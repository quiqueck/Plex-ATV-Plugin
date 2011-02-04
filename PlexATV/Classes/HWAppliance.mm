#define LOCAL_DEBUG_ENABLED 1

#import "HWAppliance.h"
#import "BackRowExtras.h"
#import "HWPlexDir.h"
#import "HWBasicMenu.h"
#import "HWSettingsController.h"
#import <Foundation/Foundation.h>
#import <plex-oss/PlexRequest + Security.h>
#import <plex-oss/MachineManager.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/MachineConnectionBase.h>
#import "SMFramework.h"
#import "HWUserDefaults.h"
#import "Constants.h"

#define OTHERSERVERS_ID @"hwOtherServer"
#define SETTINGS_ID @"hwSettings"
#define OTHERSERVERS_CAT [BRApplianceCategory categoryWithName:NSLocalizedString(@"Other Servers", @"Other Servers") identifier:OTHERSERVERS_ID preferredOrder:98]
#define SETTINGS_CAT [BRApplianceCategory categoryWithName:NSLocalizedString(@"Settings", @"Settings") identifier:SETTINGS_ID preferredOrder:99]

//dictionary keys
NSString * const CategoryNameKey = @"PlexApplianceName";
NSString * const MachineIdKey = @"PlexMachineUID";
NSString * const MachineNameKey = @"PlexMachineName";

@interface UIDevice (ATV)
+(void)preloadCurrentForMacros;
@end

@interface BRTopShelfView (specialAdditions)
- (BRImageControl *)productImage;
@end


@implementation BRTopShelfView (specialAdditions)
- (BRImageControl *)productImage {
	return MSHookIvar<BRImageControl *>(self, "_productImage");
}
@end


@interface TopShelfController : NSObject {}
- (void)selectCategoryWithIdentifier:(id)identifier;
- (id)topShelfView;
- (void)refresh;
@end

@implementation TopShelfController
- (void)initWithApplianceController:(id)applianceController {}
- (void)selectCategoryWithIdentifier:(id)identifier {}
- (void)refresh{}


- (BRTopShelfView *)topShelfView {
	BRTopShelfView *topShelf = [[BRTopShelfView alloc] init];
	BRImageControl *imageControl = [topShelf productImage];
	BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[HWPlexDir class]] pathForResource:@"PlexLogo" ofType:@"png"]];
	//BRImage *theImage = [[BRThemeInfo sharedTheme] largeGeniusIconWithReflection];
	[imageControl setImage:theImage];
	
	return [topShelf autorelease];
}
@end


#pragma mark -
#pragma mark PlexAppliance


@implementation PlexAppliance
@synthesize topShelfController = _topShelfController;
@synthesize applianceCat = _applianceCategories;
@synthesize machines = _machines;

NSString * const CompoundIdentifierDelimiter = @"|||";

+ (void)initialize {}


- (id)init {
	if((self = [super init]) != nil) {
		
		[UIDevice preloadCurrentForMacros];
		//#warning Please check elan.plexapp.com/2010/12/24/happy-holidays-from-plex/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+osxbmc+%28Plex%29 to get a set of transcoder keys
		[PlexRequest setStreamingKey:@"k3U6GLkZOoNIoSgjDshPErvqMIFdE0xMTx8kgsrhnC0=" forPublicKey:@"KQMIY6GATPC63AIMC4R2"];
		//instrumentObjcMessageSends(YES);
		
		NSString *logPath = @"/tmp/PLEX.txt"; 
		NSLog(@"Redirecting Log to %@", logPath);
		
		/*		FILE fl1 = fopen([logPath fileSystemRepresentation], "a+");
		 fclose(fl1);*/
		freopen([logPath fileSystemRepresentation], "a+", stderr);
		freopen([logPath fileSystemRepresentation], "a+", stdout);
		
		_topShelfController = [[TopShelfController alloc] init];
		_applianceCategories = [[NSMutableArray alloc] init];
		_machines = [[NSMutableArray alloc] init];
		
		otherServersApplianceCategory = [OTHERSERVERS_CAT retain];
		settingsApplianceCategory = [SETTINGS_CAT retain];
		
		[[ProxyMachineDelegate shared] registerDelegate:self];
		[[MachineManager sharedMachineManager] startAutoDetection];
	} return self;
}

- (Machine *)machineFromUid:(NSString *)uid {
	NSPredicate *machinePredicate = [NSPredicate predicateWithFormat:@"uid == %@", uid];
	NSArray *matchingMachines = [self.machines filteredArrayUsingPredicate:machinePredicate];
	if ([matchingMachines count] != 1) {
		NSLog(@"ERROR: incorrect number of machine matches to selected appliance with uid [%@]", uid);
		return nil;
	}
	return [matchingMachines objectAtIndex:0];
}

- (id)controllerForIdentifier:(id)identifier args:(id)args {
	id menuController = nil;
	
	if ([OTHERSERVERS_ID isEqualToString:identifier]) {
		menuController = [[HWBasicMenu alloc] init];
	} else if ([SETTINGS_ID isEqualToString:identifier]) {
		HWSettingsController* hwsc = [[HWSettingsController alloc] init];
		hwsc.topLevelController = self;
		menuController = hwsc;
	} else {
		// ====== get the name of the category and identifier of the machine selected ======
		NSDictionary *compoundIdentifier = (NSDictionary *)identifier;
		
		NSString *categoryName = [compoundIdentifier objectForKey:CategoryNameKey];
		NSString *machineUid = [compoundIdentifier objectForKey:MachineIdKey];
		//NSString *machineName = [compoundIdentifier objectForKey:MachineNameKey];
		
		// ====== find the machine using the identifer (uid) ======
		Machine *machineWhoCategoryBelongsTo = [self machineFromUid:machineUid];
		if (!machineWhoCategoryBelongsTo) return nil;
		
		// ====== find the category selected ======		
		NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"name == %@", categoryName];
		NSArray *categories = [[machineWhoCategoryBelongsTo.request rootLevel] directories];
		NSArray *matchingCategories = [categories filteredArrayUsingPredicate:categoryPredicate];
		if ([matchingCategories count] != 1) {
			NSLog(@"ERROR: incorrect number of category matches to selected appliance with name [%@]", categoryName);
			return nil;
		}
		
		//HAZAA! we found it! Push new view
		PlexMediaObject* matchingCategory = [matchingCategories objectAtIndex:0];
		HWPlexDir* menuController = [[HWPlexDir alloc] initWithRootContainer:[matchingCategory contents]];
		[[[BRApplicationStackManager singleton] stack] pushController:menuController];
	}
	
	return [menuController autorelease];
}

- (id)applianceCategories {
	//sort the array alphabetically
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[self.applianceCat sortUsingDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	//update the appliance ordering variable so they are listed in alphabetically order in the menu.
	//this is done and saved to the mutuable array, so should be pretty fast as only the recently added
	//items (which are appended to the end of the array) will need to be moved.
	BRApplianceCategory *appliance;
	for (int i = 0; i<[self.applianceCat count]; i++) {
		appliance = [self.applianceCat objectAtIndex:i];
		[appliance setPreferredOrder:i];
	}
	//other servers appliance category, set it to the second to last
	[otherServersApplianceCategory setPreferredOrder:[self.applianceCat count]];
	//settings appliance category, set it to the end of the list
	[settingsApplianceCategory setPreferredOrder:[self.applianceCat count]+1];
	
	//we need to add in the "special appliances"
	NSMutableArray *allApplianceCategories = [NSMutableArray arrayWithArray:self.applianceCat];
	[allApplianceCategories addObject:otherServersApplianceCategory];
	[allApplianceCategories addObject:settingsApplianceCategory];
	return allApplianceCategories;
}

- (id)identifierForContentAlias:(id)contentAlias { return @"Plex"; }
- (id)selectCategoryWithIdentifier:(id)ident { return nil; }
- (BOOL)handleObjectSelection:(id)fp8 userInfo:(id)fp12 { return YES; }
- (id)applianceSpecificControllerForIdentifier:(id)arg1 args:(id)arg2 { return nil; }
- (id)localizedSearchTitle { return @"Plex"; }
- (id)applianceName { return @"Plex"; }
- (id)moduleName { return @"Plex"; }
- (id)applianceKey { return @"Plex"; }

-(void) redisplayCategories{
	[super reloadCategories];
}

-(void) reloadCategories {
	[self.applianceCat removeAllObjects];
	
	NSArray *machines = [[MachineManager sharedMachineManager] machines];
	for (Machine *machine in machines) {
		NSString *machineID = [machine.machineID copy];
		NSString *machineName = [machine.serverName copy];
		
		//check if the user has opted to use default server view mode
		//if he has, check if the current machine is the default one
		//it it is not, skip to the next machine, else keep going
		if (![[HWUserDefaults preferences] boolForKey:PreferencesUseCombinedPmsView]
			&& ![machineID isEqualToString:[[HWUserDefaults preferences] objectForKey:PreferencesDefaultServerUid]])
			continue;
		
		if (machine.isComplete) {						   
			//================== add all it's categories to our appliances list ==================
			//machine.request.rootLevel = machine.rootLevel + machine.librarySections
			for (PlexMediaObject *pmo in machine.request.rootLevel) {
				NSString *categoryName = [pmo.name copy];
#if LOCAL_DEBUG_ENABLED
				NSLog(@"Adding category [%@] for machine id [%@]", categoryName, machineID);
#endif
				
				//create the compoundIdentifier for the appliance identifier
				NSMutableDictionary *compoundIdentifier = [NSMutableDictionary dictionary];
				[compoundIdentifier setObject:categoryName forKey:CategoryNameKey];
				[compoundIdentifier setObject:machineID forKey:MachineIdKey];
				[compoundIdentifier setObject:machineName forKey:MachineNameKey];
				
				//================== add the appliance ==================
				
				//the appliance order will be the highest number (ie it will be put at the end of the menu.
				//this will be readjusted when the array is sorted in the (id)applianceCategories
				float applianceOrder = [self.applianceCat count];
				
				BRApplianceCategory *appliance = [BRApplianceCategory categoryWithName:categoryName identifier:compoundIdentifier preferredOrder:applianceOrder];
				[self.applianceCat addObject:appliance];
				
				// find any duplicate names of the one currently being added.
				// if found, append machine name to them all
				NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"name == %@", categoryName];
				NSArray *duplicateNameCategories = [self.applianceCat filteredArrayUsingPredicate:categoryPredicate];
				if ([duplicateNameCategories count] > 1) {
					//================== found duplicate category names ==================
#if LOCAL_DEBUG_ENABLED
					NSLog(@"Found [%@] duplicate categories with name [%@]", [duplicateNameCategories count], categoryName);
#endif
					//iterate over all of them updating their names
					for (BRApplianceCategory *appl in duplicateNameCategories) {			
						
						NSDictionary *compoundIdentifierBelongingToDuplicateAppliance = (NSDictionary *)appl.identifier;
						NSString *nameOfMachineThatCategoryBelongsTo = [compoundIdentifierBelongingToDuplicateAppliance objectForKey:MachineNameKey];
						if (!nameOfMachineThatCategoryBelongsTo) break;
						
						// update the name
						// name had format:       "Movies"
						// now changing it to be: "Movies (Office)"
						NSString *nameWithPms = [[NSString alloc] initWithFormat:@"%@ (%@)", categoryName, nameOfMachineThatCategoryBelongsTo];
						[appl setName:nameWithPms];
						[nameWithPms release];
					}
				}
				[categoryName release];
			}
			[machineID release];
			[machineName release];
		}
	}
	[machines release];
	
	[super reloadCategories];
}


#pragma mark -
#pragma mark Machine Delegate Methods
-(void)machineWasRemoved:(Machine*)m{
#if LOCAL_DEBUG_ENABLED
	NSLog(@"MachineManager: Removed machine %@", m);
#endif
	[self reloadCategories];
}

-(void)machineWasAdded:(Machine*)m {	
#if LOCAL_DEBUG_ENABLED
	NSLog(@"MachineManager: Added machine %@", m);
	//new machine added, no need to take action until we have a valid connection
#endif
}

-(void)machine:(Machine*)m receivedInfoForConnection:(MachineConnectionBase*)con updated:(ConnectionInfoType)updateMask;
#if LOCAL_DEBUG_ENABLED
NSLog(@"MachineManager: Received Info For connection %@ from machine %@", con, m);
#endif
if (machine.isComplete && [machine.bestConnection isEqual:con] 
	&& (updateMask == ConnectionInfoTypeRootLevel || updateMask == ConnectionInfoTypeLibrarySections) {
		[self reloadCategories];
	}
	}
	
	-(void)machineWasChanged:(Machine*)m {
		if (m==nil) return;
		
		BOOL machineRunsServer = runsServer(m.role);
		BOOL machineIsOnline = m.isOnline;
		
		if (machine.isComplete) {
#if LOCAL_DEBUG_ENABLED
			NSLog(@"MachineManager: Changed %@", m);
#endif
		} else {
#if LOCAL_DEBUG_ENABLED
			NSLog(@"MachineManager: Machine %@ offline", m);
#endif
			[self reloadCategories];
		}
	}
	
	-(void)machine:(Machine*)m changedClientTo:(ClientConnection*)cc{}
	@end

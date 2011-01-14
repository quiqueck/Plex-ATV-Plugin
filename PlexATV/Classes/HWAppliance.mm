

#import "BackRowExtras.h"
#import "HWPlexDir.h"
#import "HWBasicMenu.h"
#import "HWSettingsController.h"
#import <Foundation/Foundation.h>
#import <plex-oss/PlexRequest + Security.h>
#import <plex-oss/MachineManager.h>
#import <plex-oss/PlexMediaContainer.h>
#import "Constants.h"
#import "SMFPreferences.h"

#define OTHERSERVERS_ID @"hwOtherServer"
#define SETTINGS_ID @"hwSettings"
#define OTHERSERVERS_CAT [BRApplianceCategory categoryWithName:NSLocalizedString(@"Other Servers", @"Other Servers") identifier:OTHERSERVERS_ID preferredOrder:98]
#define SETTINGS_CAT [BRApplianceCategory categoryWithName:NSLocalizedString(@"Settings", @"Settings") identifier:SETTINGS_ID preferredOrder:99]

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
@interface PlexAppliance: BRBaseAppliance <MachineManagerDelegate> {
	TopShelfController *_topShelfController;
	NSMutableArray *_applianceCategories;
	NSMutableArray *_machines;
}
@property(nonatomic, readonly, retain) id topShelfController;
@property(retain) NSMutableArray *applianceCat;
@property(nonatomic, retain) NSMutableArray *machines;

- (void)retrieveNewPlexCategories:(Machine *)m;
- (void)addNewApplianceWithDict:(NSDictionary *)dict;
- (void)addNewApplianceWithName:(NSString *)name identifier:(id)ident;
- (void)removeAppliancesWithIdentifier:(id)ident;
@end

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
		
		//setup user preferences
		[[SMFPreferences preferences] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
														NO, PreferencesUseCombinedPmsView, 
														@"<No Default Selected>", PreferencesDefaultServerName,
														@"", PreferencesDefaultServerUid,
														@"Low", PreferencesQualitySetting,
														nil]];
		
		_topShelfController = [[TopShelfController alloc] init];
		//preload the main menu with the settings menu item
		_applianceCategories = [[NSMutableArray alloc] initWithObjects:OTHERSERVERS_CAT,SETTINGS_CAT,nil];
		_machines = [[NSMutableArray alloc] init];
		
		
    [[ProxyMachineDelegate shared] registerDelegate:self];
		[[MachineManager sharedMachineManager] startAutoDetection];
		
	} return self;
}


- (id)controllerForIdentifier:(id)identifier args:(id)args {
	id menuController = nil;
	
	if ([identifier isEqualToString:OTHERSERVERS_ID]) {
		menuController = [[HWBasicMenu alloc] init];
	} else if ([identifier isEqualToString:SETTINGS_ID]) {
		menuController = [[HWSettingsController alloc] init];
	} else {
		// ====== get the name of the category and identifier of the machine selected ======
		// compoundIdentifier has format:
		// Example: "45E13AB3-E11C-44DD-B4F8-8A0DE1111990<delimiter>Movies"
		// or       "45E13AB3-E11C-44DD-B4F8-8A0DE1111990<delimiter>Movies (Office)"
		NSArray *compoundIdentifierComponents = [(NSString *)identifier componentsSeparatedByString:CompoundIdentifierDelimiter];
		if ([compoundIdentifierComponents count] != 2) {
			NSLog(@"ERROR: incorrect number of components in compoundIdentifier: [%@]", identifier);
			return nil;
		}
		NSString *ident = [compoundIdentifierComponents objectAtIndex:0];
		NSMutableString *categoryName = [[compoundIdentifierComponents objectAtIndex:1] mutableCopy];
		
		// ====== find the machine using the identifer (uid) ======
		NSPredicate *machinePredicate = [NSPredicate predicateWithFormat:@"uid == %@", ident];
		NSArray *matchingMachines = [self.machines filteredArrayUsingPredicate:machinePredicate];
		if ([matchingMachines count] != 1) {
			NSLog(@"ERROR: incorrect number of machine matches to selected appliance with uid [%@]", ident);
			return nil;
		}
		Machine *machineWhoCategoryBelongsTo = [matchingMachines objectAtIndex:0];
		
		// ====== find the category selected ======
		// If this category name was a duplicate of another (ie 2x"Movies", then
		// the machine name has been appended to it (ie "Movies (Office)") which needs
		// to be removed so we can find the right entry in the machine's rootlists'
		//directory
		NSString *machineNameToPotentiallyRemove = [[NSString alloc] initWithFormat:@" (%@)", machineWhoCategoryBelongsTo.serverName];
		[categoryName replaceOccurrencesOfString:machineNameToPotentiallyRemove withString:@"" options:nil range:NSMakeRange(0, [categoryName length])];

		NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"name == %@", categoryName];
		NSArray *categories = [[machineWhoCategoryBelongsTo.request rootLevel] directories];
		NSArray *matchingCategories = [categories filteredArrayUsingPredicate:categoryPredicate];
		if ([matchingCategories count] != 1) {
			NSLog(@"ERROR: incorrect number of category matches to selected appliance with name [%@]", categoryName);
			return nil;
		}
		
		//HAZAA! we found it! Push new view
		PlexMediaObject* matchingCategory = [matchingCategories objectAtIndex:0];
		HWPlexDir* menuController = [[HWPlexDir alloc] init];
		menuController.rootContainer = [matchingCategory contents];
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
		
		int newPreferredOrder;
		if ([appliance.identifier isEqualToString:OTHERSERVERS_ID]) {
			//other servers appliance category, set it to the second to last
			newPreferredOrder = [self.applianceCat count];
		} else if ([appliance.identifier isEqualToString:SETTINGS_ID]) {
			//settings appliance category, set it to the end of the list
			newPreferredOrder = [self.applianceCat count] + 1;
		} else {
			newPreferredOrder = i;
		}
		[appliance setPreferredOrder:newPreferredOrder];
	}
	return self.applianceCat;
}

- (id)identifierForContentAlias:(id)contentAlias { return @"Plex"; }
- (id)selectCategoryWithIdentifier:(id)ident { return nil; }
- (BOOL)handleObjectSelection:(id)fp8 userInfo:(id)fp12 { return YES; }
- (id)applianceSpecificControllerForIdentifier:(id)arg1 args:(id)arg2 { return nil; }
- (id)localizedSearchTitle { return @"Plex"; }
- (id)applianceName { return @"Plex"; }
- (id)moduleName { return @"Plex"; }
- (id)applianceKey { return @"Plex"; }


#pragma mark -
#pragma mark Sync Plex Categories With Appliances
NSString * const ApplianceNameKey = @"PlexApplianceName";
NSString * const MachineUIDKey = @"PlexMachineUID";

- (void)retrieveNewPlexCategories:(Machine *)m {
	//autorelease pool to avoid memory leaks
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"Retrieving categories for machine %@", m);
	PlexMediaContainer *rootContainer = [m.request rootLevel];
	NSMutableArray *directories = rootContainer.directories;
	
	for (PlexMediaObject *pmo in directories) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[pmo.name copy] forKey:ApplianceNameKey];
		[dict setObject:[m.uid copy] forKey:MachineUIDKey];
		[self performSelectorOnMainThread:@selector(addNewApplianceWithDict:) withObject:dict waitUntilDone:NO];
		NSLog(@"Adding category [%@] for machine uid [%@]", pmo.name, m.uid);
	}
	[pool drain];
}

- (void)addNewApplianceWithDict:(NSDictionary *)dict {
	//argument is a dict due to objects being passed between threads
	NSString *applianceName = [dict objectForKey:ApplianceNameKey];
	NSString *machineUid = [dict objectForKey:MachineUIDKey];
	
	[self addNewApplianceWithName:applianceName identifier:machineUid];
}
								
- (void)addNewApplianceWithName:(NSString *)name identifier:(id)ident {
	// creates a compoundIdentifier to help us find back to the right machine and category.
	// Example: "45E13AB3-E11C-44DD-B4F8-8A0DE1111990<delimiter>Movies"
	NSString *compoundIdentifier = [[NSString alloc] initWithFormat:@"%@%@%@", (NSString *)ident, CompoundIdentifierDelimiter, name];
	
	//the appliance order will be the highest number (ie it will be put at the end of the menu.
	//this will be readjusted when the array is sorted in the (id)applianceCategories
	float applianceOrder = [self.applianceCat count];
	NSLog(@"Adding appliance with name [%@] with identifier [%@]", name, compoundIdentifier);
	BRApplianceCategory *appliance = [BRApplianceCategory categoryWithName:name identifier:compoundIdentifier preferredOrder:applianceOrder];
	[self.applianceCat addObject:appliance];
	
	// find any duplicate names of the one currently being added.
	// if found, append pms name to them all
	NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"name == %@", name];
	NSArray *duplicateNameCategories = [self.applianceCat filteredArrayUsingPredicate:categoryPredicate];
	if ([duplicateNameCategories count] > 1) {
		//found duplicates, iterate over all of them updating their names
		for (BRApplianceCategory *appl in duplicateNameCategories) {
			//vvv needs refactoring vvv
			NSArray *compoundIdentifierComponents = [appl.identifier componentsSeparatedByString:CompoundIdentifierDelimiter];
			if ([compoundIdentifierComponents count] != 2) {
				NSLog(@"ERROR: incorrect number of components in compoundIdentifier: [%@]", appl.identifier);
				break;
			}
			NSString *ident = [compoundIdentifierComponents objectAtIndex:0];
			// ====== find the machine using the identifer (uid) ======
			NSPredicate *machinePredicate = [NSPredicate predicateWithFormat:@"uid == %@", ident];
			NSArray *matchingMachines = [self.machines filteredArrayUsingPredicate:machinePredicate];
			if ([matchingMachines count] != 1) {
				NSLog(@"ERROR: incorrect number of machine matches to selected appliance");
				break;
			}
			Machine *machineWhoCategoryBelongsTo = [matchingMachines objectAtIndex:0];
			//^^^ needs refactoring ^^^
			
			// update the name
			// name had format:       "Movies"
			// now changing it to be: "Movies (Office)"
			NSString *nameWithPms = [[NSString alloc] initWithFormat:@"%@ (%@)", name, machineWhoCategoryBelongsTo.serverName];
			[appl setName:nameWithPms];
			[nameWithPms release];
			
			//update the compoundIdentifier to match the new name
			// compoundIdentifier had format: "45E13AB3-E11C-44DD-B4F8-8A0DE1111990<delimiter>Movies"
			// now changing it to be:         "45E13AB3-E11C-44DD-B4F8-8A0DE1111990<delimiter>Movies (Office)"
			NSString *compoundIdentifier = [[NSString alloc] initWithFormat:@"%@%@%@", ident, CompoundIdentifierDelimiter, nameWithPms];
			[appl setIdentifier:compoundIdentifier];
			[compoundIdentifier release];
		}
	}
	
	[self reloadCategories];
}

- (void)removeAppliancesWithIdentifier:(id)ident {
	// called with actual UID (ie. "45E13AB3-E11C-44DD-B4F8-8A0DE1111990") of the
	// machine rather than the compoundIdentifier's used for the categories
	NSLog(@"Removing appliances with identifier [%@]", (NSString *)ident);
	
	//these appliances belongs to this machine
	NSPredicate *machinePredicate = [NSPredicate predicateWithFormat:@"uid == %@", ident];
	NSArray *matchingMachines = [self.machines filteredArrayUsingPredicate:machinePredicate];
	if ([matchingMachines count] != 1) {
		NSLog(@"ERROR: incorrect number of machine matches to selected appliance with uid [%@]", ident);
		return;
	}
	Machine *machineWhosCategoriesAreBeingRemoved = [matchingMachines objectAtIndex:0];
	
	// find and remove all the appliances who's compoundIdentifers begin with the uid of this machine.
	// this will be all the appliances who "belong" to this machine
	// "45E13AB3-E11C-44DD-B4F8-8A0DE1111990<delimiter>Movies"
	NSPredicate *appliancePredicate = [NSPredicate predicateWithFormat:@"identifier BEGINSWITH %@", ident];
	NSArray *appliancesToRemove = [self.applianceCat filteredArrayUsingPredicate:appliancePredicate];
	[self.applianceCat removeObjectsInArray:appliancesToRemove];
	
	// now they have been removed from the main menu. 
	// Must check if any of these items had the machine name appended because then there might
	// not be duplicates with that name left (ie we have gone from having 2x"Movies" to 1x"Movies)
	// and the remaining "Movies" item no longer need the pms name appended.
	// This means we go from "Movies (Office)" to just "Movies". Though we must check that there only
	// is 1x"Movies", cause the case could have been that we had 3x"Movies", and now have 2x"Movies"
	// and the pms name must remain.
	for (BRApplianceCategory *appliance in appliancesToRemove) {
		NSMutableString *categoryName = [appliance.name mutableCopy];
		NSString *machineNameToPotentiallyRemove = [[NSString alloc] initWithFormat:@" (%@)", machineWhosCategoriesAreBeingRemoved.serverName];
		[categoryName replaceOccurrencesOfString:machineNameToPotentiallyRemove withString:@"" options:nil range:NSMakeRange(0, [categoryName length])];
		NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH %@", categoryName];
		
		NSArray *matchingAppliances = [self.applianceCat filteredArrayUsingPredicate:categoryPredicate];
		if ([matchingAppliances count] == 1) {
			//there is now only 1x"Movies" left, remove the pms suffix
			BRApplianceCategory *singleMatch = [matchingAppliances objectAtIndex:0];
			[singleMatch setName:categoryName];
		}
	}
	[self reloadCategories];
}

#pragma mark -
#pragma mark Machine Delegate Methods
-(void)machineWasRemoved:(Machine*)m{
  NSLog(@"MachineManager: Removed machine %@", m);
  [self removeAppliancesWithIdentifier:m.uid];
}

- (void)machineWasAdded:(Machine*)m {
	if (![[SMFPreferences preferences] boolForKey:PreferencesUseCombinedPmsView]
		&& ![m.uid isEqualToString:[[SMFPreferences preferences] objectForKey:PreferencesDefaultServerUid]])
		  return;
	
    BOOL machineRunsServer = runsServer(m.role);
    BOOL machineIsOnline = m.isOnline;
    BOOL machinesListAlreadyContainsMachine = [self.machines containsObject:m];
    
    if ( machineRunsServer && machineIsOnline && !machinesListAlreadyContainsMachine ) {
	    [self.machines addObject:m];
	    NSLog(@"MachineManager: Added machine %@", m);
		
	    [m resolveAndNotify:self];
		
		//retrieve new categories
		[self performSelectorInBackground:@selector(retrieveNewPlexCategories:) withObject:[m retain]];
		//does not reload at this time as the background thread will tell the main thread to refresh
		//once it has finished its work
    }
}

- (void)machineStateDidChange:(Machine*)m {
	if (m==nil) return;
	
	BOOL machineRunsServer = runsServer(m.role);
    BOOL machineIsOnline = m.isOnline;
    BOOL machinesListAlreadyContainsMachine = [self.machines containsObject:m];
	
	/*if ( machineRunsServer && machineIsOnline && !machinesListAlreadyContainsMachine ) {
		[self machineWasAdded:m];
		return;
	} else */ if ( (!machineRunsServer || !machineIsOnline) && machinesListAlreadyContainsMachine ) {
		[self removeAppliancesWithIdentifier:m.uid];
		NSLog(@"MachineManager: Removed %@", m);
		[self.machines removeObject:m];
	} else {
		NSLog(@"MachineManager: Changed %@", m);
	}
	//[self reloadCategories];
}

- (void)machineResolved:(Machine*)m {
	NSLog(@"MachineManager: Resolved %@", m);
}

- (void)machineDidNotResolve:(Machine*)m {
	NSLog(@"MachineManager: Unable to Resolve %@", m);
}

- (void)machineReceivedClients:(Machine*)m {
	NSLog(@"MachineManager: Got list of clients %@", m);
}


@end

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
#import "HWUserDefaults.h"
#import "Constants.h"
#import "HWMediaGridController.h"
#import "HWTVShowsController.h"

#define SERVER_LIST_ID @"hwServerList"
#define SETTINGS_ID @"hwSettings"
#define SERVER_LIST_CAT [BRApplianceCategory categoryWithName:NSLocalizedString(@"Server List", @"Server List") identifier:SERVER_LIST_ID preferredOrder:98]
#define SETTINGS_CAT [BRApplianceCategory categoryWithName:NSLocalizedString(@"Settings", @"Settings") identifier:SETTINGS_ID preferredOrder:99]

//dictionary keys
NSString * const CategoryNameKey = @"PlexApplianceName";
NSString * const MachineIDKey = @"PlexMachineID";
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
	[imageControl setImage:theImage];
	
	return [topShelf autorelease];
}
@end


#pragma mark -
#pragma mark PlexAppliance


@implementation PlexAppliance
@synthesize topShelfController = _topShelfController;
@synthesize applianceCat = _applianceCategories;

NSString * const CompoundIdentifierDelimiter = @"|||";

+ (void)initialize {}


- (id)init {
	if((self = [super init]) != nil) {
		
		[UIDevice preloadCurrentForMacros];
		//#warning Please check elan.plexapp.com/2010/12/24/happy-holidays-from-plex/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+osxbmc+%28Plex%29 to get a set of transcoder keys
		[PlexRequest setStreamingKey:@"k3U6GLkZOoNIoSgjDshPErvqMIFdE0xMTx8kgsrhnC0=" forPublicKey:@"KQMIY6GATPC63AIMC4R2"];
		//instrumentObjcMessageSends(YES);
		
		
		DLog(@"==================== plex client starting up ====================");
		
		DLog(@"stuff: ",[[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lastPathComponent]);
		_topShelfController = [[TopShelfController alloc] init];
		_applianceCategories = [[NSMutableArray alloc] init];
		
		otherServersApplianceCategory = [SERVER_LIST_CAT retain];
		settingsApplianceCategory = [SETTINGS_CAT retain];
		
		[[ProxyMachineDelegate shared] registerDelegate:self];
		[[MachineManager sharedMachineManager] startAutoDetection];
		[[MachineManager sharedMachineManager] startMonitoringMachineState];
	} return self;
}

- (id)controllerForIdentifier:(id)identifier args:(id)args {
	id menuController = nil;
	
	if ([SERVER_LIST_ID isEqualToString:identifier]) {
		menuController = [[HWBasicMenu alloc] init];
	} else if ([SETTINGS_ID isEqualToString:identifier]) {
		HWSettingsController* hwsc = [[HWSettingsController alloc] init];
		hwsc.topLevelController = self;
		menuController = hwsc;
	} else {
		// ====== get the name of the category and identifier of the machine selected ======
		NSDictionary *compoundIdentifier = (NSDictionary *)identifier;
		
		NSString *categoryName = [compoundIdentifier objectForKey:CategoryNameKey];
		NSString *machineId = [compoundIdentifier objectForKey:MachineIDKey];
		//NSString *machineName = [compoundIdentifier objectForKey:MachineNameKey];
		
		// ====== find the machine using the identifer (uid) ======
		Machine *machineWhoCategoryBelongsTo = [[MachineManager sharedMachineManager] machineForMachineID:machineId];
		if (!machineWhoCategoryBelongsTo) return nil;
		
		// ====== find the category selected ======		
		NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"name == %@", categoryName];
		NSArray *categories = [[machineWhoCategoryBelongsTo.request rootLevel] directories];
		NSArray *matchingCategories = [categories filteredArrayUsingPredicate:categoryPredicate];
		if ([matchingCategories count] != 1) {
			DLog(@"ERROR: incorrect number of category matches to selected appliance with name [%@]", categoryName);
			return nil;
		}
		
		//HAZAA! we found it! Push new view
		PlexMediaObject* matchingCategory = [matchingCategories objectAtIndex:0];
		DLog(@"matchingCategory: %@", [matchingCategory type]);
		if (matchingCategory.isMovie) {
			menuController = [self newMoviesController:[matchingCategory contents]];
		} else if (matchingCategory.isTVShow) {
			menuController = [self newTVShowsController:[matchingCategory contents]];
		} else {
			menuController = [[HWPlexDir alloc] initWithRootContainer:[matchingCategory contents]];
		}
	}    
	return [menuController autorelease];
}

- (BRController *)newTVShowsController:(PlexMediaContainer *)tvShowCategory {
	BRController *menuController = nil;
	PlexMediaObject *allTvShows=nil;
	if (tvShowCategory.directories > 0) {
		NSUInteger i, count = [tvShowCategory.directories count];
		for (i = 0; i < count; i++) {
			PlexMediaObject * obj = [tvShowCategory.directories objectAtIndex:i];
			NSString *key = [obj.attributes objectForKey:@"key"];
			DLog(@"obj_type: %@",key);
			if ([key isEqualToString:@"all"]) {
				allTvShows = obj;
				break;
			}
		}
	}
	
	if (allTvShows) {
		menuController = [[HWTVShowsController alloc] initWithPlexAllTVShows:[allTvShows contents]];
	}
	return menuController;
}

- (BRController *)newMoviesController:(PlexMediaContainer*)movieCategory {
	BRController *menuController = nil;
	PlexMediaObject *recent=nil;
	PlexMediaObject *allMovies=nil;
    //DLog(@"showGridListControl_movieCategory_directories: %@", movieCategory.directories);
	if (movieCategory.directories > 0) {
		NSUInteger i, count = [movieCategory.directories count];
		for (i = 0; i < count; i++) {
			PlexMediaObject * obj = [movieCategory.directories objectAtIndex:i];
			NSString *key = [obj.attributes objectForKey:@"key"];
			DLog(@"obj_type: %@",key);
			if ([key isEqualToString:@"all"])
				allMovies = obj;
			else if ([key isEqualToString:@"recentlyAdded"])
				recent = obj;
		}
	}
	
	if (recent && allMovies){
		DLog(@"pushing shelfController");
		menuController = [[HWMediaGridController alloc] initWithPlexAllMovies:[allMovies contents] andRecentMovies:[recent contents]];
	}
	return menuController;
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

-(void) reloadCategories {
	[self.applianceCat removeAllObjects];
	
	NSArray *machines = [[MachineManager sharedMachineManager] threadSafeMachines];
	NSArray *machinesExcludedFromServerList = [[HWUserDefaults preferences] objectForKey:PreferencesMachinesExcludedFromServerList];
	for (Machine *machine in machines) {
		NSString *machineID = [machine.machineID copy];
		NSString *machineName = [machine.serverName copy];
		
		//check if the user has added this machine to the exclusion list
		if ([machinesExcludedFromServerList containsObject:machineID]) {
			//machine specifically excluded, skip
#if LOCAL_DEBUG_ENABLED
			DLog(@"Machine [%@] is included in the server exclusion list, skipping", machineID);
#endif
			continue;
		} else if (!machine.canConnect) {
			//machine is not connectable
#if LOCAL_DEBUG_ENABLED
			DLog(@"Cannot connect to machine [%@], skipping", machine);
#endif
			continue;
		}
		
		//================== add all it's categories to our appliances list ==================
		//not using machine.request.rootLevel.directories because it might not work,
		//instead get the two arrays seperately and merge
		NSMutableArray *allDirectories = [NSMutableArray arrayWithArray:machine.rootLevel.directories];
		[allDirectories addObjectsFromArray:machine.librarySections.directories];
		
		for (PlexMediaObject *pmo in allDirectories) {
			NSString *categoryName = [pmo.name copy];
#if LOCAL_DEBUG_ENABLED
			DLog(@"Adding category [%@] for machine id [%@]", categoryName, machineID);
#endif
			
			//create the compoundIdentifier for the appliance identifier
			NSMutableDictionary *compoundIdentifier = [NSMutableDictionary dictionary];
			[compoundIdentifier setObject:categoryName forKey:CategoryNameKey];
			[compoundIdentifier setObject:machineID forKey:MachineIDKey];
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
				DLog(@"Found [%d] duplicate categories with name [%@]", [duplicateNameCategories count], categoryName);
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
	
	[super reloadCategories];
}


#pragma mark -
#pragma mark Machine Delegate Methods
-(void)machineWasRemoved:(Machine*)m{
#if LOCAL_DEBUG_ENABLED
	DLog(@"MachineManager: Removed machine %@", m);
#endif
	[self reloadCategories];
}

-(void)machineWasAdded:(Machine*)m {   
#if LOCAL_DEBUG_ENABLED
	DLog(@"MachineManager: Added machine %@", m);
#endif
	BOOL machineIsOnlineAndConnectable = m.isComplete;
	
	if (machineIsOnlineAndConnectable) {
		[self reloadCategories];
	}
}

- (void)machineWasChanged:(Machine *)m {}

-(void)machine:(Machine *)m updatedInfo:(ConnectionInfoType)updateMask {
#if LOCAL_DEBUG_ENABLED
	DLog(@"MachineManager: Updated Info with update mask %d from machine %@", updateMask, m);
#endif
	BOOL machinesCategoryListWasUpdated = (updateMask & (ConnectionInfoTypeRootLevel | ConnectionInfoTypeLibrarySections)) != 0;
	BOOL machineHasEitherGoneOnlineOrOffline = (updateMask & ConnectionInfoTypeCanConnect) != 0;
	
	if ( machinesCategoryListWasUpdated || machineHasEitherGoneOnlineOrOffline ) {
		[self reloadCategories];
	}
}
@end
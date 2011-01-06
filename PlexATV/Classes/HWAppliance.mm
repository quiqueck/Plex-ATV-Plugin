

#import "BackRowExtras.h"
#import "HWPlexDir.h"
#import <Foundation/Foundation.h>
#import <plex-oss/PlexRequest + Security.h>
#define HELLO_ID @"hwHello"

#define HELLO_CAT [BRApplianceCategory categoryWithName:NSLocalizedString(@"Servers", @"Servers") identifier:HELLO_ID preferredOrder:0]

@interface UIDevice (ATV)
+(void)preloadCurrentForMacros;
@end

@interface BRTopShelfView (specialAdditions)

- (BRImageControl *)productImage;

@end


@implementation BRTopShelfView (specialAdditions)

- (BRImageControl *)productImage
{
	return MSHookIvar<BRImageControl *>(self, "_productImage");
}

@end


@interface TopShelfController : NSObject {
}
- (void)selectCategoryWithIdentifier:(id)identifier;
- (id)topShelfView;
- (void)refresh;
@end

@implementation TopShelfController
- (void)initWithApplianceController:(id)applianceController {}
- (void)refresh {}
- (void)selectCategoryWithIdentifier:(id)identifier {}


- (BRTopShelfView *)topShelfView {
	
	BRTopShelfView *topShelf = [[BRTopShelfView alloc] init];
	BRImageControl *imageControl = [topShelf productImage];
	BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[HWPlexDir class]] pathForResource:@"PlexLogo" ofType:@"png"]];
	[imageControl setImage:theImage];
	
	return topShelf;
}

@end

@interface PlexAppliance: BRBaseAppliance  <MachineManagerDelegate> {
	TopShelfController *_topShelfController;
	NSMutableArray *_applianceCategories;
	NSMutableArray *_machines;
}
@property(nonatomic, readonly, retain) id topShelfController;

@end

@implementation PlexAppliance
@synthesize topShelfController = _topShelfController;

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
		
		[[MachineManager sharedMachineManager] setDelegate:self];
		[[MachineManager sharedMachineManager] startAutoDetection];
		
	} return self;
}

- (id)applianceCategories {
	return _applianceCategories;
}

- (id)identifierForContentAlias:(id)contentAlias {
	return @"Plex";
}

- (id)selectCategoryWithIdentifier:(id)ident {
	return nil;
}

- (BOOL)handleObjectSelection:(id)fp8 userInfo:(id)fp12 {
	NSLog(@"handleObjectSection");
	return YES;
}

- (id)applianceSpecificControllerForIdentifier:(id)arg1 args:(id)arg2 {
	return nil;
}

- (id)controllerForIdentifier:(id)identifier args:(id)args {
	int selectedIndex = [identifier intValue];
		
	NSLog(@"%@, %ld", _machines, selectedIndex);
	Machine *m = [_machines objectAtIndex:selectedIndex];
	NSLog(@"machine selected: %@", m);
	
	HWPlexDir *menuController = [[[HWPlexDir alloc] init] autorelease];
	
	NSLog(@"request: %@", m.request);
	menuController.rootContainer = [m.request rootLevel];
	NSLog(@"request rootlevel: %@", menuController.rootContainer);
	
	return nil;
}

- (id)localizedSearchTitle { return @"Plex"; }
- (id)applianceName { return @"Plex"; }
- (id)moduleName { return @"Plex"; }
- (id)applianceKey { return @"Plex"; }

#pragma mark -
#pragma mark Machine Delegate Methods
-(void)machineWasAdded:(Machine*)m{
	[_machines addObject:m];
	NSLog(@"Added %@", m);
	
	NSNumber *identifierAndOrder = [[NSNumber alloc] initWithInt:[_applianceCategories count]];
	BRApplianceCategory *appliance = [BRApplianceCategory categoryWithName:m.serverName identifier:identifierAndOrder preferredOrder:[identifierAndOrder floatValue]];
	[identifierAndOrder release];
	[_applianceCategories addObject:appliance];
	[m resolveAndNotify:self];
	
	[self reloadCategories];
}

-(void)machineStateDidChange:(Machine*)m{
	if (m == nil) return;
	
#pragma mark TODO should remove machines when they go offline. 
	//I have tried using: m.uid, m.serverName, m.hostName, m.mac, m.ip, m.isOnline
	//but none seem to switch between a machine/pms that was online and one that is
	
	if (![_machines containsObject:m]){
		[self machineWasAdded:m];
	} else {
		[self reloadCategories];
	}
}

-(void)machineResolved:(Machine*)m{
	NSLog(@"Resolved %@", m);
}

-(void)machineDidNotResolve:(Machine*)m{
	NSLog(@"Unable to Resolve %@", m);
}

-(void)machineReceivedClients:(Machine*)m{
	NSLog(@"Got list of clients %@", m);
}

@end



#import "BackRowExtras.h"
#import "HWBasicMenu.h"
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
@end

@implementation TopShelfController
- (void)initWithApplianceController:(id)applianceController {

	
	
}

- (void)selectCategoryWithIdentifier:(id)identifier {
	
	static id menuController = nil;
	
	if ([identifier isEqualToString:HELLO_ID])
	{

		if (menuController==nil)
			menuController = [[HWBasicMenu alloc] init];
		
	} 
	
	
	[[[BRApplicationStackManager singleton] stack] pushController:menuController];
	//[menuController autorelease];
}




- (BRTopShelfView *)topShelfView {
	
	BRTopShelfView *topShelf = [[BRTopShelfView alloc] init];
	BRImageControl *imageControl = [topShelf productImage];
	BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[HWBasicMenu class]] pathForResource:@"PlexLogo" ofType:@"png"]];
	//BRImage *theImage = [[BRThemeInfo sharedTheme] largeGeniusIconWithReflection];
	[imageControl setImage:theImage];
	
	return [topShelf autorelease];
}

@end

@interface PlexAppliance: BRBaseAppliance {
	TopShelfController *_topShelfController;
	NSArray *_applianceCategories;
}
@property(nonatomic, readonly, retain) id topShelfController;

@end

@implementation PlexAppliance
@synthesize topShelfController = _topShelfController;

+ (void)initialize {
}


- (id)init {
	if((self = [super init]) != nil) {
		[UIDevice preloadCurrentForMacros];
  #warning Please check ... to get a set of transcoder keys
    [PlexRequest setStreamingKey:@"Get Your Keys From" forPublicKey:@"plexapp.com"];
		//instrumentObjcMessageSends(YES);
		
		NSString *logPath = @"/tmp/PLEX.txt"; 
		NSLog(@"Redirecting Log to %@", logPath);
		
/*		FILE fl1 = fopen([logPath fileSystemRepresentation], "a+");
		fclose(fl1);*/
		freopen([logPath fileSystemRepresentation], "a+", stderr);
		freopen([logPath fileSystemRepresentation], "a+", stdout);
		
		
		_topShelfController = [[TopShelfController alloc] init];
		
		_applianceCategories = [[NSArray alloc] initWithObjects:HELLO_CAT,nil];
	
	} return self;
}

- (id)applianceCategories {
	return _applianceCategories;
}

- (id)identifierForContentAlias:(id)contentAlias {
	return @"Local Servers";
}

- (id)selectCategoryWithIdentifier:(id)ident {
	//NSLog(@"selecteCategoryWithIdentifier: %@", ident);
	return nil;
}

- (BOOL)handleObjectSelection:(id)fp8 userInfo:(id)fp12 {
	NSLog(@"handleObjectSeection");
	return YES;
}

- (id)applianceSpecificControllerForIdentifier:(id)arg1 args:(id)arg2 {
	//NSLog(@"applianceSpecificControllerForIdentifier: %@ args: %@", arg1, arg2);
	return nil;
}

- (id)localizedSearchTitle { return @"Servers"; }
- (id)applianceName { return @"Servers"; }
- (id)moduleName { return @"Servers"; }
- (id)applianceKey { return @"Servers"; }

@end

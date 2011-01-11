//
//  HWSettingsController.m
//  atvTwo
//
//  Created by camelot on 10/01/2011.
//

#import "HWSettingsController.h"
#import "SMFMenuItem.h"
#import "HWPmsListController.h"

@implementation HWSettingsController

NSString * const PlexDefaultServer = @"PlexDefaultServer";
NSString * const PlexQualitySetting = @"PlexQualitySetting";

#define DefaultServerIndex 0
#define QualitySettingIndex 1

#pragma mark -
#pragma mark init/dealoc

- (id) init {
	if((self = [super init]) != nil) {
		[self setMenuWidthFactor:1.5];
		[self setListTitle:@"Settings"];
		
		userPreference = [SMFPreferences preferences];
		[userPreference registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
										  @"<No Default Selected>", PlexDefaultServer,
										  @"Low", PlexQualitySetting,
										  nil]];
		
		[self setupList];
	}	
	return self;
}

- (void)setupList {
	[_items removeAllObjects];
	
	// =========== default server ===========
	SMFMenuItem *defaultServerMenuItem = [SMFMenuItem folderMenuItem];
	
	NSString *defaultServer = [userPreference stringForKey:PlexDefaultServer];
	NSString *defaultServerTitle = [[NSString alloc] initWithFormat:@"Default Server:    %@", defaultServer];
	[defaultServerMenuItem setTitle:defaultServerTitle];
	[defaultServerTitle release];
	[_items addObject:defaultServerMenuItem];
	
	
	// =========== quality setting ===========
	SMFMenuItem *qualitySettingMenuItem = [SMFMenuItem menuItem];
	
	NSString *qualitySetting = [userPreference objectForKey:PlexQualitySetting];
	NSString *qualitySettingTitle = [[NSString alloc] initWithFormat:@"Quality Setting:   %@", qualitySetting];
	[qualitySettingMenuItem setTitle:qualitySettingTitle];
	[qualitySettingTitle release];
	[_items addObject:qualitySettingMenuItem];

	//this code can be used to find all the accessory types
//	for (int i = 0; i<32; i++) {
//		BRMenuItem *tempSettingMenuItem = [[BRMenuItem alloc] init];
//		[tempSettingMenuItem addAccessoryOfType:i];
//		
//		NSString *tempSettingTitle = [[NSString alloc] initWithFormat:@"temp %d", i];
//		[tempSettingMenuItem setText:tempSettingTitle withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
//		[tempSettingTitle release];
//		[_items addObject:tempSettingMenuItem];
//	}
}

- (void)dealloc {
	[userPreference release];
	[super dealloc];	
}

- (void)wasExhumed {
	[self setupList];
	[self.list reload];
	[super wasExhumed];
}

#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
	switch (selected) {
		case DefaultServerIndex: {
			// =========== default server ===========
			HWPmsListController* menuController = [[HWPmsListController alloc] init];
			[[[BRApplicationStackManager singleton] stack] pushController:menuController];
			[menuController autorelease];
			break;
		}
		case QualitySettingIndex: {
			// =========== quality setting ===========
			NSString *qualitySetting = [userPreference objectForKey:PlexQualitySetting];
			if ([qualitySetting isEqualToString:@"Low"]) {
				[userPreference setObject:@"Medium" forKey:PlexQualitySetting];
			} else if ([qualitySetting isEqualToString:@"Medium"]) {
				[userPreference setObject:@"High" forKey:PlexQualitySetting];
			} else {
				[userPreference setObject:@"Low" forKey:PlexQualitySetting];
			}
			
			[self setupList];
			[self.list reload];
			break;
		}
		default:
			break;
	}
}


@end

//
//  HWAdvancedSettingsController.m
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//
//  Inspired by 
//
//		MLoader.m
//		MextLoader
//
//		Created by Thomas Cool on 10/22/10.
//		Copyright 2010 tomcool.org. All rights reserved.
//

#import "HWAdvancedSettingsController.h"
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation HWAdvancedSettingsController

#define EnableSkipFilteringOptionsMenu 0
#define EnableDebug 1

#pragma mark -
#pragma mark init/dealoc

- (id) init {
	if((self = [super init]) != nil) {
		[self setLabel:@"Plex Advanced Settings"];
		[self setListTitle:@"Plex Advanced Settings"];
		
		[self setupList];
	}	
	return self;
}

- (void)wasPopped{
	DLog(@"Did pop controller %@", self);
	[super wasPopped];
}

- (void)setupList {
	[_items removeAllObjects];
	
	// =========== enable "skip filtering options" menu ===========
	SMFMenuItem *skipFilteringOptionsMenuItem = [SMFMenuItem menuItem];
	
	NSString *skipFilteringOptions = [[HWUserDefaults preferences] boolForKey:PreferencesAdvancedEnableSkipFilteringOptionsMenu] ? @"Enabled" : @"Disabled";
	NSString *skipFilteringOptionsTitle = [[NSString alloc] initWithFormat:@"Filtering menu:    %@", skipFilteringOptions];
	[skipFilteringOptionsMenuItem setTitle:skipFilteringOptionsTitle];
	[skipFilteringOptionsTitle release];
	[_items addObject:skipFilteringOptionsMenuItem];
	
	
	// =========== enable debug ===========
	SMFMenuItem *enableDebugMenuItem = [SMFMenuItem menuItem];
	
	NSString *enableDebug = [[HWUserDefaults preferences] boolForKey:PreferencesAdvancedEnableDebug] ? @"Enabled" : @"Disabled";
	NSString *enableDebugTitle = [[NSString alloc] initWithFormat:@"Debug:    %@", enableDebug];
	[enableDebugMenuItem setTitle:enableDebugTitle];
	[enableDebugTitle release];
	[_items addObject:enableDebugMenuItem];
}

- (void)dealloc {
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
		case EnableSkipFilteringOptionsMenu: {
			// =========== enable "skip filtering options" menu ===========
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesAdvancedEnableSkipFilteringOptionsMenu];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesAdvancedEnableSkipFilteringOptionsMenu];			
			[self setupList];
			[self.list reload];
			break;
		}
		case EnableDebug: {
			// =========== enable debug ===========
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesAdvancedEnableDebug];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesAdvancedEnableDebug];			
			[self setupList];
			[self.list reload];
			break;
		}
		default:
			break;
	}
}


-(id)previewControlForItem:(long)item
{
	SMFBaseAsset *asset = [[SMFBaseAsset alloc] init];
	switch (item) {
		case EnableSkipFilteringOptionsMenu: {
			// =========== enable "skip filtering options" menu ===========
			[asset setTitle:@"Toggles whether to skip the menu"];
			[asset setSummary:@"Enables/Disables the skipping of the menu's with 'all', 'unwatched', 'newest', etc. (currently experimental)"];
			break;
		}
		case EnableDebug: {	
			// =========== enable debug ===========
			[asset setTitle:@"Turn debug mode on or off"];
			[asset setSummary:@"Enables/Disables writing to the log file (currently not used)"];
			break;
		}
		default:
			break;
	}
	[asset setCoverArt:[BRImage imageWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"PlexSettings" ofType:@"png"]]];
	SMFMediaPreview *p = [[SMFMediaPreview alloc] init];
	[p setShowsMetadataImmediately:YES];
	[p setAsset:asset];
	[asset release];
	return [p autorelease];  
}


@end

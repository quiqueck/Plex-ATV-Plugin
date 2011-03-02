//
//  HWMediaShelfController.m
//  atvTwo
//
//  Created by bob on 2011-01-29.
//  Copyright 2011 Band's gonna make it!. All rights reserved.
//

#import "HWMediaGridController.h"
#import "PlexMediaAsset.h"
#import "PlexPreviewAsset.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import "SMFramework/SMFControlFactory.h"
#import "HWDetailedMovieMetadataController.h"

#define LOCAL_DEBUG_ENABLED 1
#define MAX_RECENT_ITEMS 20

//these are in the AppleTV.framework, but cannot #import <AppleTV/AppleTV.h> due to
//naming conflicts with Backrow.framework. below is a hack!
@interface BRThemeInfo (PlexExtentions)
- (id)storeRentalPlaceholderImage;
@end

@implementation HWMediaGridController

void checkNil(NSObject *ctrl)
{
	if (ctrl!=nil) {
		[ctrl release];
		ctrl=nil;
	}
}

-(id)initWithPath:(NSString *)path
{
	return self;
}

- (id)initWithPlexAllMovies:(PlexMediaContainer *)allMovies andRecentMovies:(PlexMediaContainer *)recentMovies {
	
	self = [self init];
	[allMovies retain];
	[recentMovies retain];
#if LOCAL_DEBUG_ENABLED
	DLog(@"initWithPlexContaner - converting to assets");
#endif
	
    // we'll cut the recent movies down to MAX_RECENT_ITEMS, since recent actually has all movies, only sorted by added date
    //and shelf isn't actually usable with bunch of items
	NSArray *fullRecentMovies = [self convertContainerToMediaAssets:recentMovies];
	NSRange theRange;  
	theRange.location = 0;
	theRange.length = [fullRecentMovies count] > MAX_RECENT_ITEMS ? MAX_RECENT_ITEMS : [fullRecentMovies count];
	
	_shelfAssets = [[fullRecentMovies subarrayWithRange:theRange] retain];
	_gridAssets = [self convertContainerToMediaAssets:allMovies];
	
	return self;
}

-(void)dealloc {
#if LOCAL_DEBUG_ENABLED
	DLog(@"deallocing HWMediaShelfController");
#endif
	_shelfAssets = nil;
	_gridAssets = nil;
    //[_spinner release];
    //[_cursorControl release];
    //[_scroller release];
	[_gridControl release];
	[_shelfControl release];
	[_panelControl release];
	
	[super dealloc];
}

- (NSArray *)convertContainerToMediaAssets:(PlexMediaContainer *)container {
	DLog(@"convertContainerToMediaAssets %@", container);
	NSMutableArray *assets = [[NSMutableArray alloc] initWithCapacity:5];
	
	for (int i=0; i < [container.directories count]; i++) {
		PlexMediaObject *mediaObj = [container.directories objectAtIndex:i];
		
		NSURL* mediaURL = [mediaObj mediaStreamURL];
		PlexPreviewAsset* pma = [[PlexPreviewAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:mediaObj];
		[assets addObject:pma];
	}
	
#if LOCAL_DEBUG_ENABLED
	DLog(@"converted %d assets", [assets count]);
#endif
	return assets;
}

- (void) drawSelf
{
	DLog(@"drawSelf");
	[self _removeAllControls];
	
	CGRect masterFrame = [BRWindow interfaceFrame];
	logFrame(masterFrame);
	
	/*
	 * Controls init
	 */
	
	DLog(@"controls init");
	
	_spinner=[[BRWaitSpinnerControl alloc]init];
	
	_cursorControl=[[BRCursorControl alloc] init];
	
	_scroller=[[BRScrollControl alloc] init];
	
	_gridControl=[[BRGridControl alloc] init];
	
	_shelfControl = [[BRMediaShelfControl alloc]init];
	
	_panelControl = [[BRPanelControl alloc]init];
	
	
	[self addControl:_scroller];
	[self addControl:_spinner];
	
	
	
	[_panelControl setFrame:masterFrame];
	[_panelControl setPanelMode:1];
	
	/* Scroller
	 * - Panel
	 *  - Spacer (44px)
	 *  - Box1 (divider + shelf)
	 *  - Box2 (divider + grid)
	 *  - Spacer
	 */
	BRSpacerControl *spacerTop=[BRSpacerControl spacerWithPixels:44.f];
	[_panelControl addControl:spacerTop];
	
	/*
	 *  Text control (recently added)
	 */
	BRDividerControl *div1=[[BRDividerControl alloc] init];
	div1.drawsLine = YES;
	[div1 setStartOffsetText:0];
	[div1 setAlignmentFactor:0.5f];
	[div1 setLabel:@"Recently added"];
	
	logFrame(div1.frame);
	
	/*
	 * Shelf
	 */
	DLog(@"shelf");
	_shelfControl = [[BRMediaShelfControl alloc] init];
	[_shelfControl setProvider:[self getProviderForShelf]];
	[_shelfControl setColumnCount:7];
	[_shelfControl setCentered:NO];
	[_shelfControl setHorizontalGap:23];
    //    [_shelfControl setCoverflowMargin:.021746988594532013];
	
	logFrame(_shelfControl.frame);
	
	DLog(@"box");
	BRBoxControl *shelfBox = [[BRBoxControl alloc] init];
	[shelfBox setAcceptsFocus:YES];
	[shelfBox setDividerSuggestedHeight:26.f];
	[shelfBox setDividerMargin:0.05f];
	[shelfBox setContent:_shelfControl];
	[shelfBox setDivider:div1];
	[shelfBox layoutSubcontrols];
	CGRect boxFrame = shelfBox.frame;
	boxFrame.size.height = 255.0f;
	[shelfBox setFrame:boxFrame];
    //shelfBox.frame.size.width = 255.f;
	[_panelControl addControl:shelfBox];
	
	
    
	
	/*
	 * Grid
	 */ 
	BRDividerControl *div2=[[BRDividerControl alloc] init];
	div2.drawsLine = YES;
	[div2 setStartOffsetText:0];
	[div2 setAlignmentFactor:0.5f];
	[div2 setLabel:@"All movies"];
	
	CGRect dividerFrame;
	dividerFrame.origin.x = 0;
	dividerFrame.origin.y = boxFrame.size.height+10.f;
	[div2 setFrame:dividerFrame];
	
	
	DLog(@"grid");
	[_gridControl setProvider:[self getProviderForGrid]];
	[_gridControl setColumnCount:6];
	[_gridControl setWrapsNavigation:YES];
	[_gridControl setHorizontalGap:0];
	[_gridControl setVerticalGap:15];
	[_gridControl setLeftMargin:0.05f];
	[_gridControl setRightMargin:0.05f];
	
	
	[_gridControl setAcceptsFocus:YES];
	[_gridControl setWrapsNavigation:YES];
	[_gridControl setProviderRequester:_gridControl];
	CGRect gridFrame;
	gridFrame.origin.y = dividerFrame.origin.y-25;
	gridFrame.size.height = [_gridControl _totalHeight] + 50.f;
	[_gridControl setFrame:gridFrame];
	
	CGRect gridBoxFrame;
	gridBoxFrame.origin.x = 0;
    //gridBoxFrame.origin.y = dividerFrame.size.height+5.f;
    //[_gridControl setFrame:gridFrame];
	
	BRBoxControl *gridBox = [[BRBoxControl alloc] init];
	[gridBox setAcceptsFocus:YES];
	[gridBox setDividerSuggestedHeight:66.f];
	[gridBox setDividerMargin:0.05f];
	[gridBox setContent:_gridControl];
	[gridBox setDivider:div2];
	[gridBox setFrame:gridFrame];
	
	
	
	[gridBox layoutSubcontrols];
	
	[_panelControl addControl:gridBox];
	
    
	
	BRSpacerControl *spacerBottom=[BRSpacerControl spacerWithPixels:44.f];
	CGRect spacerFrame;
	spacerFrame.origin.x=0;
	spacerFrame.origin.y = 0;
	spacerFrame.size.height = 44.f;
	[spacerBottom setFrame:spacerFrame];
	
	[_panelControl addControl:spacerBottom];
	[_panelControl layoutSubcontrols];
	
	[self addControl:_cursorControl];
	[_cursorControl release];
	
	[_scroller setFrame:masterFrame];
	[_scroller setFollowsFocus:YES];
	[_scroller setContent:_panelControl]; 
	[_scroller setAcceptsFocus:YES];
	
	[self layoutSubcontrols];
	
#if LOCAL_DEBUG_ENABLED
	DLog(@"drawSelf done");
#endif
	
	
}

-(id)getProviderForShelf {
#if LOCAL_DEBUG_ENABLED
	DLog(@"getProviderForShelf_start");
#endif
	NSSet *_set = [NSSet setWithObject:[BRMediaType photo]];
	NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType photo]];
	BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello" predicate:_pred mediaTypes:_set];
	
	for (int i=0;i<[_shelfAssets count];i++)
	{
		PlexPreviewAsset *asset = [_shelfAssets objectAtIndex:i];
		//DLog(@"asset_title: %@", [asset title]);
		[store addObject:asset];
		//[asset release];
	}
#if LOCAL_DEBUG_ENABLED
	DLog(@"getProviderForShelf - have assets, creating datastore and provider");
#endif
	BRPosterControlFactory *tcControlFactory = [BRPosterControlFactory factory];
	[tcControlFactory setDefaultImage:[[BRThemeInfo sharedTheme] storeRentalPlaceholderImage]];
	
	BRPhotoDataStoreProvider* provider = [BRPhotoDataStoreProvider providerWithDataStore:store 
																		  controlFactory:tcControlFactory];
	
	
#if LOCAL_DEBUG_ENABLED
	DLog(@"getProviderForShelf_end");
#endif
	[store release];
	return provider;
	
}

-(id)getProviderForGrid
{
#if LOCAL_DEBUG_ENABLED
	DLog(@"getProviderForGrid_start");
#endif
	NSSet *_set = [NSSet setWithObject:[BRMediaType photo]];
	NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType photo]];
	BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello" predicate:_pred mediaTypes:_set];
	
	for (int i=0;i<[_gridAssets count];i++)
	{
		PlexPreviewAsset *asset = (PlexPreviewAsset*)[_gridAssets objectAtIndex:i];
		
		[store addObject:asset];
	}
#if LOCAL_DEBUG_ENABLED
	DLog(@"getProviderForGrid - have assets, creating datastore and provider");
#endif
	SMFControlFactory *controlFactory = [SMFControlFactory posterControlFactory];
	controlFactory.favorProxy = YES;
	controlFactory.defaultImage = [[BRThemeInfo sharedTheme] storeRentalPlaceholderImage];
	
	BRPhotoDataStoreProvider* provider = [BRPhotoDataStoreProvider providerWithDataStore:store 
																		  controlFactory:controlFactory];
	
	
#if LOCAL_DEBUG_ENABLED
	DLog(@"getProviderForGrid_end");
#endif
	
	return provider;
}

-(BOOL)brEventAction:(BREvent *)action
{
	if ([[self stack] peekController]!=self)
		return [super brEventAction:action];
	int remoteAction = [action remoteAction];
	if (remoteAction==kBREventRemoteActionPlay && action.value==1)
	{
		int index;
		NSArray *assets;
		
		if ([_shelfControl isFocused]) {
			index = [_shelfControl focusedIndex];
			assets = _shelfAssets;
#if LOCAL_DEBUG_ENABLED
			DLog(@"item in shelf selected. assets: %d, index:%d",[assets count], index);
#endif      
		}
		
		else if ([_gridControl isFocused]) {
			index = [_gridControl _indexOfFocusedControl];
			assets = _gridAssets;
#if LOCAL_DEBUG_ENABLED
			DLog(@"item in grid selected. assets: %d, index:%d",[assets count], index);
#endif      
			
		}
		
		if (assets) {
#if LOCAL_DEBUG_ENABLED
			DLog(@"brEventaction. have %d assets and index %d, showing movie preview ctrl",[assets count], index);
#endif      
			
			HWDetailedMovieMetadataController* previewController = [[HWDetailedMovieMetadataController alloc] initWithPreviewAssets:assets withSelectedIndex:index];
			[[[BRApplicationStackManager singleton] stack] pushController:[previewController autorelease]];      
		}
		else {
			DLog(@"error: no selected asset");
		}
		
		
		return YES;
	}
	return [super brEventAction:action];
	
}


-(void)controlWasActivated
{
	DLog(@"controlWasActivated");
	[self drawSelf];
	[super controlWasActivated];
	
}

void logFrame(CGRect frame) {
	DLog(@"x:%f, y:%f - width:%f, height:%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
}

@end

  //
  //  HWMediaShelfController.m
  //  atvTwo
  //
  //  Created by bob on 2011-01-29.
  //  Copyright 2011 Band's gonna make it!. All rights reserved.
  //

#import "HWMediaShelfController.h"
#import "PlexMediaAsset.h"
#import "PlexPreviewAsset.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import "SMFramework.h"

#define LOCAL_DEBUG_ENABLED 1
#define DEFAULT_IMAGES_PATH		@"/System/Library/PrivateFrameworks/AppleTV.framework/DefaultFlowerPhotos/"

@implementation HWMediaShelfController

-(id)initWithPath:(NSString *)path
{
  return self;
}

- (id)initWithPlexContainer:(PlexMediaContainer *)container {
  
  self = [self init];
  [container retain];
#if LOCAL_DEBUG_ENABLED
  NSLog(@"initWithPlexContaner - converting to assets");
#endif
  [self convertContainerToMediaAssets:container];
  
#if LOCAL_DEBUG_ENABLED
  NSLog(@"assets converted, constructing shelf control");
#endif
  
  return self;
}  

- (void)convertContainerToMediaAssets:(PlexMediaContainer *)container {
  NSLog(@"convertContainerToMediaAssets %@", container);
  _assets = [[NSMutableArray alloc] initWithCapacity:5];
  
  for (int i=0; i < [container.directories count]; i++) {
    PlexMediaObject *mediaObj = [container.directories objectAtIndex:i];
    
    NSURL* mediaURL = [mediaObj mediaStreamURL];
    PlexPreviewAsset* pma = [[PlexPreviewAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:mediaObj];
    [_assets addObject:pma];
  }
  
#if LOCAL_DEBUG_ENABLED
  NSLog(@"converted %d assets", [_assets count]);
#endif
}

- (void) drawSelf
{
  NSLog(@"drawSelf");
  CGRect masterFrame = [BRWindow interfaceFrame];
  
  /*
   * Controls init
   */
  
  _spinner=[[BRWaitSpinnerControl alloc]init];
  _cursorControl=[[BRCursorControl alloc] init];
  _scroller=[[BRScrollControl alloc] init];
  _gridControl=[[BRGridControl alloc] init];
  _shelfControl = [[BRMediaShelfControl alloc]init];
  _panelControl = [[BRPanelControl alloc]init];
  

    //[self addControl:_scroller];
  [self addControl:_spinner];
  [_scroller setFrame:masterFrame];
  [_scroller setAcceptsFocus:YES];
  
  /*
   * Shelf
   */
  
  _shelfControl = [[BRMediaShelfControl alloc] init];
  [_shelfControl setProvider:[self getProviderForShelf]];
  [_shelfControl setColumnCount:7];
  [_shelfControl setCentered:NO];
  [_shelfControl setHorizontalGap:23];
  [_gridControl focusControlAtIndex:0];
    //    [_shelfControl setCoverflowMargin:.021746988594532013];
  CGRect gframe=CGRectMake(masterFrame.size.width*0.00, 
                           masterFrame.origin.y+masterFrame.size.height*0.72f, 
                           masterFrame.size.width*1.f,
                           masterFrame.size.height*0.24f);
  [_shelfControl setFrame:gframe];
  [self addControl:_shelfControl];
  
  BRTextControl *moviesControl =[[BRTextControl alloc] init];
  [moviesControl setText:@"Recently added" withAttributes:[[BRThemeInfo sharedTheme]metadataSummaryFieldAttributes]];
  CGRect mf;
  mf.size = [moviesControl renderedSize];
  mf.origin.x=gframe.origin.x+masterFrame.size.width*0.05;
  mf.origin.y=gframe.origin.y+gframe.size.height+masterFrame.size.height*0.005f,
  [moviesControl setFrame:mf];
  [self addControl:moviesControl];
  [moviesControl release];
  
  /*
   *  First Divider
   */
  BRDividerControl *div1 = [[BRDividerControl alloc]init];
  CGRect div1Frame = CGRectMake(mf.origin.x+mf.size.width+5.f , 
                                mf.origin.y-3.f, 
                                masterFrame.size.width*0.74f, 
                                masterFrame.size.height*0.02f);
  [div1 setFrame:div1Frame];
  [self addControl:div1];
  [div1 release];
  
  
  /*
   * Grid
   */  
  NSLog(@"grid");
  [_gridControl setProvider:[self getProviderForGrid]];
  [_gridControl setColumnCount:7];
  [_gridControl setWrapsNavigation:YES];
  [_gridControl setHorizontalGap:0];
  [_gridControl setVerticalGap:23];
  [_gridControl setLeftMargin:0.05f];
  [_gridControl setRightMargin:0.05f];
  [_gridControl setAccessibilityLabel:@"All movies"];
  
  CGRect frame;
  frame.origin.x = 0;
  frame.origin.y = 0;
  
  frame.size.width = masterFrame.size.width;
	frame.size.height = 500;//masterFrame.size.height*2.f;
	[_gridControl setAcceptsFocus:YES];
  [_gridControl setWrapsNavigation:YES];
  [_gridControl setProviderRequester:_gridControl];//[NSNotificationCenter defaultCenter]];
  
  [_gridControl setFrame:frame];
    //[_gridControl focusControlAtIndex:0];

  [self addControl:_gridControl];
  
  
  
  
  
  
  
  
  
  [self addControl:_cursorControl];
  [_cursorControl release];
 /* 
  [_scroller setFollowsFocus:YES];
  [_scroller setContent:_panelControl];  
  [self layoutSubcontrols];
   */ 
  
  
}

-(id)getProviderForShelf {
#if LOCAL_DEBUG_ENABLED
  NSLog(@"getProviderForShelf_start");
#endif
  NSSet *_set = [NSSet setWithObject:[BRMediaType photo]];
  NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType photo]];
  BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello" predicate:_pred mediaTypes:_set];
  
  for (int i=0;i<[_assets count];i++)
  {
    PlexPreviewAsset *asset = [_assets objectAtIndex:i];
    NSLog(@"asset_title: %@", [asset title]);
    [store addObject:asset];
      //[asset release];
  }
#if LOCAL_DEBUG_ENABLED
  NSLog(@"getProviderForShelf - have assets, creating datastore and provider");
#endif

  BRPhotoDataStoreProvider* provider = [BRPhotoDataStoreProvider providerWithDataStore:store 
                                                                            controlFactory:[BRPosterControlFactory factory]];
  
  
#if LOCAL_DEBUG_ENABLED
  NSLog(@"getProviderForShelf_end");
#endif
  [store release];
  return provider;
  
}

-(id)getProviderForGrid
{
#if LOCAL_DEBUG_ENABLED
  NSLog(@"getProviderForGrid_start");
#endif
  NSSet *_set = [NSSet setWithObject:[BRMediaType movie]];
  NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType movie]];
  BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello" predicate:_pred mediaTypes:_set];
  
  for (int i=0;i<[_assets count];i++)
  {
    PlexPreviewAsset *asset = (PlexPreviewAsset*)[_assets objectAtIndex:i];

    [store addObject:asset];
  }
#if LOCAL_DEBUG_ENABLED
  NSLog(@"getProviderForGrid - have assets, creating datastore and provider");
#endif

  BRDataStoreProvider* provider = [BRDataStoreProvider providerWithDataStore:store 
                                                                            controlFactory:[BRPhotoControlFactory standardFactory]];

  
#if LOCAL_DEBUG_ENABLED
  NSLog(@"getProviderForGrid_end");
#endif
  
  return provider;
}


-(void)controlWasActivated
{
  NSLog(@"controlWasActivated");
	[self drawSelf];
  [super controlWasActivated];
	
}

@end

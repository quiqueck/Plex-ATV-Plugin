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
#import "SMFramework/SMFControlFactory.h"

#define LOCAL_DEBUG_ENABLED 1

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
  
  
  [self addControl:_scroller];
  [self addControl:_spinner];
  
  [_panelControl setFrame:masterFrame];
  [_panelControl setPanelMode:1];
  
  
  /*
   * Shelf
   */
  
  _shelfControl = [[BRMediaShelfControl alloc] init];
  [_shelfControl setProvider:[self getProviderForShelf]];
  [_shelfControl setColumnCount:7];
  [_shelfControl setCentered:NO];
  [_shelfControl setHorizontalGap:23];
    //    [_shelfControl setCoverflowMargin:.021746988594532013];
  CGRect gframe=CGRectMake(0, 
                           masterFrame.origin.y+masterFrame.size.height*0.90f, 
                           masterFrame.size.width*1.f,
                           masterFrame.size.height*0.24f);
  [_shelfControl setFrame:gframe];
  [_panelControl addControl:_shelfControl];
  
  BRTextControl *recentlyAddedTextCtrl =[[BRTextControl alloc] init];
  [recentlyAddedTextCtrl setText:@"Recently added" withAttributes:[[BRThemeInfo sharedTheme]metadataSummaryFieldAttributes]];
  CGRect recentlyAddedTextFrame;
  recentlyAddedTextFrame.size = [recentlyAddedTextCtrl renderedSize];
  recentlyAddedTextFrame.origin.x=gframe.origin.x+masterFrame.size.width*0.05;
  recentlyAddedTextFrame.origin.y=gframe.origin.y+gframe.size.height+5.f,
  [recentlyAddedTextCtrl setFrame:recentlyAddedTextFrame];
  [_panelControl addControl:recentlyAddedTextCtrl];
  [recentlyAddedTextCtrl release];
  
  /*
   *  First Divider
   */
  BRDividerControl *div1 = [[BRDividerControl alloc]init];
  CGRect div1Frame = CGRectMake(recentlyAddedTextFrame.origin.x+recentlyAddedTextFrame.size.width+10.f , 
                                recentlyAddedTextFrame.origin.y+7.f, 
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
  [_gridControl setVerticalGap:5];
  [_gridControl setLeftMargin:0.05f];
  [_gridControl setRightMargin:0.05f];
  [_gridControl setAccessibilityLabel:@"All movies"];
  
  CGRect gridFrame;
  gridFrame.origin.x = 0;
  gridFrame.origin.y = 0;
  
  gridFrame.size.width = masterFrame.size.width;
	gridFrame.size.height = masterFrame.size.height-gframe.size.height;
	[_gridControl setAcceptsFocus:YES];
  [_gridControl setWrapsNavigation:YES];
  [_gridControl setProviderRequester:_gridControl];//[NSNotificationCenter defaultCenter]];
  
  [_gridControl setFrame:gridFrame];
    //[_gridControl focusControlAtIndex:0];
  
  [_panelControl addControl:_gridControl];
  
  
  BRTextControl *allMoviesCtrl =[[BRTextControl alloc] init];
  [allMoviesCtrl setText:@"All movies" withAttributes:[[BRThemeInfo sharedTheme]metadataSummaryFieldAttributes]];
  CGRect allMoviesRect;
  allMoviesRect.size = [allMoviesCtrl renderedSize];
  allMoviesRect.origin.x=gridFrame.origin.x+masterFrame.size.width*0.05;
  allMoviesRect.origin.y=gridFrame.origin.y+gridFrame.size.height+8.f,
  [allMoviesCtrl setFrame:allMoviesRect];
  [_panelControl addControl:allMoviesCtrl];
  [allMoviesCtrl release];
  
  /*
   *  Second Divider
   */
  BRDividerControl *div2 = [[BRDividerControl alloc]init];
  CGRect div2Frame = CGRectMake(allMoviesRect.origin.x+allMoviesRect.size.width+10.f , 
                                allMoviesRect.origin.y+7.f, 
                                masterFrame.size.width*0.74f, 
                                masterFrame.size.height*0.02f);
  [div2 setFrame:div2Frame];
  [_panelControl addControl:div2];
  [div2 release];
  
  
  
  
  
  
  [self addControl:_cursorControl];
  [_cursorControl release];
  
  [_scroller setFrame:masterFrame];
  [_scroller setFollowsFocus:YES];
  [_scroller setContent:_panelControl]; 
  [_scroller setAcceptsFocus:YES];
  
    //[_panelControl addControl:_scroller];
  [_panelControl layoutSubcontrols];
  [self layoutSubcontrols];
  
  
  
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
  
  BRPhotoDataStoreProvider* provider = [BRPhotoDataStoreProvider providerWithDataStore:store 
                                                                        controlFactory:[SMFPhotoControlFactory posterControlFactory]];
  
  
#if LOCAL_DEBUG_ENABLED
  NSLog(@"getProviderForGrid_end");
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
    SMFMoviePreviewController* previewController = [[SMFMoviePreviewController alloc] init];
    PlexPreviewAsset *prevAsset = [_assets objectAtIndex:0];
    HWMovieListing *dataSource = [[HWMovieListing alloc] initWithRootContainer: [prevAsset.pmo contents]];
    previewController.datasource = dataSource;
    
    [[[BRApplicationStackManager singleton] stack] pushController:previewController];
    [previewController autorelease];
    return YES;
  }
  return [super brEventAction:action];
  
}


-(void)controlWasActivated
{
  NSLog(@"controlWasActivated");
	[self drawSelf];
  [super controlWasActivated];
	
}

@end

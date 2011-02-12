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
#import "HWDetailedMovieMetadataController.h"

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
  [self _removeAllControls];
  
  CGRect masterFrame = [BRWindow interfaceFrame];
  logFrame(masterFrame);
  
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
  
  /* Scroller
   * - Panel
   *  - Spacer (44px)
   *  - Box1 (divider+shelf)
   *  - Box2
   *  - Grid?
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
  NSLog(@"shelf");
  _shelfControl = [[BRMediaShelfControl alloc] init];
  [_shelfControl setProvider:[self getProviderForShelf]];
  [_shelfControl setColumnCount:7];
  [_shelfControl setCentered:NO];
  [_shelfControl setHorizontalGap:23];
    //    [_shelfControl setCoverflowMargin:.021746988594532013];

  logFrame(_shelfControl.frame);
  
  NSLog(@"box");
  BRBoxControl *shelfBox = [[BRBoxControl alloc] init];
  [shelfBox setAcceptsFocus:YES];
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
  
  
  NSLog(@"grid");
  [_gridControl setProvider:[self getProviderForGrid]];
  [_gridControl setColumnCount:7];
  [_gridControl setWrapsNavigation:YES];
  [_gridControl setHorizontalGap:0];
  [_gridControl setVerticalGap:5];
  [_gridControl setLeftMargin:0.05f];
  [_gridControl setRightMargin:0.05f];
  

	[_gridControl setAcceptsFocus:YES];
  [_gridControl setWrapsNavigation:YES];
  [_gridControl setProviderRequester:_gridControl];
  CGRect gridFrame;
  gridFrame.size.height = 5000.f;
  [_gridControl setFrame:gridFrame];
  
  CGRect gridBoxFrame;
  gridBoxFrame.origin.x = 0;
    //gridBoxFrame.origin.y = dividerFrame.size.height+5.f;
    //[_gridControl setFrame:gridFrame];
  
  BRBoxControl *gridBox = [[BRBoxControl alloc] init];
  [gridBox setAcceptsFocus:YES];
  [gridBox setDividerSuggestedHeight:46.f];
  [gridBox setDividerMargin:0.05f];
  [gridBox setContent:_gridControl];
  [gridBox setDivider:div2];
  [gridBox setFrame:gridFrame];
  


  [gridBox layoutSubcontrols];
  
  [_panelControl addControl:gridBox];
  
  /*
  NSLog(@"txt-ctrl: all movies");
  
  BRTextControl *allMoviesCtrl =[[BRTextControl alloc] init];
  [allMoviesCtrl setText:@"All movies" withAttributes:[[BRThemeInfo sharedTheme]metadataSummaryFieldAttributes]];
  CGRect allMoviesFrame;
  allMoviesFrame.size = [allMoviesCtrl renderedSize];
  allMoviesFrame.origin.x=gridFrame.origin.x;
  allMoviesFrame.origin.y=gridFrame.origin.y+gridFrame.size.height+8.f;
  
  logFrame(allMoviesFrame);
  [allMoviesCtrl setFrame:allMoviesFrame];
    //[_panelControl addControl:allMoviesCtrl];
  [allMoviesCtrl release];
  
  
  /*
   *  Second Divider
   
  NSLog(@"second divider");
  BRDividerControl *div2 = [[BRDividerControl alloc]init];
  CGRect div2Frame = CGRectMake(allMoviesFrame.origin.x+allMoviesFrame.size.width+10.f , 
                                allMoviesFrame.origin.y+7.f, 
                                masterFrame.size.width*0.74f, 
                                masterFrame.size.height*0.02f);
  logFrame(div2Frame);
  [div2 setFrame:div2Frame];
    //[_panelControl addControl:div2];
  [div2 release];
  
  
  */
  
  
  BRSpacerControl *spacerBottom=[BRSpacerControl spacerWithPixels:44.f];
  [_panelControl addControl:spacerBottom];
  
  [_panelControl layoutSubcontrols];
  
  [self addControl:_cursorControl];
  [_cursorControl release];
  
  [_scroller setFrame:masterFrame];
  [_scroller setFollowsFocus:YES];
  [_scroller setContent:_panelControl]; 
  [_scroller setAcceptsFocus:YES];
  
    //[_panelControl addControl:_scroller];
    //[_panelControl layoutSubcontrols];
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
      //NSLog(@"asset_title: %@", [asset title]);
    [store addObject:asset];
      //[asset release];
  }
#if LOCAL_DEBUG_ENABLED
  NSLog(@"getProviderForShelf - have assets, creating datastore and provider");
#endif
  BRPosterControlFactory *tcControlFactory = [BRPosterControlFactory factory];
	[tcControlFactory setDefaultImage:[[BRThemeInfo sharedTheme] storeRentalPlaceholderImage]];
  
  BRPhotoDataStoreProvider* provider = [BRPhotoDataStoreProvider providerWithDataStore:store 
                                                                        controlFactory:tcControlFactory];
  
  
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
  NSSet *_set = [NSSet setWithObject:[BRMediaType photo]];
  NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType photo]];
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
    int index;
    if ([_shelfControl isFocused])
      index = [_shelfControl focusedIndex];
    else if ([_gridControl isFocused])
      index = [_gridControl _indexOfFocusedControl];      

    PlexPreviewAsset *selectedAsset = [_assets objectAtIndex:index];
    NSLog(@"title: %@",selectedAsset.title);

	  HWDetailedMovieMetadataController* previewController = [[HWDetailedMovieMetadataController alloc] initWithPreviewAssets:_assets withSelectedIndex:index];
    [[[BRApplicationStackManager singleton] stack] pushController:[previewController autorelease]];
    
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

void logFrame(CGRect frame) {
  NSLog(@"x:%f, y:%f - width:%f, height:%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
}

@end

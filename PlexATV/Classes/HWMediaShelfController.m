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

#define LOCAL_DEBUG_ENABLED 1

@implementation HWMediaShelfController

@synthesize _assets;

- (id) init
{
	if((self = [super init]) != nil) {
    return self;
	}
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
  
  CGRect masterFrame = self.frame;
  masterFrame.size.width = 1280;
  masterFrame.size.height = 720;
  NSLog(@"%@",NSStringFromRect(masterFrame));
  /*
    _shelfControl = [[BRMediaShelfControl alloc] init];
    [_shelfControl setProvider:[self getProviderForGrid]];
    [_shelfControl setColumnCount:7];
    [_shelfControl setCentered:NO];
    [_shelfControl layoutSubcontrols];
  */
  
  BRGridControl *_trustedGrid = [[BRGridControl alloc]init];
  [_trustedGrid setColumnCount:7];
  [_trustedGrid setHorizontalGap:0.01f];
    ////    [_trustedGrid setVerticalGap:10];
  [_trustedGrid setProviderRequester:_trustedGrid];
  [_trustedGrid setProvider:[self getProviderForGrid]];
  [_trustedGrid setAcceptsFocus:YES];
  [_trustedGrid setWrapsNavigation:YES];
  [_trustedGrid setTopMargin:0.3f];
    //[_trustedGrid setHorizontalMargins:0.4f];
  CGRect gframe;
  gframe.origin.x=masterFrame.origin.x;//+masterFrame.size.width*0.05f;
  gframe.origin.y=masterFrame.origin.y+masterFrame.size.height*0.04f;
  gframe.size.width=masterFrame.size.width*0.9f;
  gframe.size.height=masterFrame.size.height*0.15f;
    //[_shelfControl setFrame:gframe];
  NSLog(@"gFrame width: %f", masterFrame.size.width);
  NSLog(@"gFrame height: %f", masterFrame.size.height);
  [_trustedGrid setFrame:[self frame]];
  [_trustedGrid layoutSubcontrols];
  NSLog(@"data Count: %i",[_trustedGrid dataCount]);
  
    //[_trustedGrid sizeToFit];
   
   
    //NSLog(@"data Count: %i",[_shelfControl dataCount]);
    //[_shelfControl setFrame:masterFrame];
    //NSLog(@"gFrame width: %f", masterFrame.size.width);
  [self addControl:_trustedGrid];
  
#if LOCAL_DEBUG_ENABLED
  NSLog(@"controls in me: %@",[self controls]);
#endif
  
  [container autorelease];
  
  return self;
  
}

- (void)convertContainerToMediaAssets:(PlexMediaContainer *)container {
  NSLog(@"convertContainerToMediaAssets %@", container);
  self._assets = [[NSMutableArray alloc] initWithCapacity:5];
  
  for (int i=0; i < [container.directories count]; i++) {
    PlexMediaObject *mediaObj = [container.directories objectAtIndex:i];
    
    NSURL* mediaURL = [mediaObj mediaStreamURL];
    PlexPreviewAsset* pma = [[PlexPreviewAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:mediaObj];
    [self._assets addObject:pma];
  }
  
#if LOCAL_DEBUG_ENABLED
  NSLog(@"converted %d assets", [self._assets count]);
#endif
}

-(void)dealloc
{
	[_assets release];
	[_shelfControl release];
	[super dealloc];
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
    [store addObject:[_assets objectAtIndex:i]];
  }
#if LOCAL_DEBUG_ENABLED
  NSLog(@"getProviderForGrid - have assets, creating datastore and provider");
#endif
  id dSPfCClass = NSClassFromString(@"BRDataStoreProvider");
  id tcControlFactory = [BRMediaPreviewControlFactory factory];
  id provider = [dSPfCClass providerWithDataStore:store controlFactory:tcControlFactory];
  
#if LOCAL_DEBUG_ENABLED
  NSLog(@"getProviderForGrid_end");
#endif
  
  return provider;
}





- (void)wasPushed{
	NSLog(@"--- Did push controller %@", self);
	
	[super wasPushed];
}

- (void)wasPopped{
	NSLog(@"--- Did pop controller %@", self);
	
	[super wasPopped];
}



- (id)previewControlForItem:(long)item

{
  return nil;
}

- (BOOL)shouldRefreshForUpdateToObject:(id)object{
	return YES;
}

- (void)itemSelected:(long)selected {
}

- (float)heightForRow:(long)row {
	return 50.0f;
}

- (long)itemCount {
	return _assets.count;
}

- (id)itemForRow:(long)row {
  return nil;
}

- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (id)titleForRow:(long)row {
  return nil;
}

-(void)setNeedsUpdate{
	NSLog(@"Updating UI");
}


@end

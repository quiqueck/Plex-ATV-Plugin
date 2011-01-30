//
//  HWMediaShelfController.h
//  atvTwo
//
//  Created by bob on 2011-01-29.
//  Copyright 2011 Band's gonna make it!. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlexMediaContainer;

@interface HWMediaShelfController : BRController {
	NSMutableArray	*_assets;
  BRMediaShelfControl *_shelfControl;
	
}
@property (nonatomic, retain) NSMutableArray *_assets;

  //our own stuff
- (id)initWithPlexContainer:(PlexMediaContainer *)container;
- (id)getProviderForGrid;
- (void)convertContainerToMediaAssets:(PlexMediaContainer *)container;

@end

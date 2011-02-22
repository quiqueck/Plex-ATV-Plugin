//
//  HWMediaShelfController.h
//  atvTwo
//
//  Created by bob on 2011-01-29.
//  Copyright 2011 Band's gonna make it!. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlexMediaContainer;

@interface HWMediaGridController : BRController {
  NSArray	*_shelfAssets;
  NSArray	*_gridAssets;
  BRGridControl*          _gridControl;
  BRMediaShelfControl*    _shelfControl;
  BRWaitSpinnerControl *  _spinner;
  BRCursorControl *       _cursorControl;
  BRScrollControl *       _scroller;
  BRPanelControl *        _panelControl;
}
-(void)drawSelf;
- (id)getProviderForGrid;
-(id)getProviderForShelf;
  //our own stuff
- (id)initWithPlexAllMovies:(PlexMediaContainer *)allMovies andRecentMovies:(PlexMediaContainer *)recentMovies;
- (NSArray *)convertContainerToMediaAssets:(PlexMediaContainer *)container;

@end

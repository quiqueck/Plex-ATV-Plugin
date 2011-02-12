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
- (id)initWithPlexContainer:(PlexMediaContainer *)container;
- (void)convertContainerToMediaAssets:(PlexMediaContainer *)container;

@end

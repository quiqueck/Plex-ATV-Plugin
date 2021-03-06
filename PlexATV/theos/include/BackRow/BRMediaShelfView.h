/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BackRow-Structs.h"
#import "BRControl.h"

@class NSMutableArray, NSTimer, NSDictionary, NSIndexPath;

@interface BRMediaShelfView : BRControl {
@private
	id _dataSource;	// 40 = 0x28
	id _delegate;	// 44 = 0x2c
	NSDictionary *_controlActions;	// 48 = 0x30
	NSDictionary *_titleActions;	// 52 = 0x34
	BOOL _centered;	// 56 = 0x38
	BOOL _scrollable;	// 57 = 0x39
	NSIndexPath *_lastFocusedIndexPath;	// 60 = 0x3c
	BOOL _restoresFocus;	// 64 = 0x40
	NSRange _flatRange;	// 68 = 0x44
	CATransform3D _leftTransform;	// 76 = 0x4c
	CATransform3D _rightTransform;	// 140 = 0x8c
	NSMutableArray *_cells;	// 204 = 0xcc
	NSMutableArray *_titles;	// 208 = 0xd0
	NSTimer *_scrollTimer;	// 212 = 0xd4
	BOOL _scrolling;	// 216 = 0xd8
	int _collapsedState;	// 220 = 0xdc
	BOOL _ordered;	// 224 = 0xe0
	BOOL _needToReloadDataOnActivate;	// 225 = 0xe1
}
@property(assign) BOOL centered;	// G=0x32e48a6d; S=0x32e4a2a9; converted property
@property(assign) int collapsedState;	// G=0x32e48a9d; S=0x32e49b85; converted property
@property(retain) id dataSource;	// G=0x32e48a2d; S=0x32e4a38d; converted property
@property(assign) id delegate;	// G=0x32e48a4d; S=0x32e48a3d; converted property
@property(retain) id focusedIndexPath;	// G=0x32e49e75; S=0x32e49c4d; converted property
@property(assign) BOOL ordered;	// G=0x32e48a7d; S=0x32e4a281; converted property
@property(assign) BOOL restoresFocus;	// G=0x32e48a8d; S=0x32e49bc1; converted property
@property(assign) BOOL scrollable;	// G=0x32e48a5d; S=0x32e4a2d1; converted property
- (id)init;	// 0x32e4a5d5
- (long)_columnCount;	// 0x32e49a7d
- (id)_controlActions;	// 0x32e49181
- (float)_coverflowMargin;	// 0x32e4998d
- (id)_currentCellAtIndex:(int)index;	// 0x32e49781
- (NSRange)_dividedRangeForRange:(NSRange)range andDirection:(int)direction;	// 0x32e4b005
- (unsigned)_dividerCountInRange:(NSRange)range;	// 0x32e49141
- (unsigned)_firstScrollableIndex;	// 0x32e48aad
- (void)_focusChanged:(id)changed;	// 0x32e496b9
- (float)_horizontalGap;	// 0x32e49a2d
- (long)_indexFromIndexPath:(id)indexPath;	// 0x32e48d51
- (id)_indexPathFromIndex:(long)index sectionIndex:(long *)index2;	// 0x32e48c55
- (BOOL)_isDividerAtIndex:(long)index;	// 0x32e490b5
- (unsigned)_lastScrollableIndex;	// 0x32e4abc9
- (void)_layoutShelfContents;	// 0x32e4b1c5
- (BOOL)_leftButtonEvent;	// 0x32e4954d
- (void)_loadControlAtIndex:(int)index;	// 0x32e498b9
- (id)_newControlAtIndex:(int)index;	// 0x32e497c5
- (unsigned)_nextFocusableIndexInDirection:(int)direction;	// 0x32e495fd
- (void)_purgeControlAtIndex:(int)index;	// 0x32e496cd
- (void)_purgeControls;	// 0x32e49aa5
- (void)_refillShelf;	// 0x32e4a901
- (void)_reloadTitles;	// 0x32e48f99
- (void)_removeSectionHeaderTitleControls;	// 0x32e48df1
- (void)_restoreLastSelection;	// 0x32e49355
- (BOOL)_rightButtonEvent;	// 0x32e495a5
- (void)_saveCurrentSelection;	// 0x32e49391
- (BOOL)_scrollInDirection:(int)direction;	// 0x32e4ac05
- (BOOL)_scrollIndexToVisible:(long)visible;	// 0x32e4afd1
- (BOOL)_scrollLeft;	// 0x32e49519
- (BOOL)_scrollRight;	// 0x32e49535
- (long)_sectionIndexForIndex:(long)index;	// 0x32e48ba1
- (void)_setDimness:(float)dimness forLayer:(id)layer;	// 0x32e4a7dd
- (id)_titleActions;	// 0x32e48e89
- (void)_updateFocusAcceptanceAtIndex:(int)index;	// 0x32e4b129
- (void)_updateSublayerTransform;	// 0x32e4941d
- (int)_visibleFlowCellCount;	// 0x32e48abd
- (NSRange)_visibleRange;	// 0x32e4af65
- (id)accessibilityLabel;	// 0x32e48aed
- (BOOL)brEventAction:(id)action;	// 0x32e49ef1
// converted property getter: - (BOOL)centered;	// 0x32e48a6d
// converted property getter: - (int)collapsedState;	// 0x32e48a9d
- (void)controlWasActivated;	// 0x32e4a481
- (void)controlWasFocused;	// 0x32e4a4c9
- (long)dataCount;	// 0x32e4a30d
// converted property getter: - (id)dataSource;	// 0x32e48a2d
- (void)dealloc;	// 0x32e4a51d
// converted property getter: - (id)delegate;	// 0x32e48a4d
- (id)focusedControlForEvent:(id)event focusPoint:(CGPoint *)point;	// 0x32e49aed
// converted property getter: - (id)focusedIndexPath;	// 0x32e49e75
- (id)initialFocus;	// 0x32e48ac1
- (void)layoutSubcontrols;	// 0x32e4a705
// converted property getter: - (BOOL)ordered;	// 0x32e48a7d
- (void)reloadData;	// 0x32e4a42d
// converted property getter: - (BOOL)restoresFocus;	// 0x32e48a8d
// converted property getter: - (BOOL)scrollable;	// 0x32e48a5d
- (id)selectedControl;	// 0x32e49bad
// converted property setter: - (void)setCentered:(BOOL)centered;	// 0x32e4a2a9
// converted property setter: - (void)setCollapsedState:(int)state;	// 0x32e49b85
// converted property setter: - (void)setDataSource:(id)source;	// 0x32e4a38d
// converted property setter: - (void)setDelegate:(id)delegate;	// 0x32e48a3d
// converted property setter: - (void)setFocusedIndexPath:(id)path;	// 0x32e49c4d
// converted property setter: - (void)setOrdered:(BOOL)ordered;	// 0x32e4a281
// converted property setter: - (void)setRestoresFocus:(BOOL)focus;	// 0x32e49bc1
// converted property setter: - (void)setScrollable:(BOOL)scrollable;	// 0x32e4a2d1
- (void)visibleScrollRectChanged;	// 0x32e492f1
@end


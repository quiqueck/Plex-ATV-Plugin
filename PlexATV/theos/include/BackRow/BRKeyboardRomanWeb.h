/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BackRow-Structs.h"
#import "BRKeyboardRomanFull.h"

@class BRImageControl, BRButtonControl;

__attribute__((visibility("hidden")))
@interface BRKeyboardRomanWeb : BRKeyboardRomanFull {
@private
	BRButtonControl *_previousButton;	// 32 = 0x20
	BRButtonControl *_nextButton;	// 36 = 0x24
	BRButtonControl *_autoFillButton;	// 40 = 0x28
	BRButtonControl *_clearButton;	// 44 = 0x2c
	BRImageControl *_rowDividerImageControl;	// 48 = 0x30
}
- (float)_actionKeysContainerBaseGap:(id)gap resolutionScale:(float)scale;	// 0x32e2c541
- (CGSize)_actionKeysContainerSize:(id)size resolutionScale:(float)scale;	// 0x32e2c55d
- (void)_autoFillButtonClick:(id)click;	// 0x32e2b629
- (void)_generateKeyEventWithCharacters:(id)characters;	// 0x32e2c731
- (id)_keyboardDataFileName;	// 0x32e2bb71
- (id)_mainKeyRowWithKeys:(id)keys index:(int)index;	// 0x32e2b6b5
- (float)_mainKeysContainerBaseGap:(id)gap resolutionScale:(float)scale;	// 0x32e2c599
- (CGSize)_mainKeysContainerSize:(id)size resolutionScale:(float)scale;	// 0x32e2c6d5
- (CGSize)_minTextEntryControlSize:(id)size resolutionScale:(float)scale;	// 0x32e2c5d5
- (void)_nextButtonClick:(id)click;	// 0x32e2b62d
- (int)_numberOfColumnsForMainKeyRowIndex:(int)mainKeyRowIndex;	// 0x32e2b611
- (int)_numberOfMainKeyRows;	// 0x32e2b60d
- (void)_prevousButtonClick:(id)click;	// 0x32e2b671
- (float)_topMostUIElementGap:(id)gap resolutionScale:(float)scale;	// 0x32e2c5b5
- (id)actionDictionaryForCustomControl:(id)customControl;	// 0x32e2b735
- (id)actionKeyRows;	// 0x32e2ba31
- (id)actionKeysContainer;	// 0x32e2b869
- (id)bottomRow;	// 0x32e2b5f9
- (BOOL)canWrapVertically;	// 0x32e2b609
- (id)customizeTextEntryControls:(id)controls;	// 0x32e2bb89
- (void)dealloc;	// 0x32e2bae1
- (id)focusedControlAndRow:(id *)row;	// 0x32e2ba61
- (void)layoutCustomControls:(id)controls resolutionScale:(float)scale;	// 0x32e2c2a9
- (id)name;	// 0x32e2b5ed
- (BOOL)popupKeyboardShouldBeRightAlignedForKey:(id)popupKeyboard;	// 0x32e2b795
- (id)removeCustomizedTextEntryControls:(id)controls;	// 0x32e2b989
@end


/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BRImageControl.h"

@class BRImage;

@interface BRFocusableImageControl : BRImageControl {
@private
	BRImage *_focusedImage;	// 64 = 0x40
	BRImage *_unfocusedImage;	// 68 = 0x44
	BRImage *_disabledImage;	// 72 = 0x48
	BOOL _dimsWhenDisabled;	// 76 = 0x4c
	BOOL _disabled;	// 77 = 0x4d
}
@property(assign) BOOL dimsWhenDisabled;	// G=0x32db8299; S=0x32db8345; converted property
@property(assign) BOOL disabled;	// G=0x32db8279; S=0x32db83b5; converted property
@property(retain) BRImage *disabledImage;	// G=0x32db8289; S=0x32db836d; converted property
@property(retain) BRImage *focusedImage;	// G=0x32d8966d; S=0x32d88ce9; converted property
@property(retain) BRImage *unfocusedImage;	// G=0x32d88d31; S=0x32d88d65; converted property
- (void)_updateDim;	// 0x32db846d
- (void)_updateImage;	// 0x32db82a9
- (void)controlWasFocused;	// 0x32d89619
- (void)controlWasUnfocused;	// 0x32d8967d
- (void)dealloc;	// 0x32d895ad
// converted property getter: - (BOOL)dimsWhenDisabled;	// 0x32db8299
// converted property getter: - (BOOL)disabled;	// 0x32db8279
// converted property getter: - (id)disabledImage;	// 0x32db8289
// converted property getter: - (id)focusedImage;	// 0x32d8966d
- (id)preferredActionForKey:(id)key;	// 0x32db83e5
// converted property setter: - (void)setDimsWhenDisabled:(BOOL)disabled;	// 0x32db8345
// converted property setter: - (void)setDisabled:(BOOL)disabled;	// 0x32db83b5
// converted property setter: - (void)setDisabledImage:(id)image;	// 0x32db836d
// converted property setter: - (void)setFocusedImage:(id)image;	// 0x32d88ce9
// converted property setter: - (void)setUnfocusedImage:(id)image;	// 0x32d88d65
// converted property getter: - (id)unfocusedImage;	// 0x32d88d31
@end


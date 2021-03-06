/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BackRow-Structs.h"
#import "BRControl.h"

@class BRDividerControl, BRImageControl, BRTextControl, NSString;

__attribute__((visibility("hidden")))
@interface BRPhotoBrowserHeaderControl : BRControl {
@private
	BRTextControl *_titleControl;	// 40 = 0x28
	BRTextControl *_subtitleControl;	// 44 = 0x2c
	BRImageControl *_icon;	// 48 = 0x30
	BRDividerControl *_divider;	// 52 = 0x34
	NSString *_title;	// 56 = 0x38
	long _count;	// 60 = 0x3c
	BOOL _displaysCount;	// 64 = 0x40
	float _iconVerticalOffset;	// 68 = 0x44
}
@property(assign) long count;	// G=0x32e2e665; S=0x32e2e7b1; converted property
@property(assign) BOOL displaysCount;	// G=0x32e2e675; S=0x32e2e77d; converted property
@property(assign) float dividerBrightness;	// G=0x32e2e695; S=0x32e2e6b5; converted property
@property(retain) BRImageControl *icon;	// G=0x32e2e6f9; S=0x32e2e719; converted property
@property(assign) float iconVerticalOffset;	// G=0x32e2e685; S=0x32e2e6d5; converted property
@property(retain) id subtitle;	// G=0x32e2e74d; S=0x32e2eb7d; converted property
@property(retain) NSString *title;	// G=0x32e2e655; S=0x32e2e9f1; converted property
- (id)init;	// 0x32e2e8b5
// converted property getter: - (long)count;	// 0x32e2e665
- (void)dealloc;	// 0x32e2e835
// converted property getter: - (BOOL)displaysCount;	// 0x32e2e675
// converted property getter: - (float)dividerBrightness;	// 0x32e2e695
// converted property getter: - (id)icon;	// 0x32e2e6f9
// converted property getter: - (float)iconVerticalOffset;	// 0x32e2e685
- (void)layoutSubcontrols;	// 0x32e2ec95
- (id)photoBrowserHeader;	// 0x32e2e7f5
// converted property setter: - (void)setCount:(long)count;	// 0x32e2e7b1
// converted property setter: - (void)setDisplaysCount:(BOOL)count;	// 0x32e2e77d
// converted property setter: - (void)setDividerBrightness:(float)brightness;	// 0x32e2e6b5
// converted property setter: - (void)setIcon:(id)icon;	// 0x32e2e719
// converted property setter: - (void)setIconVerticalOffset:(float)offset;	// 0x32e2e6d5
// converted property setter: - (void)setSubtitle:(id)subtitle;	// 0x32e2eb7d
// converted property setter: - (void)setTitle:(id)title;	// 0x32e2e9f1
- (CGSize)sizeThatFits:(CGSize)fits;	// 0x32e2ebd5
// converted property getter: - (id)subtitle;	// 0x32e2e74d
// converted property getter: - (id)title;	// 0x32e2e655
@end


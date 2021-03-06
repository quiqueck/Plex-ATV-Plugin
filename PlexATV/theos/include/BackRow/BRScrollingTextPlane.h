/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BackRow-Structs.h"
#import "BRControl.h"

@class NSAttributedString;

__attribute__((visibility("hidden")))
@interface BRScrollingTextPlane : BRControl {
@private
	NSAttributedString *_string;	// 40 = 0x28
	float _pursuitGap;	// 44 = 0x2c
	CGSize _cachedNaturalTextSize;	// 48 = 0x30
}
@property(retain) id attributedString;	// G=0x32dbe40d; S=0x32dbeab1; converted property
+ (Class)layerClass;	// 0x32dbeb35
// converted property getter: - (id)attributedString;	// 0x32dbe40d
- (void)dealloc;	// 0x32dbee25
- (void)drawInContext:(CGContextRef)context;	// 0x32dbf351
- (CGSize)naturalTextSize;	// 0x32dbf44d
// converted property setter: - (void)setAttributedString:(id)string;	// 0x32dbeab1
- (void)setPursuitGap:(float)gap;	// 0x32dbea7d
- (void)setTileSize:(CGSize)size;	// 0x32dbea51
@end


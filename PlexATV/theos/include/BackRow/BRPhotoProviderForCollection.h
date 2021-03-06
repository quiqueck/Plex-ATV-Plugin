/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BRPhotoProvider.h"
#import "BRProvider.h"
#import "BRPhotoProviderForCollection.h"

@class BRPhotoMediaCollection, NSArray;

@protocol BRPhotoProviderForCollection <BRProvider>
@property(assign) BOOL vendPhotoDataOnly;	// converted property
- (BOOL)canHaveZeroData;
- (id)collection;
// converted property setter: - (void)setVendPhotoDataOnly:(BOOL)only;
// converted property getter: - (BOOL)vendPhotoDataOnly;
@end

@interface BRPhotoProviderForCollection : BRPhotoProvider <BRPhotoProviderForCollection> {
@private
	NSArray *_assets;	// 12 = 0xc
	BRPhotoMediaCollection *_collection;	// 16 = 0x10
	BOOL _vendPhotoDataOnly;	// 20 = 0x14
}
@property(readonly, retain) BRPhotoMediaCollection *collection;	// G=0x32e51bf5; converted property
@property(assign) BOOL vendPhotoDataOnly;	// G=0x32e51c19; S=0x32e51c09; converted property
+ (id)providerForCollection:(id)collection controlFactory:(id)factory;	// 0x32e51db1
- (id)initWithCollection:(id)collection controlFactory:(id)factory;	// 0x32e51d45
- (id)_data;	// 0x32e51c29
- (BOOL)canHaveZeroData;	// 0x32e51c05
// converted property getter: - (id)collection;	// 0x32e51bf5
- (id)dataAtIndex:(long)index;	// 0x32e51c95
- (long)dataCount;	// 0x32e51cd9
- (void)dealloc;	// 0x32e51cfd
- (id)hashForDataAtIndex:(long)index;	// 0x32e51c71
// converted property setter: - (void)setVendPhotoDataOnly:(BOOL)only;	// 0x32e51c09
// converted property getter: - (BOOL)vendPhotoDataOnly;	// 0x32e51c19
@end


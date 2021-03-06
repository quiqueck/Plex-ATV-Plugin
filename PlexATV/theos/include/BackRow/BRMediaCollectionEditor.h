/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

//

@protocol BRMediaCollection;

@interface BRMediaCollectionEditor : NSObject {
@private
	id<BRMediaCollection> _collection;	// 4 = 0x4
}
+ (id)editorForCollection:(id)collection;	// 0x32d9ec45
+ (void)setImplementationClass:(Class)aClass;	// 0x32d9ec19
- (id)initWithMediaCollection:(id)mediaCollection;	// 0x32d9eccd
- (void)addMediaObjectToCollection:(id)collection;	// 0x32d9ec29
- (void)clearCollection;	// 0x32d9ec31
- (id)collection;	// 0x32d9ec35
- (id)collectionCopyWithName:(id)name;	// 0x32d9ec25
- (void)dealloc;	// 0x32d9ec85
- (void)removeMediaObjectFromCollection:(id)collection;	// 0x32d9ec2d
@end


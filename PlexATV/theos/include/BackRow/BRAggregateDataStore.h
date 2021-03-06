/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BRDataStore.h"

@class NSArray;

__attribute__((visibility("hidden")))
@interface BRAggregateDataStore : BRDataStore {
@private
	NSArray *_dataStores;	// 40 = 0x28
}
- (id)initWithDataStores:(id)dataStores;	// 0x32e02841
- (void)dealloc;	// 0x32e027f9
- (id)loadData;	// 0x32e02729
- (void)purge;	// 0x32e027ad
- (void)setUseLocalProvidersOnly:(BOOL)only;	// 0x32e026b1
- (BOOL)storeAppliesToObject:(id)object;	// 0x32e02651
@end


/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BRProvider.h"
//

@class NSMutableArray, BRSeriesProvider, NSSet;
@protocol BRControlFactory;

@interface BRSeriesMostRecentNoStoreProvider : NSObject <BRProvider> {
@private
	NSSet *_mediaTypes;	// 4 = 0x4
	BRSeriesProvider *_seriesProvider;	// 8 = 0x8
	id<BRControlFactory> _controlFactory;	// 12 = 0xc
	BRSeriesProvider *_unwatchedProvider;	// 16 = 0x10
	NSMutableArray *_data;	// 20 = 0x14
	BOOL _storeAvailable;	// 24 = 0x18
	BOOL _needsUpdate;	// 25 = 0x19
	BOOL _initialized;	// 26 = 0x1a
}
+ (id)providerForMediaTypes:(id)mediaTypes controlFactory:(id)factory filteringOutProvider:(id)provider;	// 0x32e39491
- (void)_checkStore;	// 0x32e392e5
- (id)_data;	// 0x32e39095
- (id)_filteredDataFrom:(id)from;	// 0x32e38d75
- (id)_filteredSeriesNames;	// 0x32e38ec5
- (id)_initForMediaTypes:(id)mediaTypes controlFactory:(id)factory filteringOutProvider:(id)provider;	// 0x32e394e1
- (void)_reloadData;	// 0x32e38fc1
- (void)_setStoreAvailable:(BOOL)available;	// 0x32e390dd
- (BOOL)_storeAvailable;	// 0x32e38d65
- (id)controlFactory;	// 0x32e38d55
- (id)dataAtIndex:(long)index;	// 0x32e39445
- (long)dataCount;	// 0x32e3946d
- (void)dealloc;	// 0x32e39611
- (id)hashForDataAtIndex:(long)index;	// 0x32e393cd
@end


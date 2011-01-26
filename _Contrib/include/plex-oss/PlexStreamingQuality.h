//
//  PlexStreamingQuality.h
//  PlexPad
//
//  Created by Frank Bauer on 16.01.11.
//  Copyright 2011 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PlexStreamingQualityDescriptor;
typedef PlexStreamingQualityDescriptor* PlexStreamingQuality;
@interface PlexStreamingQualityDescriptor : NSObject {
	NSUInteger bitrate;
	NSUInteger maxHeight;
	NSInteger fps;
	NSInteger value;
	NSString* name;
}

+(PlexStreamingQuality)quality3GLow;
+(PlexStreamingQuality)quality3GMed;
+(PlexStreamingQuality)quality3GHigh;
+(PlexStreamingQuality)qualityWiFiLow;
+(PlexStreamingQuality)qualityWiFiMed;
+(PlexStreamingQuality)qualityiPhoneWiFi;
+(PlexStreamingQuality)qualityiPadWiFi;
+(PlexStreamingQuality)quality720pLow;
+(PlexStreamingQuality)quality720pHigh;
+(PlexStreamingQuality)quality1080pLow;
+(PlexStreamingQuality)quality1080pMed;
+(PlexStreamingQuality)quality1080pHigh;

+(NSArray*)qualitiesForPlex90;
+(NSArray*)qualitiesForPlex91;

+(PlexStreamingQuality)qualityForBitrate:(int)bts videoHeight:(int)in_vh fps:(int)in_fps quality:(int)in_qv;
-(id)initForBitrate:(int)in_br videoHeight:(int)in_vh fps:(int)in_fps quality:(int)in_qv;
-(id)initForBitrate:(int)in_br videoHeight:(int)in_vh fps:(int)in_fps quality:(int)in_qv name:(NSString*)in_name;

@property (readonly) NSInteger value;
@property (readonly) NSUInteger bitrate;
@property (readonly) NSUInteger maxHeight;
@property (readonly) NSInteger fps;
@property (readonly, retain) NSString* name;
@end


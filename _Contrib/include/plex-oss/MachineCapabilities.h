//
//  MachineCapabilities.h
//  PlexPad
//
//  Created by Frank Bauer on 16.01.11.
//  Copyright 2011 Ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlexStreamingQuality.h"
typedef const NSString* MachineCapability; 
extern MachineCapability SERVER_CAP_1080p_TRANSCODER;
extern MachineCapability SERVER_CAP_QUALITY_LISTING;
extern MachineCapability SERVER_CAP_GDM_DISCOVERY;
extern MachineCapability SERVER_CAP_BONJOUR_DISCOVERY;
extern MachineCapability SERVER_CAP_TRANSCODER_KEYS_IN_URL;
extern MachineCapability SERVER_CAP_DIRECT_PLAYBACK;
extern MachineCapability SERVER_CAP_EDIT_METADATA;
extern MachineCapability SERVER_CAP_TRANSCODER_PING;



@interface MachineCapabilities : NSObject {
	NSMutableArray* caps;
	NSMutableArray* qualities;
	int version;
}

@property (readonly) int version;
@property (readonly) NSMutableArray* caps;
@property (readonly) NSMutableArray* qualities;

-(id)initForServerVersion:(int)ver;
-(BOOL)supports:(MachineCapability)capability;
-(PlexStreamingQuality)qualityForHeight:(int)val returnFirst:(BOOL)retf;
-(PlexStreamingQuality)qualityForMaximumBitrate:(int)maxBrInkbps;
-(PlexStreamingQuality)qualityForValue:(int)val;

+(NSSet*)availableCapabilities;
+(NSString*)humanReadableCapability:(MachineCapability)mc;

+(NSUInteger)maxSystemStreamingBitrate;
+(NSUInteger)minSystemStreamingBitrate;


@end

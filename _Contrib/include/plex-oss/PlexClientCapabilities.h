//
//  PlexClientCapabilities.h
//  MachineTest
//
//  Created by Frank Bauer on 11.03.11.
//  Copyright 2011 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Machine;
typedef const NSString* PlexClientCapability;

extern const PlexClientCapability CLIENT_CAP_HTTP_LIVE_STREAMING;
extern const PlexClientCapability CLIENT_CAP_HTTP_MP4_STREAMING;
extern const PlexClientCapability CLIENT_CAP_720p_PLAYBACK;
extern const PlexClientCapability CLIENT_CAP_DECODER_CAPS;

typedef NSUInteger PlexClientBitrate;
typedef NSUInteger PlexClientAudioChannels;
typedef NSUInteger PlexClientH264Level;
typedef NSString* PlexClientH264Profile;
typedef NSUInteger PlexClientResolution;
typedef NSString* PlexClientDecoderName;

extern const PlexClientBitrate PlexClientBitrateAny;
extern const PlexClientAudioChannels PlexAudioChannelsAny;

extern const PlexClientDecoderName PlexClientDecoderName_MP3;
extern const PlexClientDecoderName PlexClientDecoderName_AAC;
extern const PlexClientDecoderName PlexClientDecoderName_AC3;
extern const PlexClientDecoderName PlexClientDecoderName_DTS;
extern const PlexClientDecoderName PlexClientDecoderName_PCM;

extern const PlexClientH264Level PlexClientH264Level_3_0;
extern const PlexClientH264Level PlexClientH264Level_3_1;
extern const PlexClientH264Level PlexClientH264Level_3_2;
extern const PlexClientH264Level PlexClientH264Level_4_0;
extern const PlexClientH264Level PlexClientH264Level_4_1;
extern const PlexClientH264Level PlexClientH264Level_4_2;
extern const PlexClientH264Level PlexClientH264Level_5_1;

extern const PlexClientH264Profile PlexClientH264Profile_High;
extern const PlexClientH264Profile PlexClientH264Profile_Baseline;
extern const PlexClientH264Profile PlexClientH264Profile_Main;

extern const PlexClientResolution PlexClientResolution_1080p;
extern const PlexClientResolution PlexClientResolution_720p;
extern const PlexClientResolution PlexClientResolution_SD;

extern const PlexClientAudioChannels PlexClientAudioChannels_Stereo;
extern const PlexClientAudioChannels PlexClientAudioChannels_Quadro;
extern const PlexClientAudioChannels PlexClientAudioChannels_5_1Surround;
extern const PlexClientAudioChannels PlexClientAudioChannels_6_1Surround;
extern const PlexClientAudioChannels PlexClientAudioChannels_7_1Surround;

@interface PlexClientDecoder : NSObject{
    PlexClientDecoderName name;
}
@property (readonly, retain) PlexClientDecoderName name;
-(NSString*)capString;
@end

@interface PlexClientAudioDecoder : PlexClientDecoder{
    PlexClientBitrate bitrate;
    PlexClientAudioChannels channels;
}

@property (readwrite, assign) PlexClientBitrate bitrate;
@property (readwrite, assign) PlexClientAudioChannels channels;
@end

@interface PlexClientVideoDecoder : PlexClientDecoder{
    PlexClientResolution resolution;
}

@property (readwrite, assign) PlexClientResolution resolution;
@end

@interface PlexClientH264VideoDecoder : PlexClientVideoDecoder{
    PlexClientH264Level level;
    PlexClientH264Profile profile;
}
@property (readwrite, assign) PlexClientH264Level level;
@property (readwrite, assign) PlexClientH264Profile profile;
@end


@interface PlexClientCapabilities : NSObject {
    NSMutableArray* caps;
    NSMutableArray* audioDecoders;
    NSMutableArray* videoDecoders;
    
    NSString* cachedCaps;
    Machine* cachedForMachine;
}

@property (readonly) NSMutableArray* caps;
@property (readonly) BOOL disableDirectCopy;

SINGLETON_INTERFACE(PlexClientCapabilities);

-(BOOL)supports:(PlexClientCapability)capability;
-(void)resetCaps;

+(NSSet*)availableCapabilities;
+(NSString*)humanReadableCapability:(PlexClientCapability)mc;

-(void)setAudioDecoderForCodec:(NSString*)name bitrate:(PlexClientBitrate)br channels:(PlexClientAudioChannels)ch;
-(void)removeAudioCodec:(NSString*)name;

-(NSString*)capStringForMachine:(Machine*)m;
@end

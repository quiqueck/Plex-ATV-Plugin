//
//  PlexMediaStream.h
//  PlexPad
//
//  Created by Frank Bauer on 12.02.11.
//  Copyright 2011 Ambertation. All rights reserved.
//

#import "PlexDirectory.h"

typedef NSUInteger PlexMediaStreamType;
extern const PlexMediaStreamType PlexMediaStreamTypeVideo;
extern const PlexMediaStreamType PlexMediaStreamTypeAudio;
extern const PlexMediaStreamType PlexMediaStreamTypeSubtitle;

@interface PlexMediaStream : PlexDirectory {

}

+(NSString*)stringFromPlexMediaStreamType:(const PlexMediaStreamType)t;

@property (readonly) const PlexMediaStreamType streamType;
@property (readonly) NSString* language;
@property (readonly) NSString* codec;
@property (readonly) NSString* streamDescription;
@property (readonly) NSInteger index;
@property (readonly) NSInteger channels;
@property (readwrite) BOOL selected;

-(id)initWithAttributes:(NSDictionary*)dict parentMediaContainer:(PlexMediaContainer*)mc parentObject:(PlexDirectory*)pmo containerType:(NSString*)ct;
@end

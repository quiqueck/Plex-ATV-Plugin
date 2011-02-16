//
//  PlexMediaObject + VideoDetails.h
//  PlexPad
//
//  Created by Frank Bauer on 12.02.11.
//  Copyright 2011 Ambertation. All rights reserved.
//

#import "PlexMediaObject.h"
#import "PlexMediaStream.h"

@interface PlexMediaObject (VideoDetails)
-(PlexMediaObject*)loadVideoDetails;
-(PlexDirectory*)partAtIndex:(NSUInteger)idx;

-(NSArray*)actors;
-(NSArray*)writers;
-(NSArray*)directors;
-(NSArray*)genres;
@end

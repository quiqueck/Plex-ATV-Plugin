//
//  PlexPlaybackController.h
//  plex
//
//  Created by bob on 2011-02-20.
//  Copyright 2011 Band's gonna make it!. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PlexMediaObject;

@interface PlexPlaybackController : NSObject {
  PlexMediaObject *pmo;
  NSTimer* playProgressTimer;
}
 
-(id)initWithPlexMediaObject:(PlexMediaObject*)mediaObject;
-(void)startPlaying;
-(void)playbackVideoWithOffset:(int)offset;
-(void)movieFinished:(NSNotification*)event;
-(void)playbackAudio;
@end

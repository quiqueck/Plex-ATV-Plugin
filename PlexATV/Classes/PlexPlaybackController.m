//
//  PlexPlaybackController.m
//  plex
//
//  Created by Bob Jelica on 22.02.2011.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// 

#import "PlexPlaybackController.h"
#import "Constants.h"
#import "HWUserDefaults.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexImage.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Preferences.h>
#import <plex-oss/PlexStreamingQuality.h>
#import "PlexMediaProvider.h"
#import "PlexMediaAsset.h"
#import "PlexMediaAssetOld.h"
#import "PlexPreviewAsset.h"
#import "PlexSongAsset.h"

BRMediaPlayer* __player = nil;
PlexMediaProvider* __provider = nil;

#define ResumeOptionDialog @"ResumeOptionDialog"
#define LOCAL_DEBUG_ENABLED 1

@implementation PlexPlaybackController

- (id) init
{
	self = [super init];
	if (self != nil) {
		//register for notifications when a movie has finished playing properly to the end.
		//used to mark movie as seen
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinished:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
	}
	return self;
}

-(id)initWithPlexMediaObject:(PlexMediaObject*)mediaObject {
	[self init];
	
	if (self != nil) {
		pmo = [mediaObject retain];
	}
	
	return self;
}

- (void) dealloc {
	DLog(@"deallocing player controller for %@", pmo.name);
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if (playProgressTimer){
		[playProgressTimer invalidate];
		[playProgressTimer release];
		playProgressTimer = nil;
	}
	
	if (__player){
		[__player release];
		__player = nil;
	}
	
	[pmo release];
	[super dealloc];
}



-(void)startPlaying {
	
	if ([@"Track" isEqualToString:pmo.containerType]){
		DLog(@"ITS A TRAP(CK)!");
		[self playbackAudio];
	}
	else {
		DLog(@"viewOffset: %@", [pmo.attributes valueForKey:@"viewOffset"]);
		
		//we have offset, ie. already watched a part of the movie, show a dialog asking if you want to resume or start over
		if ([pmo.attributes valueForKey:@"viewOffset"] != nil) {
			NSNumber *viewOffset = [NSNumber numberWithInt:[[pmo.attributes valueForKey:@"viewOffset"] intValue]];
			
			BROptionDialog *option = [[BROptionDialog alloc] init];
			[option setIdentifier:ResumeOptionDialog];
			
			[option setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
								 viewOffset, @"viewOffset", 
								 pmo, @"mediaObject",
								 nil]];
			[option setPrimaryInfoText:@"You have already watched a part of this video.\nWould you like to continue where you left off, or start from beginning?"];
			[option setSecondaryInfoText:pmo.name];
			
			int offsetInHrs = [viewOffset intValue] / (1000*60*60);
			int offsetInMins = ([viewOffset intValue] % (1000*60*60)) / (1000*60);
			int offsetInSecs = (([viewOffset intValue] % (1000*60*60)) % (1000*60)) / 1000;
			
			if (offsetInHrs > 0)
				[option addOptionText:[NSString stringWithFormat:@"Resume from %d hrs %d mins %d secs", offsetInHrs, offsetInMins, offsetInSecs]];
			else
				[option addOptionText:[NSString stringWithFormat:@"Resume from %d mins %d secs", offsetInMins, offsetInSecs]];
			
			[option addOptionText:@"Play from the beginning"];
			[option addOptionText:@"Go back"];
			[option setActionSelector:@selector(optionSelected:) target:self];
			[[[BRApplicationStackManager singleton] stack] pushController:option];
			[option release];
		}
		else {
			[self playbackVideoWithOffset:0]; //not previously unwatched, just start playback from beginning
		}
		
	}
	
}

-(void)playbackVideoWithOffset:(int)offset {
	[pmo.attributes setObject:[NSNumber numberWithInt:offset] forKey:@"viewOffset"]; //set where in the video we want to start...
	
    //determine the user selected quality setting
	NSString *qualitySetting = [[HWUserDefaults preferences] objectForKey:PreferencesQualitySetting];
	PlexStreamingQualityDescriptor *streamQuality;
	if ([qualitySetting isEqualToString:@"Good"]) {
		streamQuality = [PlexStreamingQualityDescriptor qualityiPadWiFi];
	} else 	if ([qualitySetting isEqualToString:@"Best"]) {
		streamQuality = [PlexStreamingQualityDescriptor quality720pHigh];
	} else { //medium (default)
		streamQuality = [PlexStreamingQualityDescriptor quality720pLow];
	}
	pmo.request.machine.streamQuality = streamQuality;
	
	/*
	 //player get's confused if we're running a transcoder already (tried playing and failed on ATV, transcoder still running)
	 if ([pmo.request transcoderRunning]) {
	 [pmo.request stopTranscoder];
	 [NSThread sleepForTimeInterval:3.0]; //give the PMS chance to kill transcoder, since we're gonna start a new one right away
	 }
	 */
	
	
	DLog(@"Quality: %@", pmo.request.machine.streamQuality);
	NSURL* mediaURL = [pmo mediaURL];
	
	DLog(@"Starting Playback of %@", mediaURL);
	
	BOOL didTimeOut = NO;
	[pmo.request dataForURL:mediaURL authenticateStreaming:YES timeout:0  didTimeout:&didTimeOut];
	
	
	
	if (__provider==nil){
		__provider = [[PlexMediaProvider alloc] init];
		BRMediaHost* mh = [[BRMediaHost mediaHosts] objectAtIndex:0];
		[mh addMediaProvider:__provider];
	}
	
	if (playProgressTimer){
		[playProgressTimer invalidate];
		[playProgressTimer release];
		playProgressTimer = nil;
	}
	
	if (__player){
		[__player release];
		__player = nil;
	}
	
	BRBaseMediaAsset* pma = nil;
	if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.1"]){
		pma = [[PlexMediaAssetOld alloc] initWithURL:mediaURL mediaProvider:__provider mediaObject:pmo];
	} else {
		pma = [[PlexMediaAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:pmo];
	}
	
    //DLog(@"mediaItem: %@", [pma mediaItemRef]);
	
	BRMediaPlayerManager* mgm = [BRMediaPlayerManager singleton];
	NSError * error = nil;
	BRMediaPlayer * player = [mgm playerForMediaAsset:pma error: &error];
	
	DLog(@"pma=%@, prov=%@, mgm=%@, play=%@, err=%@", pma, __provider, mgm, player, error);
	
	if ( error != nil ){
		DLog(@"b0bben: error in brmediaplayer, aborting");
		[pma release];
		return ;
	}
	
	
    //[mgm presentMediaAsset:pma options:0];
	[mgm presentPlayer:player options:0];
	DLog(@"presented player");
	playProgressTimer = [[NSTimer scheduledTimerWithTimeInterval:10.0f 
														  target:self 
														selector:@selector(reportProgress:) 
														userInfo:nil 
														 repeats:YES] retain];
	[pma release];
}

-(void)playbackAudio {
	DLog(@"playbackAudioWithMediaObject");
	
	NSError *error;
	
	DLog(@"track_url: %@", [pmo mediaStreamURL]);
	DLog(@"key: %@", [pmo.attributes objectForKey:@"key"]);
	
	PlexSongAsset *psa = [[PlexSongAsset alloc] initWithURL:[pmo.attributes objectForKey:@"key"] mediaProvider:nil mediaObject:pmo];
	BRMediaPlayer *player = [[BRMediaPlayerManager singleton] playerForMediaAsset:psa error:&error];
	[psa release];
    //BRMediaPlayer *player = [[BRMediaPlayerManager singleton] playerForMediaAssetAtIndex:index inTrackList:songList error:&error];
	[[BRMediaPlayerManager singleton] presentPlayer:player options:nil];	
}

-(void)reportProgress:(NSTimer*)tm {
	BRMediaPlayer *playa = [[BRMediaPlayerManager singleton] activePlayer];
	DLog(@"Elapsed: %f, %i", playa.elapsedTime, playa.playerState);
	
	switch (playa.playerState) {
		case kBRMediaPlayerStateStopped:
			DLog(@"Finished Playback");
			
			if (playProgressTimer){
				[playProgressTimer invalidate];
				[playProgressTimer release];
				playProgressTimer = nil;
			}
			
#warning why are we releasing the singleton ?
			if (playa){
				[playa release];
				playa = nil;
			}
			
			//stop the transcoding on PMS
			[pmo.request stopTranscoder];
			DLog(@"stopping transcoder");
      
			break;
		case kBRMediaPlayerStatePlaying:
			//report time back to PMS so we can continue in the right spot
			[pmo postMediaProgress: playa.elapsedTime];
			return;
		case kBRMediaPlayerStatePaused:
			DLog(@"paused playback, pinging transcoder");
			[pmo.request pingTranscoder];
			break;
		default:
			break;
	}
}

-(void)movieFinished:(NSNotification*)event {
	[pmo markSeen];
	[[[BRApplicationStackManager singleton] stack] popController];
}

- (void)optionSelected:(id)sender {
	BROptionDialog *option = sender;
	if ([option.identifier isEqualToString:ResumeOptionDialog]) {
		NSNumber *viewOffset = [option.userInfo objectForKey:@"viewOffset"];
		
		if([[sender selectedText] hasPrefix:@"Resume from"]) {
			[[[BRApplicationStackManager singleton] stack] popController]; //need this so we don't go back to option dialog when going back
			DLog(@"Resuming from %d ms", [viewOffset intValue]);
			[self playbackVideoWithOffset:[viewOffset intValue]];
		} else if ([[sender selectedText] isEqualToString:@"Play from the beginning"]) {
			[[[BRApplicationStackManager singleton] stack] popController]; //need this so we don't go back to option dialog when going back
			[self playbackVideoWithOffset:0]; //0 offset is beginning, mkay?
		} else if ([[sender selectedText] isEqualToString:@"Go back"]) {
			//go back to movie listing...
			[[[BRApplicationStackManager singleton] stack] popController];
		}
	}
}




@end

  //
  //  HWPlexDir.m
  //  atvTwo
  //
  //  Created by Frank Bauer on 22.10.10.
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

#import "HWPlexDir.h"
#import "Constants.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexImage.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Preferences.h>
#import "PlexMediaProvider.h"
#import "PlexMediaAsset.h"
#import "PlexMediaAssetOld.h"
#import "PlexPreviewAsset.h"
#import "PlexSongAsset.h"
#import "SongListController.h"
#import "HWUserDefaults.h"

BRMediaPlayer* __player = nil;
PlexMediaProvider* __provider = nil;
@implementation HWPlexDir
@synthesize rootContainer;

- (id) init
{
	if((self = [super init]) != nil) {
    
      //register for notifications when a movie has finished playing properly to the end.
      //used to mark movie as seen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinished:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
		
      //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(log:) name:nil object:nil];
    
		[self setListTitle:@"PLEX"];
		
		NSString *settingsPng = [[NSBundle bundleForClass:[HWPlexDir class]] pathForResource:@"PlexIcon" ofType:@"png"];
		BRImage *sp = [BRImage imageWithPath:settingsPng];
      //BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];
		
		[self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		
		rootContainer = nil;
		[[self list] setDatasource:self];
		return ( self );
		
	}
	
	return ( self );
}	

- (void)log:(NSNotificationCenter *)note {
  NSLog(@"note = %@", note);
}

-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
	NSLog(@"deallocing HWPlexDir");
	if (playProgressTimer){
		[playProgressTimer invalidate];
		[playProgressTimer release];
		playProgressTimer = nil;
	}
	
	if (__player){
		[__player release];
		__player = nil;
	}
	
  [playbackItem release];
	[rootContainer release];
	
	[super dealloc];
}

  //handle custom event
-(BOOL)brEventAction:(BREvent *)event
{
	int remoteAction = [event remoteAction];
  if ([(BRControllerStack *)[self stack] peekController] != self)
		remoteAction = 0;
  
  int itemCount = [[(BRListControl *)[self list] datasource] itemCount];
  switch (remoteAction)
  {
    case kBREventRemoteActionSelectHold: {
      if([event value] == 1) {
          //get the index of currently selected row
				long selected = [self getSelection];
				[self showModifyViewedStatusViewForRow:selected];
			}
      break;
		}
    case kBREventRemoteActionSwipeLeft:
    case kBREventRemoteActionLeft:
      return YES;
      break;
    case kBREventRemoteActionSwipeRight:
    case kBREventRemoteActionRight:
      return YES;
      break;
    case kBREventRemoteActionPlayPause:
      NSLog(@"play/pause event");
      if([event value] == 1)
        [self playPauseActionForRow:[self getSelection]];
      
      
      return YES;
      break;
		case kBREventRemoteActionUp:
		case kBREventRemoteActionHoldUp:
			if([self getSelection] == 0 && [event value] == 1)
			{
				[self setSelection:itemCount-1];
				return YES;
			}
			break;
		case kBREventRemoteActionDown:
		case kBREventRemoteActionHoldDown:
			if([self getSelection] == itemCount-1 && [event value] == 1)
			{
				[self setSelection:0];
				return YES;
			}
			break;
  }
	return [super brEventAction:event];
}

- (id)previewControlForItem:(long)item
{
#if DEBUG
	NSLog(@"HWPlexDir_previewControlForItem");
#endif
	PlexMediaObject* pmo = [rootContainer.directories objectAtIndex:item];
	[pmo retain];
	
	NSURL* mediaURL = [pmo mediaStreamURL];
	PlexPreviewAsset* pma = [[PlexPreviewAsset alloc] initWithURL:mediaURL mediaProvider:__provider mediaObject:pmo];
	BRMetadataPreviewControl *preview =[[BRMetadataPreviewControl alloc] init];
	[preview setShowsMetadataImmediately:NO];
	[preview setAsset:pma];	
	[pmo release];
	
	return [preview autorelease];
}

#define ModifyViewStatusOptionDialog @"ModifyViewStatusOptionDialog"
#define ResumeOptionDialog @"ResumeOptionDialog"

- (void)itemSelected:(long)selected; {
	PlexMediaObject* pmo = [rootContainer.directories objectAtIndex:selected];
	
	NSString* type = [pmo.attributes objectForKey:@"type"];
	if ([type empty]) type = pmo.containerType;
	type = [type lowercaseString];
	
    //NSLog(@"Item Selected: %@, type:%@", pmo.debugSummary, type);
	
	NSLog(@"viewgroup: %@, artistgroup:%@",pmo.mediaContainer.viewGroup, pmo.mediaContainer.content );
	
	
	if ([PlexViewGroupAlbum isEqualToString:pmo.mediaContainer.viewGroup] || [@"albums" isEqualToString:pmo.mediaContainer.content]) {
		NSLog(@"Accessing Artist/Album %@", pmo);
		SongListController *songlist = [[SongListController alloc] initWithPlexContainer:[pmo contents] title:pmo.name];
		[[[BRApplicationStackManager singleton] stack] pushController:songlist];
		[songlist autorelease];
	}
	else if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType]){
		NSLog(@"viewOffset: %@", [pmo.attributes valueForKey:@"viewOffset"]);
		
      //we have offset, ie. already watched a part of the movie, show a dialog asking if you want to resume or start over
		if ([pmo.attributes valueForKey:@"viewOffset"] != nil) {
			NSNumber *viewOffset = [NSNumber numberWithInt:[[pmo.attributes valueForKey:@"viewOffset"] intValue]];
			
			BROptionDialog *option = [[BROptionDialog alloc] init];
			[option setIdentifier:ResumeOptionDialog];
			
			[option setUserInfo:[[NSDictionary alloc] initWithObjectsAndKeys:
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
			[[self stack] pushController:option];
			[option release];
		}
		else
			[self playbackVideoWithMediaObject:pmo andOffset:0]; //not previously unwatched, just start playback from beginning
		
	}
	else {
		HWPlexDir* menuController = [[HWPlexDir alloc] init];
		menuController.rootContainer = [pmo contents];
		[[[BRApplicationStackManager singleton] stack] pushController:menuController];
		
		[menuController autorelease];
	}
}

- (void)showModifyViewedStatusViewForRow:(long)row {
    //get the currently selected row
	PlexMediaObject* pmo = [rootContainer.directories objectAtIndex:row];
	
	if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType]){
		BROptionDialog *option = [[BROptionDialog alloc] init];
		[option setIdentifier:ModifyViewStatusOptionDialog];
		
		[option setUserInfo:[[NSDictionary alloc] initWithObjectsAndKeys:
                         pmo, @"mediaObject",
                         nil]];
		
		[option setPrimaryInfoText:@"Modify View Status"];
		[option setSecondaryInfoText:pmo.name];
		
		[option addOptionText:@"Mark as Watched"];
		[option addOptionText:@"Mark as Unwatched"];
		[option addOptionText:@"Go back"];
		[option setActionSelector:@selector(optionSelected:) target:self];
		[[self stack] pushController:option];
		[option release];
	}
}

- (void)optionSelected:(id)sender {
	BROptionDialog *option = sender;
	PlexMediaObject *pmo = [option.userInfo objectForKey:@"mediaObject"];
	if ([option.identifier isEqualToString:ResumeOptionDialog]) {
		NSNumber *viewOffset = [option.userInfo objectForKey:@"viewOffset"];
		
		if([[sender selectedText] hasPrefix:@"Resume from"]) {
			[[self stack] popController]; //need this so we don't go back to option dialog when going back
			NSLog(@"Resuming from %d ms", [viewOffset intValue]);
			[self playbackVideoWithMediaObject:pmo andOffset:[viewOffset intValue]];
		} else if ([[sender selectedText] isEqualToString:@"Play from the beginning"]) {
			[[self stack] popController]; //need this so we don't go back to option dialog when going back
			[self playbackVideoWithMediaObject:pmo andOffset:0]; //0 offset is beginning, mkay?
		} else if ([[sender selectedText] isEqualToString:@"Go back"]) {
        //go back to movie listing...
			[[self stack] popController];
		}
	} else if ([option.identifier isEqualToString:ModifyViewStatusOptionDialog]) {		
		if([[sender selectedText] isEqualToString:@"Mark as Watched"]) {
        //mark video watched
			[[self stack] popController]; //need this so we don't go back to option dialog when going back
			NSLog(@"Marking as watched: %@", pmo.name);
			[pmo markSeen];
			[self.list reload];
		} else if ([[sender selectedText] isEqualToString:@"Mark as Unwatched"]) {
        //mark as unwatched
			[[self stack] popController]; //need this so we don't go back to option dialog when going back
			NSLog(@"Marking as unwatched: %@", pmo.name);
			[pmo markUnseen];
			[self.list reload];
		} else if ([[sender selectedText] isEqualToString:@"Go back"]) {
        //go back to movie listing...
			[[self stack] popController];
		}
	}
}

-(void)playbackVideoWithMediaObject:(PlexMediaObject*)pmo andOffset:(int)offset {
	[pmo.attributes setObject:[NSNumber numberWithInt:offset] forKey:@"viewOffset"]; //set where in the video we want to start...
	
    //determine the user selected quality setting
	NSString *qualitySetting = [[HWUserDefaults preferences] objectForKey:PreferencesQualitySetting];
	PlexStreamingQuality streamQuality;
  Machine* m = pmo.request.machine;
	if ([qualitySetting isEqualToString:@"Good"]) {
      streamQuality = [m.capabilities qualityForHeight:768 returnFirst:NO]; //720p streams are higher bitrate streams than 768!!!
	} else 	if ([qualitySetting isEqualToString:@"Best"]) {
		streamQuality = [m.capabilities qualityForHeight:1080 returnFirst:YES];
	} else { //medium (default)
		streamQuality = [m.capabilities qualityForHeight:720 returnFirst:YES];
	}
	pmo.request.machine.streamQuality = streamQuality;
	
    //player get's confused if we're running a transcoder already (tried playing and failed on ATV, transcoder still running)
    //if ([pmo.request transcoderRunning]) {
    // [pmo.request stopTranscoder];
    //  [NSThread sleepForTimeInterval:3.0]; //give the PMS chance to kill transcoder, since we're gonna start a new one right away
    //}
		
	
	
	NSLog(@"Quality (%@): %@, %i", qualitySetting, m.streamQuality, m.streamQuality.value);
    NSLog(@"Quality (%@): %@, %i", qualitySetting, streamQuality, streamQuality.value);
	NSURL* mediaURL = [pmo mediaURL];
	
	NSLog(@"Starting Playback of %@", mediaURL);
	
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
	
	if (playbackItem){
		[playbackItem release];
		playbackItem = nil;
	}
	
	BRBaseMediaAsset* pma = nil;
	if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.1"]){
		pma = [[PlexMediaAssetOld alloc] initWithURL:mediaURL mediaProvider:__provider mediaObject:pmo];
	} else {
		pma = [[PlexMediaAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:pmo];
	}
	
    //NSLog(@"mediaItem: %@", [pma mediaItemRef]);
  
	BRMediaPlayerManager* mgm = [BRMediaPlayerManager singleton];
	NSError * error = nil;
	BRMediaPlayer * player = [mgm playerForMediaAsset:pma error: &error];
	
	NSLog(@"pma=%@, prov=%@, mgm=%@, play=%@, err=%@", pma, __provider, mgm, player, error);
	
	if ( error != nil ){
		NSLog(@"b0bben: error in brmediaplayer, aborting");
		[pma release];
		return ;
	}
	
	
    //[mgm presentMediaAsset:pma options:0];
	[mgm presentPlayer:player options:0];
  NSLog(@"presented player");
    //[pma autorelease];
    //__player = [player retain];
	playbackItem = [pmo retain];
	playProgressTimer = [[NSTimer scheduledTimerWithTimeInterval:10.0f 
                                                        target:self 
                                                      selector:@selector(reportProgress:) 
                                                      userInfo:nil 
                                                       repeats:YES] retain];
	
	
	
	return;
	
}

-(void)reportProgress:(NSTimer*)tm{
	BRMediaPlayer *playa = [[BRMediaPlayerManager singleton] activePlayer];
  NSLog(@"Elapsed: %f, %i", playa.elapsedTime, playa.playerState);
  
  switch (playa.playerState) {
    case kBRMediaPlayerStateStopped:
      NSLog(@"Finished Playback");
      
      if (playProgressTimer){
        [playProgressTimer invalidate];
        [playProgressTimer release];
        playProgressTimer = nil;
      }
      
      if (playa){
        [playa release];
        playa = nil;
      }
      
      if (playbackItem){
        [playbackItem release];
        playbackItem = nil;
      }
      
      
        //stop the transcoding on PMS
      [rootContainer.request stopTranscoder];
      NSLog(@"stopping transcoder");
    
      break;
    case kBRMediaPlayerStatePlaying:
        //report time back to PMS so we can continue in the right spot
      [playbackItem postMediaProgress: playa.elapsedTime];
      return;
    case kBRMediaPlayerStatePaused:
      NSLog(@"paused playback, pinging transcoder");
      [rootContainer.request pingTranscoder];
      break;
    default:
      break;
  }
}

-(void)movieFinished:(NSNotification*)event {
  [playbackItem markSeen];
  [[self list] reload];
}


- (float)heightForRow:(long)row {	
	float height;
	
	PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
	if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType]) {
		height = 70.0f;
	} else {
		height = 0.0f;
	}
	return height;
}

- (long)itemCount {
	return [rootContainer.directories count];
}

- (id)itemForRow:(long)row {
	if(row > [rootContainer.directories count])
		return nil;
	
	id result;
	
	PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
	NSString *mediaType = [pmo.attributes valueForKey:@"type"];
	
	if (pmo.hasMedia || [@"Video" isEqualToString:mediaType]) {
		BRComboMenuItemLayer *menuItem = [[BRComboMenuItemLayer alloc] init];
		
		BRImage *image;
		if ([pmo seenState] == PlexMediaObjectSeenStateUnseen) {
			image = [[BRThemeInfo sharedTheme] unplayedVideoImage];			
		} else if ([pmo seenState] == PlexMediaObjectSeenStateInProgress) {
			image = [[BRThemeInfo sharedTheme] partiallyplayedVideoImage];
		} else {
			image = nil;
		}
		//BRImageControl *thumbnailLayer = (BRImageControl *)[menuItem valueForKey:@"_thumbnailLayer"];
		[menuItem setThumbnailImage:image];
		[menuItem setThumbnailLayerAspectRatio:0.5]; //halves the size of the image (ie makes it the "right" size)
		
		[menuItem setTitle:[pmo name]];
		
		NSString *subtitle = nil;
		if ([mediaType isEqualToString:PlexMediaObjectTypeEpisode]) {
			//set subtitle to episode number
			subtitle = [NSString stringWithFormat:@"Episode %d", [pmo.attributes integerForKey:@"index"]];
		} else {
			//set subtitle to year
			NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"yyyy"];
			subtitle = [dateFormatter stringFromDate:pmo.originallyAvailableAt];
			[dateFormatter release];
		}
		[menuItem setSubtitle:subtitle];
		
		result = [menuItem autorelease];
	} else {
		BRMenuItem * menuItem = [[BRMenuItem alloc] init];
		
		if ([mediaType isEqualToString:PlexMediaObjectTypeShow] || [mediaType isEqualToString:PlexMediaObjectTypeSeason]) {
			if ([pmo.attributes valueForKey:@"agent"] == nil) {
				int accessoryType;
				if ([pmo seenState] == PlexMediaObjectSeenStateUnseen) {
					accessoryType = 15;
				} else if ([pmo seenState] == PlexMediaObjectSeenStateInProgress) {
					accessoryType = 16;
				} else {
					accessoryType = 0;
				}
				[menuItem addAccessoryOfType:accessoryType];
			}
		}
		
		[menuItem setText:[pmo name] withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		
		[menuItem addAccessoryOfType:1];
		result = [menuItem autorelease];
	}
	return result;
}

- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (id)titleForRow:(long)row {
	PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
	return pmo.name;
}

@end

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
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexImage.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Preferences.h>
#import "PlexMediaProvider.h"
#import "PlexMediaAsset.h"
#import "SongListController.h"

BRMediaPlayer* __player = nil;
PlexMediaProvider* __provider = nil;
@implementation HWPlexDir
@synthesize rootContainer;

- (id) init
{
	if((self = [super init]) != nil) {
		
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


-(void)dealloc
{
	
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


- (id)previewControlForItem:(long)item
{
#if DEBUG
  NSLog(@"previewControlForItem");
#endif
	PlexMediaObject* pmo = [rootContainer.directories objectAtIndex:item];

  NSURL* mediaURL = [pmo mediaStreamURL];
  PlexMediaAsset* pma = [[PlexMediaAsset alloc] initWithURL:mediaURL mediaProvider:__provider mediaObject:pmo];
  BRMetadataPreviewControl *preview =[[BRMetadataPreviewControl alloc] init];
  [preview setShowsMetadataImmediately:YES];
  [preview setAsset:pma];	
  
  return [preview autorelease];
}



- (void)itemSelected:(long)selected; {
	
	PlexMediaObject* pmo = [rootContainer.directories objectAtIndex:selected];
	NSLog(@"Item Selected: %@, type:%@", pmo, [pmo.attributes valueForKey:@"type"]);
	
  if ([@"album" isEqualToString:[pmo.attributes valueForKey:@"type"]]) {
      SongListController *songlist = [[SongListController alloc] initWithSongs:pmo.contents.directories title:pmo.name];
    songlist.rootContainer = [pmo contents];
      [[[BRApplicationStackManager singleton] stack] pushController:songlist];
      [songlist autorelease];
  }
	
	else if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType]){
		[pmo.attributes setObject:[NSNumber numberWithInt:0] forKey:@"viewOffset"];
		pmo.request.machine.streamQuality = PlexStreamingQuality720p_1500;
		NSLog(@"Quality: %i, %f", pmo.request.machine.streamQuality, pmo.request.machine.quality);
		NSURL* mediaURL = [pmo mediaStreamURL];
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
		
		
		PlexMediaAsset* pma = [[PlexMediaAsset alloc] initWithURL:mediaURL mediaProvider:__provider mediaObject:pmo];
		BRMediaPlayerManager* mgm = [BRMediaPlayerManager singleton];
		NSError * error = nil;
		BRMediaPlayer * player = [mgm playerForMediaAsset: pma error: &error];
		
		
		//[pma setValue:[NSNumber numberWithInt:70] forKey:@"duration"];
		//player.stopTime = 2920;
		//player.startTime = 0;
		
		NSLog(@"pma=%@, prov=%@, mgm=%@, play=%@, err=%@", pma, __provider, mgm, player, error);
		
		if ( error != nil ){
			NSLog(@"b0bben: error in brmediaplayer, aborting");
			[pma release];
			return ;
		}
		
		
		//[mgm presentMediaAsset:pma options:0];
		[mgm presentPlayer:player options:0];
		[pma release];
		//__player = [player retain];
		playbackItem = [pmo retain];
		playProgressTimer = [[NSTimer scheduledTimerWithTimeInterval:10.0f 
															  target:self 
															selector:@selector(reportProgress:) 
															userInfo:nil 
															 repeats:YES] retain];
		
		
		return;
	}
  else {
    HWPlexDir* menuController = [[HWPlexDir alloc] init];
    menuController.rootContainer = [pmo contents];
    [[[BRApplicationStackManager singleton] stack] pushController:menuController];
    
    [menuController autorelease];
  }
	

}

-(void)reportProgress:(NSTimer*)tm{
  BRMediaPlayer *playa = [[BRMediaPlayerManager singleton] activePlayer];
	if (playa.playerState==0){
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
		
		return;
	}

	NSLog(@"Elapsed: %f, %i", __player.elapsedTime, __player.playerState);
	
    //TODO: uncomment once we have duration working
	//[playbackItem postMediaProgress: __player.elapsedTime];
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
  NSLog(@"itemForRow-mediaType: %@", mediaType);
  
	if (pmo.hasMedia || [@"Video" isEqualToString:mediaType]) {
		BRComboMenuItemLayer *menuItem = [[BRComboMenuItemLayer alloc] init];
		
		id image;
		if ([pmo seenState] == PlexMediaObjectSeenStateUnseen) {
			image = [[BRThemeInfo sharedTheme] unplayedVideoImage];			
		} else if ([pmo seenState] == PlexMediaObjectSeenStateInProgress) {
			image = [[BRThemeInfo sharedTheme] partiallyplayedVideoImage];
		} else {
			image = nil;
		}
		[menuItem setThumbnailImage:image];
		
		[menuItem setTitle:[pmo name]];
		
		int durationInMinutes = (int)([pmo duration] / 60);
		
		NSString *duration = [[NSString alloc] initWithFormat:@"%d minutes", durationInMinutes];
		[menuItem setSubtitle:duration];
		[duration release];
		
		result = [menuItem autorelease];
	} else {
		BRMenuItem * menuItem = [[BRMenuItem alloc] init];
		
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

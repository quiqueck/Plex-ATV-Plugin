//
//  SongListController.m
//  Groovy
//
//  Copyright (c) 2010, hackfrag <hackfrag@gmail.com , headcrap <headcrap19388@googlemail.com>
//  http://groovy.weasel-project.com
//  
//  All rights reserved.
//  
//  
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction except as noted below, including without limitation 
//  the rights to use,copy, modify, merge, publish, distribute, 
//  and/or sublicense, and to permit persons to whom the Software is 
//  furnished to do so, subject to the following conditions:
//  
//  The Software and/or source code cannot be copied in whole and 
//  sold without meaningful modification for a profit. 
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  Redistributions of source code must retain the above copyright 
//  notice, this list of conditions and the following disclaimer.
//  
//  Redistributions in binary form must reproduce the above copyright 
//  notice, this list of conditions and the following disclaimer in 
//  the documentation and/or other materials provided with 
//  the distribution.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.


#import "SongListController.h"
#import "PlexMediaProvider.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>

@implementation SongListController

@synthesize songs;
@synthesize rootContainer;

#pragma mark -
#pragma mark init/dealoc
- (id)init {
	if((self = [super init]) != nil) {
		[self setListTitle:@"Search Result"];
		[[self list] setDatasource:self];
		[[self list] addDividerAtIndex:2 withLabel:@"Songlist"];
		return self;
	}
	
	return self;
}
- (id)initWithSongs:(NSArray *)songs title:(NSString *)title {
	self = [self init];
	[self setListTitle:title];
	self.songs = songs;
	return self;
}
- (void)dealloc {
	[self.songs dealloc];
	
	[super dealloc];
}

#pragma mark BRMediaMenuControllerDatasource
- (float)heightForRow:(long)row{
	return 0.0f;
}
- (long)itemCount {
	return [songs count] + 2;
}

- (id)itemForRow:(long)row {
  NSLog(@"itemForRow - SongListController");
	if(row == 0) {
		BRMenuItem * result = [[BRMenuItem alloc] init];
		[result setText:@"Play all" withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		[result addAccessoryOfType:0];
		return result;
	} else if (row == 1) {
		BRMenuItem * result = [[BRMenuItem alloc] init];
		[result setText:@"Shuffle" withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		[result addAccessoryOfType:0];
		return result;
	} else {
    PlexMediaObject *song = [songs objectAtIndex:row-2];
      NSLog(@"itemForRow - %@", song.name);
		BRMenuItem * result = [[BRMenuItem alloc] init];
		[result setText:[song name] withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		[result addAccessoryOfType:0];
		return result;
	}
	
	
}
- (void)itemSelected:(long)selected; { 
	NSLog(@"itemSelected - SongListController");
	if(selected == 0) {
		// Play All
		[self playAtIndex:0 withArray:self.songs];
	} else if (selected == 1) {
		// Shuffle
		[self playAtIndex:0 withArray:[self.songs shuffledArray]];
	} else {
		// Selected Song
		[self playAtIndex:(selected-2) withArray:self.songs];
	}
	
}

- (void)playAtIndex:(NSInteger)index withArray:(NSArray *)songList {
  NSLog(@"playAtIndex: %d", index);
    NSLog(@"playAtIndex: songs count %d", [songList count]);
    //BRTextWithSpinnerController *spinnerController = [[BRTextWithSpinnerController alloc] initWithTitle:@"Buffer" text:@"Getting Stream.."];
    //[[self stack] pushController:spinnerController];
    //[spinnerController release];

  PlexMediaObject *pmo = [songList objectAtIndex:index];
    //NSURL *mediaURL = [pmo mediaStreamURL];
    //NSLog(@"playAtIndex: PMC = %@", [pmo.request rootLevel]);
    //NSLog(@"playAtIndex: mediaurl = %@", [pmo mediaStreamURL]);
  
  /*
  PlexMediaAsset* pma = [[PlexMediaAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:pmo];
  [[self stack] popController];
  NSError *error;
  
  BRMediaPlayer *player = [[BRMediaPlayerManager singleton] playerForMediaAsset:pma error:&error];
  
  [[BRMediaPlayerManager singleton] presentPlayer:player options:nil];	
  */
  
/*	Groovy *groovy = [Groovy sharedGroovy];
	
	[groovy getStreamUrlBySong:song callback:^(NSString *streamUrl) {
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc postNotificationName:groovyPlayNotification object:song];
		
		song.songURL = streamUrl;
		
		[[self stack] popController];
		NSError *error;
		
		BRMediaPlayer *player = [[BRMediaPlayerManager singleton] playerForMediaAssetAtIndex:index inTrackList:songs error:&error];
		
		[[BRMediaPlayerManager singleton] presentPlayer:player options:nil];	
	}];
 */
} 
- (id)previewControlForItem:(long)item {	
  NSLog(@"previewControlForItem - SongListController");
  return nil;
 /*
  if(item == 0) {
		return nil;
	} else if (item == 1) {
		return nil;
	} else {
    if(item<0 || item>=rootContainer.directories.count) return nil;
    PlexMediaObject* pmo = [songs objectAtIndex:item];
    
    NSURL* mediaURL = [pmo mediaStreamURL];
    PlexMediaAsset* pma = [[PlexMediaAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:pmo];
    BRMetadataPreviewControl *preview =[[BRMetadataPreviewControl alloc] init];
    [preview setShowsMetadataImmediately:YES];
    [preview setAsset:pma];	
    
    return [preview autorelease];	}
  */
}
- (BOOL)rowSelectable:(long)selectable {
	return YES;
}
- (id)titleForRow:(long)row {
	return nil;
}



@end

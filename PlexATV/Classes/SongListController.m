  //
  //  SongListController.m
  //  Groovy
  //
  //  Copyright (c) 2010, hackfrag <hackfrag@gmail.com , headcrap <headcrap19388@googlemail.com>
  //  http://groovy.weasel-project.com
  //
  //  Plex modifications by b0bben
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
#import "PlexSongAsset.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexRequest.h>

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
- (id)initWithPlexContainer:(PlexMediaContainer *)container title:(NSString *)title {
  
  self = [self init];
	[self setListTitle:title];
  self.rootContainer = container;
 	[container retain];
	[self convertDirToSongAssets:container.directories];
	return self;
}

- (void)dealloc {
	[self.songs dealloc];
	[self.rootContainer release];
	[super dealloc];
}

- (void)convertDirToSongAssets:(NSArray*)plexDirectories {
  self.songs = [[NSMutableArray alloc] initWithCapacity:5];
  NSLog(@"rootcontainer: %@", plexDirectories);
  
  for (int i=0; i < [plexDirectories count]; i++) {
    PlexMediaObject *track = [plexDirectories objectAtIndex:i];
    NSLog(@"track dirs: %@", [track contents].directories);
    PlexDirectory* pmd = [track mediaResource];
    NSArray* parts = [pmd.subObjects objectForKey:@"Part"];

    PlexMediaObject* pmo = [parts objectAtIndex:0];
    NSURL *mediaURL =[NSURL URLWithString:[track.request buildAbsoluteKey:pmo.key]];
    
    PlexSongAsset *song = [[[PlexSongAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:track] autorelease];
    
    [self.songs addObject:song];
  }
  
}



#pragma mark BRMediaMenuControllerDatasource
- (float)heightForRow:(long)row{
	return 0.0f;
}
- (long)itemCount {
	return [self.songs count] + 2;
}

- (id)itemForRow:(long)row {
  NSLog(@"itemForRow - SongListController");
	if(row == 0) {
		BRMenuItem * result = [[[BRMenuItem alloc] init] autorelease];
		[result setText:@"Play all" withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		[result addAccessoryOfType:0];
		return result;
	} else if (row == 1) {
		BRMenuItem * result = [[[BRMenuItem alloc] init] autorelease];
		[result setText:@"Shuffle" withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		[result addAccessoryOfType:0];
		return result;
	} else {
    PlexSongAsset *song = [self.songs objectAtIndex:row-2];
#if DEBUG
    NSLog(@"itemForRow - %@", song.title);
#endif
		BRMenuItem * result = [[[BRMenuItem alloc] init] autorelease];
		[result setText:[song title] withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		[result addAccessoryOfType:0];
		return result;
	}
	
	
}
- (void)itemSelected:(long)selected; { 
	NSLog(@"itemSelected - SongListController");
	if(selected == 0) {
      // Play All
		[self playAll:rootContainer.directories];
	} else if (selected == 1) {
      // Shuffle
		[self playAtIndex:0 withArray:[self.songs shuffledArray]];
	} else {
    PlexMediaObject *mediaObj = [rootContainer.directories objectAtIndex:selected-2];
    if ([@"album" isEqualToString:mediaObj.type]) {
      SongListController *songlist = [[SongListController alloc] initWithPlexContainer:[mediaObj contents] title:mediaObj.name];
      [[[BRApplicationStackManager singleton] stack] pushController:songlist];
      [songlist autorelease];      
    }
    else {
        // Play selected song
      [self playAtIndex:(selected-2) withArray:self.songs];
      
    }
	}
	
}

- (void)playAll:(NSArray *)songContainers {
  NSMutableArray *songList = [[NSMutableArray alloc] initWithCapacity:5];
  
  for (PlexMediaObject *mediaObj in songContainers) {
    if ([[songContainers contents].directories count] > 1) {
      NSLog(@"going subfolder");
      [self convertDirToSongAssets:[mediaObject contents].directories];    
    } 
    
  }
}

- (void)playAtIndex:(NSInteger)index withArray:(NSArray *)songList {
  NSLog(@"playAtIndex: %d", index);
  NSLog(@"playAtIndex: songs count %d", [songList count]);
    //BRTextWithSpinnerController *spinnerController = [[BRTextWithSpinnerController alloc] initWithTitle:@"Buffer" text:@"Getting Stream.."];
    //[[self stack] pushController:spinnerController];
    //[spinnerController release];
  NSError *error;
  
    //BRMediaPlayer *player = [[BRMediaPlayerManager singleton] playerForMediaAsset:pma error:&error];
  BRMediaPlayer *player = [[BRMediaPlayerManager singleton] playerForMediaAssetAtIndex:index inTrackList:songList error:&error];
  [[BRMediaPlayerManager singleton] presentPlayer:player options:nil];	
  
} 
- (id)previewControlForItem:(long)item {	
#if DEBUG  
    //NSLog(@"previewControlForItem - SongListController");
#endif
  
  if(item == 0) {
		return nil;
	} 
  else if (item == 1) {
		return nil;
	} 
  else {
    NSLog(@"rootContainer: %@, dirs: %@", rootContainer, rootContainer.directories);
    PlexMediaObject *mediaObj = [rootContainer.directories objectAtIndex:item -2];
    if ([@"album" isEqualToString:mediaObj.type]) {
      PlexMediaAsset *album = [[PlexMediaAsset alloc] initWithURL:mediaObj.mediaStreamURL mediaProvider:nil mediaObject:mediaObj];
      BRMetadataPreviewControl *preview =[[BRMetadataPreviewControl alloc] init];
      [preview setShowsMetadataImmediately:YES];
      [preview setAsset:album];	
      
      return [preview autorelease];	
    }
    else {
      PlexSongAsset *song = [self.songs objectAtIndex:item -2];
      BRMetadataPreviewControl *preview =[[BRMetadataPreviewControl alloc] init];
      [preview setShowsMetadataImmediately:YES];
      [preview setAsset:song];	
      
      return [preview autorelease];	
    }    
  }
}
- (BOOL)rowSelectable:(long)selectable {
	return YES;
}
- (id)titleForRow:(long)row {
	return nil;
}



@end

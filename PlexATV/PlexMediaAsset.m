//
//  PlexMediaAsset.m
//  atvTwo
//
//  Created by Frank Bauer on 27.10.10.
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

#import "PlexMediaAsset.h"
#import <plex-oss/PlexMediaObject.h>
#import <ambertation-plex/Ambertation.h>

@implementation PlexMediaAsset
- (id) initWithURL:(NSURL*)u mediaProvider:(id)mediaProvider  mediaObject:(PlexMediaObject*)o
{
	pmo = [o retain];
	//self = [super initWithMediaProvider:mediaProvider];
	self = [super init];
	//self = [super initWithMediaItem:s];
	if (self != nil) {
		url = [u retain];
		
		//NSLog(@"Ref = %x", [self mediaItemRef]);
	}
	return self;
}

- (void) dealloc
{
	[pmo release];
	[url release];
	[super dealloc];
}

- (NSString*)assetID{
	NSLog(@"Asset: %@", pmo.key);
	return pmo.key;
}

- (NSString*)mediaURL{
	NSLog(@"Wanted URL %@", [url description]);
	return [url description];
}

-(id)playbackMetadata{
	NSLog(@"Metadata");
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:60], @"duration",
			self.mediaURL, @"mediaURL",
			self.assetID, @"id",
			nil];
}

- (id)mediaType{
	NSLog(@"Checked Type");
	return [BRMediaType movie];
}

-(long int)duration{
	NSLog(@"Duration");
	return [pmo.attributes integerForKey:@"duration"]/1000;
}

- (BOOL)hasVideoContent{
	NSLog(@"Video Content?");
	return YES;
}

- (BOOL)isAvailable{
	NSLog(@"Avail?");
	return YES;
}

- (BOOL)isCheckedOut{
	NSLog(@"CheckedOut?");
	return YES;
}

- (BOOL)isDisabled{
	NSLog(@"Disabled?");
	return NO;
}

- (BOOL)isExplicit{
	NSLog(@"Explicit?");
	return NO;
}

- (BOOL)isHD{
	NSLog(@"HD?");
	return YES;
}

- (BOOL)isInappropriate{
	NSLog(@"Inapprop?");
	return NO;
}

- (BOOL)isLocal{
	NSLog(@"Local?");
	return NO;
}

- (BOOL)isPlaying{
	NSLog(@"Playing = %i", [super isPlaying]);
	return [super isPlaying];
}

- (BOOL)isPlayingOrPaused{
	NSLog(@"PlayingOrPause = %i", [super isPlayingOrPaused]);
	return [super isPlayingOrPaused];
}
- (BOOL)isProtectedContent{
	NSLog(@"Protected?");
	return NO;
}

- (BOOL)isWidescreen{
	NSLog(@"Widescreen?");
	return YES;
}
@end

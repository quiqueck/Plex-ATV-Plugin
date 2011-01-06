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
#import "BackRow/BRBaseMediaAsset.h"
#import <BackRow/BRImageManager.h>
#import "BackRow/BRMediaAsset.h"
#import "PlexMediaAsset.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Machine.h>
#import <ambertation-plex/Ambertation.h>

@implementation PlexMediaAsset
@synthesize pmo;

- (id) initWithURL:(NSURL*)u mediaProvider:(id)mediaProvider  mediaObject:(PlexMediaObject*)o
{
	pmo = [o retain];
    self = [super initWithMediaProvider:mediaProvider];
    //self = [super init];
	//self = [super initWithMediaItem:s];
	if (self != nil) {
		url = [u retain];
		NSLog(@"PMO attrs: %@", pmo.attributes);
    PlexRequest *req = pmo.request;
    NSLog(@"PMO request attrs: %@", req);
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
			[NSNumber numberWithLong:self.duration], @"duration",
			self.mediaURL, @"mediaURL",
			self.assetID, @"id",
			nil];
}

- (id)mediaType{
	NSLog(@"Checked Type");
	return [BRMediaType movie];
}

-(long int)duration{
	NSLog(@"Duration: %d",[pmo.attributes integerForKey:@"duration"]/1000);
	return [pmo.attributes integerForKey:@"duration"]/1000;
}


#pragma mark BRMediaAsset
- (id)provider {
	return nil;
}

- (id)titleForSorting {
  NSLog(@"titleForSorting");
	return pmo.name;
};

-(id)title {
  NSLog(@"title");
  
    if (pmo.hasMedia)
    return pmo.name;
  
    return nil;
}


- (id)previewURL {
	[super previewURL];
	  NSLog(@"previewURL");
  return nil;//[[NSURL fileURLWithPath:[pmo.thumb imagePath]] absoluteString];
};


- (id)imageProxy {
    NSLog(@"imageProxy. art: %@, thumb: %@",[pmo.attributes valueForKey:@"art"], [pmo.attributes valueForKey:@"thumb"] );

  NSString *thumbURL=@"";
  
  if ([pmo.attributes valueForKey:@"art"] != nil)
    thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.attributes valueForKey:@"art"]];
  else if ([pmo.attributes valueForKey:@"thumb"] != nil)
    thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.attributes valueForKey:@"thumb"]];
  
  
  if ([thumbURL empty])
    return nil;
  
  return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
};

- (id)imageProxyWithBookMarkTimeInMS:(unsigned int)fp8 {
    NSLog(@"imageProxyWithBookMarkTimeInMS");
    //	NSString *coverURL = [NSString stringWithFormat:@"http://beta.grooveshark.com/static/amazonart/m%@", [json objectForKey:@"CoverArtFilename"]];
  return nil;//	return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:[pmo.thumb.imagePath]]];
};
- (BOOL)hasCoverArt {
  NSLog(@"art: %@ . thumb: %@",pmo.art,pmo.thumb);
  if (pmo.art || pmo.thumb)
    return YES;
  
  return NO;
};

- (id)trickPlayURL {
	return nil;
};

- (id)artist {
	return nil;
};
- (id)artistForSorting {
	return nil;
};

- (id)AlbumName {
	return nil;
};

- (id)AlbumID {
	return nil;
}

- (id)TrackNum {
	return nil;
};
- (id)composer {
	return nil;
};
- (id)composerForSorting {
	return nil;
};
- (id)copyright {
	return nil;
};
- (void)setUserStarRating:(float)fp8 {
	
};
- (float)starRating {
	return 4;
};

- (BOOL)closedCaptioned {
	return NO;
};
- (BOOL)dolbyDigital {
	return NO;
};
- (long)performanceCount {
	return 1;
};
- (void)incrementPerformanceCount {
	
};
- (void)incrementPerformanceOrSkipCount:(unsigned int)fp8 {
	
};
- (BOOL)hasBeenPlayed {
	return YES;
};
- (void)setHasBeenPlayed:(BOOL)fp8 {
	
};

- (id)playbackRightsOwner {
	return nil;
};
- (id)collections {
	return nil;
};
- (id)primaryCollection {
	return nil;
};
- (id)artistCollection {
	return nil;
};
- (id)primaryCollectionTitle {
	return nil;
};
- (id)primaryCollectionTitleForSorting {
	return nil;
};
- (int)primaryCollectionOrder {
	return 0;
};
- (int)physicalMediaID {
	return 0;
};
- (id)seriesName {
	return @"seriesName";
};
- (id)seriesNameForSorting {
	return nil;
};
- (id)broadcaster {
	return nil;
};

- (id)genres {
	return nil;
};
- (id)dateAcquired {
	return nil;
};
- (id)dateAcquiredString {
	return nil;
};
- (id)dateCreated {
	return nil;
};
- (id)dateCreatedString {
	return nil;
};
- (id)datePublishedString {
	return nil;
};
- (void)setBookmarkTimeInMS:(unsigned int)fp8 {
	
};
- (void)setBookmarkTimeInSeconds:(unsigned int)fp8 {
	
};
- (unsigned int)bookmarkTimeInMS {
	return 1;
};
- (unsigned int)bookmarkTimeInSeconds {
	return 1;
};
- (id)lastPlayed {
	return nil;
};
- (void)setLastPlayed:(id)fp8 {
  
};
- (id)resolution {
	return nil;
};
- (BOOL)canBePlayedInShuffle {
	return YES;
};

- (void)skip {
	
};
- (id)authorName {
	return nil;
};
- (id)keywords {
	return nil;
};
- (id)viewCount {
	return nil;
};
- (id)category {
	return nil;
};

- (int)grFormat {
	return 1;
};
- (void)willBeDeleted {
	NSLog(@"willBeDeleted");
};
- (void)preparePlaybackContext
{
	NSLog(@"preparePlaybackContext");
};
- (void)cleanUpPlaybackContext {
	NSLog(@"cleanUpPlaybackContext");
};
- (long)parentalControlRatingSystemID {
	return 1;
};
- (long)parentalControlRatingRank {
	return 1;
};

- (BOOL)playable {
	return YES;
};

/*
 - (void *)createMovieWithProperties:(void *)fp8 count:(long)fp12 {
 NSLog(@"createMovieWithProperties");
 };
 */

- (id)sourceID {
	return nil;
};
- (id)publisher {
	return nil;
};
- (id)rating {
	return nil;
};
- (id)mediaDescription {
	return pmo.summary;
};
- (id)mediaSummary {
  NSLog(@"mediaSummary: %@",pmo.summary);
  
    if (pmo.summary)
    return pmo.summary;
  
    return nil;
};
- (id)primaryGenre {
	return nil;
};
- (id)datePublished {
	return nil;
};
- (float)userStarRating {
	return 2;
};
- (id)cast {
	return nil;
};
- (id)directors {
	return nil;
};
- (id)producers {
	return nil;
};

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

#pragma mark BRMediaPreviewFactoryDelegate

- (BOOL)mediaPreviewShouldShowMetadata{ 
	return YES;
}
- (BOOL)mediaPreviewShouldShowMetadataImmediately{ 
	return YES;
}



#pragma mark BRImageProvider
- (NSString*)imageID{return nil;}
- (void)registerAsPendingImageProvider:(BRImageLoader*)loader {
	NSLog(@"registerAsPendingImageProvider");
}
- (void)loadImage:(BRImageLoader*)loader{ 
	NSLog(@"load Image");
}


@end

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
#import "PlexSongAsset.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Machine.h>
#import <ambertation-plex/Ambertation.h>

@implementation PlexSongAsset
@synthesize pmo;

- (id) initWithURL:(NSURL*)u mediaProvider:(id)mediaProvider  mediaObject:(PlexMediaObject*)o
{
	self = [super init];
	if (self != nil) {
		pmo = [o retain];
		url = [u retain];
		NSLog(@"PMO attrs: %@", pmo.attributes);
		//PlexRequest *req = pmo.request;
		//NSLog(@"PMO request attrs: %@", req);
		NSLog(@"SongAsset-PMO MediaContainer attrs: %@", pmo.mediaContainer.attributes);
		//NSLog(@"Ref = %x", [self mediaItemRef]);
	}
	return self;
}

- (void) dealloc
{
	NSLog(@"deallocing song asset for %@", pmo.name);
	[pmo release];
	[url release];
	[super dealloc];
}

- (NSString*)assetID{
    NSLog(@"Asset: %@", pmo.key);
	return pmo.key;
}

- (NSString*)mediaURL{
    NSLog(@"track url: %@", [url description]);
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
	return [BRMediaType song];
}

-(long int)duration{
	NSLog(@"Duration: %d, Totaltime: %d",[pmo.attributes integerForKey:@"duration"]/1000, [pmo.attributes integerForKey:@"totalTime"]/1000);

  int _duration = [pmo.attributes integerForKey:@"duration"]/1000;
  if (!(_duration > 0))
    _duration = [pmo.attributes integerForKey:@"totalTime"]/1000;
  
  return _duration;
}


#pragma mark BRMediaAsset
- (id)provider {
	return nil;
}

- (id)titleForSorting {
	return pmo.name;
};

-(id)title {
	return pmo.name;  
}

- (id)mediaDescription {
	return nil;
};

- (id)mediaSummary {
	return nil;
};

- (id)previewURL {
	[super previewURL];
	NSLog(@"previewURL");
	return nil;//[[NSURL fileURLWithPath:[pmo.thumb imagePath]] absoluteString];
};


- (id)imageProxy {
	NSLog(@"imageproxy");
    //NSLog(@"imageProxy. art: %@, thumb: %@",[pmo.attributes valueForKey:@"art"], [pmo.attributes valueForKey:@"thumb"] );
	
	NSString *thumbURL=@"";
	
    //HACK: need to support both regular music and itunes plugin. thumbs are stored in different objects...
	if ([pmo.mediaContainer.attributes valueForKey:@"thumb"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.mediaContainer.attributes valueForKey:@"thumb"]];
		return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
	} 
	else if ([pmo.attributes valueForKey:@"thumb"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.attributes valueForKey:@"thumb"]];
		return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
	}   
	else if ([pmo.mediaContainer.attributes valueForKey:@"art"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.mediaContainer.attributes valueForKey:@"art"]];
		return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
	} 
	else if ([pmo.attributes valueForKey:@"art"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.attributes valueForKey:@"art"]];
		return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
	}	
	else
		return nil;
};

- (id)imageProxyWithBookMarkTimeInMS:(unsigned int)fp8 {
	NSLog(@"imageProxyWithBookMarkTimeInMS");
	NSString *thumbURL=@"";
	
    //HACK: need to support both regular music and itunes plugin. thumbs are stored in different objects...
	if ([pmo.mediaContainer.attributes valueForKey:@"thumb"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.mediaContainer.attributes valueForKey:@"thumb"]];
		return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
	} 
	else if ([pmo.attributes valueForKey:@"thumb"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.attributes valueForKey:@"thumb"]];
		return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
	}   
	else if ([pmo.mediaContainer.attributes valueForKey:@"art"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.mediaContainer.attributes valueForKey:@"art"]];
		return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
	} 
	else if ([pmo.attributes valueForKey:@"art"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.attributes valueForKey:@"art"]];
		return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
	}	
	else
		return nil;};
- (BOOL)hasCoverArt {
		return YES;
};

- (id)trickPlayURL {
	return nil;
};

- (id)artist {
	NSLog(@"artist");
	return [pmo.mediaContainer.attributes valueForKey:@"title1"];
};
- (id)artistForSorting {
    NSLog(@"artistForSorting");
	return [pmo.mediaContainer.attributes valueForKey:@"title1"];
};

- (id)AlbumName {
    NSLog(@"AlbumNAme");
	return [pmo.mediaContainer.attributes valueForKey:@"title2"];
};

- (id)primaryCollectionTitle {
    NSLog(@"primaryCollectionTitle");
	return [pmo.mediaContainer.attributes valueForKey:@"title2"];
};

- (id)AlbumID {
	return nil;
}

- (id)TrackNum {
    NSLog(@"TrackNum");
	return [pmo.attributes valueForKey:@"index"];
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
	return pmo.name;
};
- (id)seriesNameForSorting {
	return pmo.name;
};
- (id)broadcaster {
	return [pmo.attributes valueForKey:@"studio"];
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
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];  
	return [dateFormatter dateFromString:[pmo.attributes valueForKey:@"originallyAvailableAt"]];
};
- (id)dateCreatedString {
	return [pmo.attributes valueForKey:@"originallyAvailableAt"];
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
    return NO;
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
	return NO;
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

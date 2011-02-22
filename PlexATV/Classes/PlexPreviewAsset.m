//
//  PlexPreviewAsset.m
//  atvTwo
//
//  Created by Frank Bauer on 27.10.10.
//  Modified by Bob Jelica & ccjensen
//
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
#import "PlexPreviewAsset.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Machine.h>
#import <ambertation-plex/Ambertation.h>

@interface BRThemeInfo (PlexExtentions)
- (id)storeRentalPlaceholderImage;
@end

@implementation PlexPreviewAsset
@synthesize pmo;

- (id) initWithURL:(NSURL*)u mediaProvider:(id)mediaProvider  mediaObject:(PlexMediaObject*)o
{
    //self = [super initWithMediaProvider:mediaProvider];
    //self = [super streamingMediaAssetWithMediaItem:o];
	self = [super initWithMediaProvider:mediaProvider];
	if (self != nil) {
		pmo = [o retain];
		url = [u retain];
		//NSLog(@"PMO attrs: %@", pmo.attributes);
		//PlexRequest *req = pmo.request;
		//NSLog(@"PMO request attrs: %@", req);
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


#pragma mark -
#pragma mark Helper Methods
- (NSDate *)dateFromPlexDateString:(NSString *)dateString {
	//format is 2001-11-06
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	return [dateFormat dateFromString:dateString];
}

#pragma mark -
#pragma mark BRMediaAsset
//- (void *)createMovieWithProperties:(void *)properties count:(long)count {
//	
//}

- (id)artist {
	if ([pmo.attributes objectForKey:@"artist"])
		return [pmo.attributes objectForKey:@"artist"];
	else
		return [pmo.mediaContainer.attributes valueForKey:@"title1"];
}

- (id)artistCollection {
	return nil;
}

- (id)artistForSorting {
	return self.artist;
}

- (id)assetID {
	return pmo.key;
}

- (id)authorName {
	return nil;
}

- (unsigned int)bookmarkTimeInSeconds {
	return 0;
}

- (void)setBookmarkTimeInSeconds:(unsigned int)fp8 {}

- (unsigned int)bookmarkTimeInMS {
	return 0;
}

- (void)setBookmarkTimeInMS:(unsigned int)fp8 {}

- (id)broadcaster {
	return [pmo.attributes valueForKey:@"studio"];
}

- (BOOL)canBePlayedInShuffle {
	return YES;
}

- (id)cast {
	NSString *result = [pmo listSubObjects:@"Role" usingKey:@"tag"];
	return [result componentsSeparatedByString:@", "];
}

- (id)category {
	return nil;
}

- (void)cleanUpPlaybackContext {}

- (BOOL)closedCaptioned {
	return NO;
}

- (id)collections {
	return nil;
}

- (id)composer {
	return [self authorName];
}

- (id)composerForSorting {
	return [self authorName];
}

- (id)copyright {
	return nil;
}

- (id)coverArt {
  return [BRImage imageWithURL:[self.imageProxy url]];
}

- (id)dateAcquired {
	return [self dateFromPlexDateString:[pmo.attributes valueForKey:@"originallyAvailableAt"]];// [self dateFromPlexDateString:[pmo.attributes valueForKey:@"originallyAvailableAt"]];
}

- (id)dateAcquiredString {
	return [[self dateAcquired] description];
}

- (id)dateCreated {
	return [self dateFromPlexDateString:[pmo.attributes valueForKey:@"originallyAvailableAt"]];// [self dateFromPlexDateString:[pmo.attributes valueForKey:@"originallyAvailableAt"]];
}

- (id)dateCreatedString {
	return [[self dateCreated] description];
}

- (id)datePublished {
	return [self dateFromPlexDateString:[pmo.attributes valueForKey:@"originallyAvailableAt"]];
}

- (id)datePublishedString {
	return [[self datePublished] description];
}

- (id)directors {
	NSString *result = [pmo listSubObjects:@"Director" usingKey:@"tag"];
	return [result componentsSeparatedByString:@", "];
}

- (BOOL)dolbyDigital {
	return NO;
}

-(long int)duration {
	return [pmo.attributes integerForKey:@"duration"]/1000;
}

- (unsigned)episode {
	return [pmo.attributes integerForKey:@"index"];
}

- (id)episodeNumber {
	return [NSString stringWithFormat:@"%d", [self episode]];
}

- (BOOL)forceHDCPProtection {
	return NO;
}

- (id)genres {
	NSString *result = [pmo listSubObjects:@"Genre" usingKey:@"tag"];
	return [result componentsSeparatedByString:@", "];
}

- (int)grFormat {
	return 1;
}

- (BOOL)hasBeenPlayed {
	return YES;
}

- (void)setHasBeenPlayed:(BOOL)fp8 {
	return;
}

- (BOOL)hasCoverArt {
	if (pmo.art || pmo.thumb)
		return YES;	
	return NO;
}

- (BOOL)hasVideoContent {
	return (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType]);
}

- (id)imageProxy {
	NSString *thumbURL = nil;
	
	if ([pmo.attributes valueForKey:@"thumb"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.attributes valueForKey:@"thumb"]];
	}
	else if ([pmo.attributes valueForKey:@"art"] != nil) {
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.attributes valueForKey:@"art"]];
	}
	
	NSURL* turl = [pmo.request pathForScaledImage:thumbURL ofSize:CGSizeMake(512, 512)];
	BRURLImageProxy *imageProxy = [BRURLImageProxy proxyWithURL:turl];
  [imageProxy setDefaultImage:[[BRThemeInfo sharedTheme] storeRentalPlaceholderImage]];
    //NSLog(@"imageProxy_defaultImage: %@",[imageProxy defaultImage]);
	return imageProxy;
}

- (id)imageProxyWithBookMarkTimeInMS:(unsigned int)fp8 {
	return nil;
}

- (void)incrementPerformanceCount {
	return;
}

- (void)incrementPerformanceOrSkipCount:(unsigned)count {
	return;
}

- (BOOL)isAvailable {
	return YES;
}

- (BOOL)isCheckedOut {
	return YES;
}

- (BOOL)isDisabled {
	return NO;
}

- (BOOL)isExplicit {
	return NO;
}

- (BOOL)isHD{
	int videoResolution = [[pmo listSubObjects:@"Media" usingKey:@"videoResolution"] intValue];
	return videoResolution >= 720;
}

- (BOOL)isInappropriate {
	return NO;
}

- (BOOL)isLocal {
	return NO;
}

- (BOOL)isPlaying {
	return [super isPlaying];
}

- (BOOL)isPlayingOrPaused {
	return [super isPlayingOrPaused];
}

- (BOOL)isProtectedContent {
	return NO;
}

- (BOOL)isWidescreen {
	return YES;
}

- (id)keywords {
	return [NSArray arrayWithObject:@"keyword"];
}

- (id)lastPlayed {
	return nil;
}

- (void)setLastPlayed:(id)fp8 {
	return;
}

- (id)mediaDescription {
	return pmo.summary;
}

- (id)mediaSummary {
	if (![pmo.summary empty])
		return pmo.summary;
	else if (pmo.mediaContainer != nil)
		return [pmo.mediaContainer.attributes valueForKey:@"summary"];
	
	return nil;
}

- (id)mediaType {	
	NSString *plexMediaType = [pmo.attributes valueForKey:@"type"];
	BRMediaType *mediaType;
	if ([@"track" isEqualToString:plexMediaType])
		mediaType = [BRMediaType song];
	else if ([@"episode" isEqualToString:plexMediaType])
		mediaType = [BRMediaType TVShow];
	else if (plexMediaType == nil)
		mediaType = nil;
	else 
		mediaType = [BRMediaType movie];
	return mediaType;
}

- (long)parentalControlRatingRank {
	return 1;
}

- (long)parentalControlRatingSystemID {
	return 1;
}

- (long)performanceCount {
	return 0;
}

- (int)physicalMediaID {
	return 0;
}

- (BOOL)playable {
	return YES;
}

-(id)playbackMetadata {
	NSLog(@"Metadata");
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithLong:self.duration], @"duration",
			self.mediaURL, @"mediaURL",
			self.assetID, @"id",
			self.mediaSummary, @"mediaSummary",
			self.mediaDescription, @"mediaDescription",
			self.rating, @"rating",
			self.starRating, @"starRating",
			nil];
}

- (void)setPlaybackMetadataValue:(id)value forKey:(id)key {
	return;
}

- (id)playbackRightsOwner {
	return [pmo.attributes valueForKey:@"studio"];
}

- (void)preparePlaybackContext {}

- (id)previewURL {
	//[super previewURL];
	return nil;//[[NSURL fileURLWithPath:[pmo.thumb imagePath]] absoluteString];
}

- (int)primaryCollectionOrder {
	return 0;
}

- (id)primaryCollectionTitle {
	if ([pmo.attributes objectForKey:@"album"] != nil)
		return [pmo.attributes objectForKey:@"album"];
	else
		return [pmo.mediaContainer.attributes valueForKey:@"title2"];
}

- (id)primaryCollectionTitleForSorting {
	return self.primaryCollectionTitle;
}

- (id)primaryGenre {
	NSArray *allGenres = [self genres];
	BRGenre *result = nil;
	if ([allGenres count] > 0) {
		result = [[[BRGenre alloc] initWithString:[allGenres objectAtIndex:0]] autorelease];
	}
	return result;
}

- (id)producers {
	NSString *result = [pmo listSubObjects:@"Producer" usingKey:@"tag"];
	return [result componentsSeparatedByString:@", "];
}

- (id)provider {
	return nil;
}

- (id)publisher {
	return [self broadcaster];
}

- (id)rating {
	NSString *rating;
	BRMediaType *mediaType = [self mediaType];
	if ([mediaType isEqual:[BRMediaType TVShow]]) {
		rating = [pmo.mediaContainer.attributes objectForKey:@"grandparentContentRating"];
	} else {
		rating = [pmo.attributes objectForKey:@"contentRating"];
	}
	return rating;
}

- (id)resolution {
	return [pmo listSubObjects:@"Media" usingKey:@"videoResolution"];
}

- (unsigned)season {
	int season;
	if ([pmo.attributes objectForKey:@"parentIndex"] == nil) {
		season = [pmo.mediaContainer.attributes integerForKey:@"parentIndex"];
	} else {
		season = [pmo.attributes integerForKey:@"parentIndex"];
	}
	return season;
}

- (id)seriesName {
    //grandparentTitle is usually populated for episodes when coming from dynamic views like "Recently added"
    //whereas mediacontainer.backTitle is used in "All shows->Futurama-Season 1->Episode 4"
	if ([pmo.attributes objectForKey:@"grandparentTitle"] != nil) {
		return [pmo.attributes objectForKey:@"grandparentTitle"];    
	}
	else
		return pmo.mediaContainer.backTitle;
}

- (id)seriesNameForSorting {
	return self.seriesName;
}

- (void)skip {}

- (id)sourceID {
	return nil;
}

- (float)starRating {
	//multiply your rating by 2, then round using Math.Round(rating, MidpointRounding.AwayFromZero), then divide that value by 2.
	float rating = [[pmo.attributes valueForKey:@"rating"] floatValue];
	if (rating > 0) {
		rating = rating / 2; //plex uses 10 based system, atv uses 5 stars
		rating = round(rating * 2.0) / 2.0; //atv supports half stars, so round to nearest half
	}
	return rating;
}

- (unsigned)startTimeInMS {
  NSLog(@"startTimeInMS");
  return [[pmo.attributes valueForKey:@"viewOffset"] intValue];
}

- (unsigned)startTimeInSeconds {
	return [[pmo.attributes valueForKey:@"viewOffset"] intValue] / 1000;
}

- (unsigned)stopTimeInMS {
	return 0;
}

- (unsigned)stopTimeInSeconds {
	return 0;
}

-(id)title {
	NSString *agentAttr = [pmo.attributes valueForKey:@"agent"];
    //  if ([@"movie" isEqualToString:plexMediaType] || [@"show" isEqualToString:plexMediaType] || [@"episode" isEqualToString:plexMediaType] && [agentAttr empty])
	if (agentAttr != nil)
		return nil;
	else
		return pmo.name;
}

- (id)titleForSorting {
	return pmo.name;
}

- (id)trickPlayURL {
	return nil;
}

- (void)setUserStarRating:(float)fp8 {}

- (float)userStarRating {
	return [self starRating];
}

- (id)viewCount {
	return nil;
}

- (void)willBeDeleted {}


#pragma mark -
#pragma mark Additional Metadata Methods
- (BOOL)hasClosedCaptioning {
	return YES;
}

- (BOOL)hasDolbyDigitalAudioTrack {
	return YES;
}

- (NSString *)mediaURL{
    //url = [NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"];
	//NSLog(@"Wanted URL %@", [url description]);	
	return [url description];
}

- (BRImage *)starRatingImage {
	BRImage *result = nil;
	float starRating = [self starRating];
	if (1.0 == starRating) {
		result = [[SMFThemeInfo sharedTheme] oneStar];
		
	} else if (1.5 == starRating) {
		result = [[SMFThemeInfo sharedTheme] onePointFiveStars];
		
	} else if (2 == starRating) {
		result = [[SMFThemeInfo sharedTheme] twoStars];
		
	} else if (2.5 == starRating) {
		result = [[SMFThemeInfo sharedTheme] twoPointFiveStars];
		
	} else if (3 == starRating) {
		result = [[SMFThemeInfo sharedTheme] threeStar];
		
	} else if (3.5 == starRating) {
		result = [[SMFThemeInfo sharedTheme] threePointFiveStars];
		
	} else if (4 == starRating) {
		result = [[SMFThemeInfo sharedTheme] fourStar];
		
	} else if (4.5 == starRating) {
		result = [[SMFThemeInfo sharedTheme] fourPointFiveStars];
		
	} else if (5 == starRating) {
		result = [[SMFThemeInfo sharedTheme] fiveStars];
	}
	return result;
}

- (NSArray *)writers {
	NSString *result = [pmo listSubObjects:@"Writer" usingKey:@"tag"];
	return [result componentsSeparatedByString:@", "];
}

- (NSString *)yearCreated {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy"];
	NSString *yearCreated = [dateFormat stringFromDate:[self dateCreated]];
	[dateFormat release];
	return yearCreated;
}

@end

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
#import "PlexMediaAssetOld.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Machine.h>
#import <ambertation-plex/Ambertation.h>
#import "PlexPreviewAsset.h"

@implementation PlexMediaAssetOld
@synthesize pmo;

- (id) initWithURL:(NSURL*)u mediaProvider:(id)mediaProvider  mediaObject:(PlexMediaObject*)o
{
	//self = [super initWithMediaProvider:mediaProvider];
	//self = [super streamingMediaAssetWithMediaItem:o];
	self = [super initWithMediaProvider:mediaProvider];
	if (self != nil) {
		pmo = [o retain];
		url = [u retain];
		ppa = [[PlexPreviewAsset alloc] initWithURL:url mediaProvider:mediaProvider mediaObject:pmo];
		
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
	[ppa release];
	[super dealloc];
}


#pragma mark -
#pragma mark BRMediaAsset
//- (void *)createMovieWithProperties:(void *)properties count:(long)count {
//	
//}

- (id)artistCollection {
	return [ppa artistCollection];
}

- (id)artistForSorting {
	return [ppa artistForSorting];
}

- (id)assetID {
	return [ppa assetID];
}

- (id)authorName {
	return [ppa authorName];;
}

- (unsigned int)bookmarkTimeInSeconds {
	return [ppa bookmarkTimeInSeconds];
}

- (void)setBookmarkTimeInSeconds:(unsigned int)fp8 {
	[ppa setBookmarkTimeInSeconds:fp8];
}

- (unsigned int)bookmarkTimeInMS {
	return [ppa bookmarkTimeInMS];
}

- (void)setBookmarkTimeInMS:(unsigned int)fp8 {
	[ppa setBookmarkTimeInMS:fp8];
}

- (id)broadcaster {
	return [ppa broadcaster];
}

- (BOOL)canBePlayedInShuffle {
	return [ppa canBePlayedInShuffle];
}

- (id)cast {
	return [ppa cast];
}

- (id)category {
	return [ppa category];
}

- (void)cleanUpPlaybackContext {
	[ppa cleanUpPlaybackContext];
}

- (BOOL)closedCaptioned {
	return [ppa closedCaptioned];
}

- (id)collections {
	return [ppa collections];
}

- (id)composer {
	return [ppa authorName];
}

- (id)composerForSorting {
	return [ppa authorName];
}

- (id)copyright {
	return [ppa copyright];
}

- (id)dateAcquired {
	return [ppa dateAcquired];
}

- (id)dateAcquiredString {
	return [ppa dateAcquiredString];
}

- (id)dateCreated {
	return [ppa dateCreated];
}

- (id)dateCreatedString {
	return [ppa dateCreatedString];
}

- (id)datePublished {
	return [ppa datePublished];
}

- (id)datePublishedString {
	return [ppa datePublishedString];
}

- (id)directors {
	return [ppa directors];
}

- (BOOL)dolbyDigital {
	return [ppa dolbyDigital];
}

-(long int)duration {
	return [ppa duration];
}

- (unsigned)episode {
	return [ppa episode];
}

- (id)episodeNumber {
	return [ppa episodeNumber];
}

- (BOOL)forceHDCPProtection {
	return [ppa forceHDCPProtection];
}

- (id)genres {
	return [ppa genres];
}

- (int)grFormat {
	return [ppa grFormat];
}

- (BOOL)hasBeenPlayed {
	return [ppa hasBeenPlayed];
}

- (void)setHasBeenPlayed:(BOOL)fp8 {
	[ppa setHasBeenPlayed:fp8];
}

- (BOOL)hasCoverArt {
	return [ppa hasCoverArt];
}

- (BOOL)hasVideoContent {
	return [ppa hasVideoContent];
}

- (id)imageProxy {
	return [ppa imageProxy];
}

- (id)imageProxyWithBookMarkTimeInMS:(unsigned int)fp8 {
	return [ppa imageProxyWithBookMarkTimeInMS:fp8];
}

- (void)incrementPerformanceCount {
	[ppa incrementPerformanceCount];
}

- (void)incrementPerformanceOrSkipCount:(unsigned)count {
	[ppa incrementPerformanceOrSkipCount:count];
}

- (BOOL)isAvailable {
	return [ppa isAvailable];
}

- (BOOL)isCheckedOut {
	return [ppa isCheckedOut];
}

- (BOOL)isDisabled {
	return [ppa isDisabled];
}

- (BOOL)isExplicit {
	return [ppa isExplicit];
}

- (BOOL)isHD{
	return [ppa isHD];
}

- (BOOL)isInappropriate {
	return [ppa isInappropriate];
}

- (BOOL)isLocal {
	return [ppa isLocal];
}

- (BOOL)isPlaying {
	return [ppa isPlaying];
}

- (BOOL)isPlayingOrPaused {
	return [ppa isPlayingOrPaused];
}

- (BOOL)isProtectedContent {
	return [ppa isProtectedContent];
}

- (BOOL)isWidescreen {
	return [ppa isWidescreen];
}

- (id)keywords {
	return [ppa keywords];
}

- (id)lastPlayed {
	return [ppa lastPlayed];
}

- (void)setLastPlayed:(id)fp8 {
	[ppa setLastPlayed:fp8];
}

- (id)mediaDescription {
	return [ppa mediaDescription];
}

- (id)mediaSummary {
	return [ppa mediaSummary];
}

- (id)mediaType {
#pragma mark only different one
	return [BRMediaType movie];
}

- (NSString *)mediaURL{
	return [ppa mediaURL];
}

- (long)parentalControlRatingRank {
	return [ppa parentalControlRatingRank];
}

- (long)parentalControlRatingSystemID {
	return [ppa parentalControlRatingSystemID];
}

- (long)performanceCount {
	return [ppa performanceCount];
}

- (int)physicalMediaID {
	return [ppa physicalMediaID];
}

- (BOOL)playable {
	return [ppa playable];
}

-(id)playbackMetadata {
	return [ppa playbackMetadata];
}

- (void)setPlaybackMetadataValue:(id)value forKey:(id)key {
	[ppa setPlaybackMetadataValue:value forKey:key];
}

- (id)playbackRightsOwner {
	return [ppa playbackRightsOwner];
}

- (void)preparePlaybackContext {
	[ppa preparePlaybackContext];
}

- (id)previewURL {
	return [ppa previewURL];
}

- (int)primaryCollectionOrder {
	return [ppa primaryCollectionOrder];
}

- (id)primaryCollectionTitle {
	return [ppa primaryCollectionTitle];
}

- (id)primaryCollectionTitleForSorting {
	return [ppa primaryCollectionTitleForSorting];
}

- (id)primaryGenre {
	return [ppa primaryGenre];
}

- (id)producers {
	return [ppa producers];
}

- (id)provider {
	return [ppa provider];
}

- (id)publisher {
	return [ppa publisher];
}

- (id)rating {
	return [ppa rating];
}

- (id)resolution {
	return [ppa resolution];
}

- (unsigned)season {
	return [ppa season];
}

- (id)seriesName {
	return [ppa seriesName];
}

- (id)seriesNameForSorting {
	return [ppa seriesNameForSorting];
}

- (void)skip {
	[ppa skip];
}

- (id)sourceID {
	return [ppa sourceID];
}

- (float)starRating {
	return [ppa starRating];
}

- (unsigned)startTimeInMS {
	return [ppa startTimeInMS];
}

- (unsigned)startTimeInSeconds {
	return [ppa startTimeInSeconds];
}

- (unsigned)stopTimeInMS {
	return [ppa stopTimeInMS];
}

- (unsigned)stopTimeInSeconds {
	return [ppa stopTimeInSeconds];
}

-(id)title {
	return [ppa title];
}

- (id)titleForSorting {
	return [ppa titleForSorting];
}

- (id)trickPlayURL {
	return [ppa trickPlayURL];
}

- (void)setUserStarRating:(float)fp8 {
	[ppa setUserStarRating:fp8];
}

- (float)userStarRating {
	return [ppa userStarRating];
}

- (id)viewCount {
	return [ppa viewCount];
}

- (void)willBeDeleted {
	return [ppa willBeDeleted];
}

@end

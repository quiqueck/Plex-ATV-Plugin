//
//  HWDetailedMovieMetadataController.m
//  atvTwo
//
//  Created by ccjensen on 2/7/11.
//

#define LOCAL_DEBUG_ENABLED 0

#import "HWDetailedMovieMetadataController.h"
#import "PlexMediaProvider.h"

//these are in the AppleTV.framework, but cannot #import <AppleTV/AppleTV.h> due to
//naming conflicts with Backrow.framework. below is a hack!
@interface BRThemeInfo (PlexExtentions)
- (id)ccBadge;
- (id)hdPosterBadge;
- (id)dolbyDigitalBadge;
@end

@implementation HWDetailedMovieMetadataController
@synthesize rootContainer;
@synthesize selectedMediaItem;
@synthesize selectedMediaItemPreviewData;


- (id) initWithRootContainer:(PlexMediaContainer*)container {
	if (self = [super init]) {
		self.rootContainer = container;
		if ([rootContainer.directories count] > 0) {
			self.selectedMediaItem = [rootContainer.directories objectAtIndex:0];
			self.selectedMediaItemPreviewData = [[PlexPreviewAsset alloc] initWithURL:nil mediaProvider:nil mediaObject:self.selectedMediaItem];
		}
	}
	return self;
}

-(void)dealloc {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"deallocing HWMovieListing");
#endif
	self.selectedMediaItem = nil;
	self.selectedMediaItemPreviewData = nil;
	self.rootContainer = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Delegate Methods
-(void)controller:(SMFMoviePreviewController *)c selectedControl:(BRControl *)ctrl {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"controller selected %@", ctrl);
#endif
}


#pragma mark -
#pragma mark datasource methods
-(NSString *)title {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"title: %@", [self.selectedMediaItemPreviewData title]);
#endif
    return [self.selectedMediaItemPreviewData title];
}

-(NSString *)subtitle {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"subtitle: %@", [self.selectedMediaItemPreviewData broadcaster]);
#endif
    return [self.selectedMediaItemPreviewData broadcaster];
}

-(NSString *)summary {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"summary: %@", [self.selectedMediaItemPreviewData mediaSummary]);
#endif
    return [self.selectedMediaItemPreviewData mediaSummary];
}

-(NSArray *)headers {
    return [NSArray arrayWithObjects:@"Details",@"Actors",@"Director",@"Producers",nil];
}

-(NSArray *)columns {
	//the table will hold all the columns
	NSMutableArray *table = [NSMutableArray array];
	
	
	// ======= details column ======
	NSMutableArray *details = [NSMutableArray array];
	
	BRGenre *genre = [self.selectedMediaItemPreviewData primaryGenre];
	[details addObject:[genre displayString]];
	
	NSString *released = [NSString stringWithFormat:@"Released %@", [self.selectedMediaItemPreviewData yearCreated]];
	[details addObject:released];
	
	NSString *duration = [NSString stringWithFormat:@"%d minutes", [self.selectedMediaItemPreviewData duration]/60];
	[details addObject:duration];
	
	NSMutableArray *badges = [NSMutableArray array];
	if ([self.selectedMediaItemPreviewData isHD])
		[badges addObject:[[BRThemeInfo sharedTheme] hdPosterBadge]];
	if ([self.selectedMediaItemPreviewData hasDolbyDigitalAudioTrack])
		[badges addObject:[[BRThemeInfo sharedTheme] dolbyDigitalBadge]];
	if ([self.selectedMediaItemPreviewData hasClosedCaptioning])
		[badges addObject:[[BRThemeInfo sharedTheme] ccBadge]];
	[details addObject:badges];
	
	BRImage *starRating = [self.selectedMediaItemPreviewData starRatingImage];
	[details addObject:starRating];
	
	[table addObject:details];
	
	
	// ======= actors column ======
	NSArray *actors = [self.selectedMediaItemPreviewData cast];
	[table addObject:actors];
	
	
	// ======= director column ======
	NSMutableArray *directorAndWriters = [NSMutableArray arrayWithArray:[self.selectedMediaItemPreviewData directors]];
	[directorAndWriters addObject:@" "];
	NSAttributedString *subHeadingWriters = [[NSAttributedString alloc]initWithString:@"Writers" attributes:[[BRThemeInfo sharedTheme]metadataSummaryFieldAttributes]];
	[directorAndWriters addObject:subHeadingWriters];
	[subHeadingWriters release];
	[directorAndWriters addObjectsFromArray:[self.selectedMediaItemPreviewData writers]];
	
	[table addObject:directorAndWriters];
	
	
	// ======= producers column ======
	NSArray *producers = [self.selectedMediaItemPreviewData producers];
	[table addObject:producers];
	
	
	// ======= done building table ======
#if LOCAL_DEBUG_ENABLED
	NSLog(@"table: %@", table);
#endif
    return table;
}

-(NSString *)rating {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"rating: %@", [self.selectedMediaItemPreviewData rating]);
#endif
    return [self.selectedMediaItemPreviewData rating];
}

-(BRImage *)coverArt {
	NSString *coverArtPath = [NSString stringWithFormat:@"%@%@",[self.selectedMediaItem.request base], [self.selectedMediaItem.attributes valueForKey:@"thumb"]];
#if LOCAL_DEBUG_ENABLED
	NSLog(@"coverArtPath: %@", coverArtPath);
#endif
	NSURL *coverArtUrl = [NSURL URLWithString:coverArtPath];
    return [BRImage imageWithURL:coverArtUrl];
}

-(BRPhotoDataStoreProvider *)providerForShelf {
    NSSet *_set = [NSSet setWithObject:[BRMediaType photo]];
    NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType photo]];
    BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello" predicate:_pred mediaTypes:_set];
    NSArray *assets = [SMFPhotoMethods mediaAssetsForPath:@"/System/Library/PrivateFrameworks/AppleTV.framework/DefaultFlowerPhotos/"];
    for (id a in assets) {
        [store addObject:a];
    }
    
    id tcControlFactory = [BRPosterControlFactory factory];
    id provider    = [BRPhotoDataStoreProvider providerWithDataStore:store controlFactory:tcControlFactory];
    [store release];
#if LOCAL_DEBUG_ENABLED
	NSLog(@"providerForShelf: %@", provider);
#endif
    return provider;
}

@end

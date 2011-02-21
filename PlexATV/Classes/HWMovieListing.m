//
//  HWMovieListing.m
//  atvTwo
//
//  Created by ccjensen on 2/7/11.
//

#import "HWMovieListing.h"
#import "PlexMediaProvider.h"

@implementation HWMovieListing
@synthesize rootContainer;
@synthesize selectedMediaItem;
@synthesize selectedMediaItemPreviewData;

- (id) init
{
	if((self = [super init]) != nil) {		
		rootContainer = nil;
		selectedMediaItem = nil;
		selectedMediaItemPreviewData = nil;
		return ( self );		
	}
	
	return ( self );
}

- (id) initWithRootContainer:(PlexMediaContainer*)container {
	self = [self init];
	self.rootContainer = container;
	NSLog(@"container: %@", container);
	if ([rootContainer.directories count] > 0) {
		self.selectedMediaItem = [rootContainer.directories objectAtIndex:0];
		NSLog(@"mediaItem: %@", self.selectedMediaItem);
		self.selectedMediaItemPreviewData = [[PlexPreviewAsset alloc] initWithURL:nil mediaProvider:nil mediaObject:self.selectedMediaItem];
	}
	return self;
}

-(void)dealloc
{
	NSLog(@"deallocing HWMovieListing");
	[selectedMediaItem release];
	[selectedMediaItemPreviewData release];
	[rootContainer release];
	
	[super dealloc];
}

#pragma mark datasource methods
-(NSString *)title
{
	NSLog(@"title: %@", [self.selectedMediaItemPreviewData title]);
    return [self.selectedMediaItemPreviewData title];
}

-(NSString *)subtitle
{
	NSLog(@"subtitle: %@", [self.selectedMediaItemPreviewData broadcaster]);
    return [self.selectedMediaItemPreviewData broadcaster];
}

-(NSString *)summary
{
	NSLog(@"summary: %@", [self.selectedMediaItemPreviewData mediaSummary]);
    return [self.selectedMediaItemPreviewData mediaSummary];
}

-(NSArray *)headers
{
	NSLog(@"headers: %@", [NSArray arrayWithObjects:@"Details",@"Actors",@"Director",@"Producers",nil]);
    return [NSArray arrayWithObjects:@"Details",@"Actors",@"Director",@"Producers",nil];
}

-(NSArray *)columns
{
    NSArray *actors = [self.selectedMediaItemPreviewData cast];
    NSArray *directors = [self.selectedMediaItemPreviewData cast];
    NSArray *producers = [self.selectedMediaItemPreviewData cast];
    NSArray *details = [NSArray arrayWithObjects:@"Action & Comedy",@"Released: 2010",@"Run Time: Years",[[SMFThemeInfo sharedTheme]fourPointFiveStars], nil];
    NSArray *objects = [NSArray arrayWithObjects:details,actors,directors,producers,nil];
	NSLog(@"columns: %@", objects);
    return objects;
}

-(NSString *)rating
{
	NSLog(@"rating: %@", [self.selectedMediaItemPreviewData rating]);
    return [self.selectedMediaItemPreviewData rating];
}

-(NSString *)posterPath
{
	NSLog(@"posterPath: %@", [[NSBundle bundleForClass:[self class]]pathForResource:@"PlexIcon" ofType:@"png"]);
    return [[NSBundle bundleForClass:[self class]]pathForResource:@"PlexIcon" ofType:@"png"];
}

-(BRPhotoDataStoreProvider *)providerForShelf
{
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
	NSLog(@"providerForShelf: %@", provider);
    return provider; 
}

@end

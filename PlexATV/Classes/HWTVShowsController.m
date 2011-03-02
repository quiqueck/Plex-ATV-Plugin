//
//  HWTVShowsController.m
//  plex
//
//  Created by ccjensen on 26/02/2011.
//

#import "HWTVShowsController.h"
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexMediaObject.h>
#import "PlexPreviewAsset.h"

@interface BRThemeInfo (PlexExtentions)
- (id)storeRentalPlaceholderImage;
@end

@implementation HWTVShowsController
- (id)initWithPlexAllTVShows:(PlexMediaContainer *)allTVShows {
	if (self = [super init]) {
		tvShows = [allTVShows retain];
		allTvShowsSeasonsPlexMediaContainer = [[NSMutableArray alloc] init];		
		
		self.datasource = self;
		self.delegate = self;
	}
	return self;
}

- (void)dealloc {
	self.datasource = nil;
	self.delegate = nil;
	
	[allTvShowsSeasonsPlexMediaContainer release];
	[tvShows release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark SMFBookcaseController Datasource Methods
- (NSString *)headerTitleForBookcaseController:(SMFBookcaseController *)bookcaseController {
	return @"TV Shows";
}

- (BRImage *)headerIconForBookcaseController:(SMFBookcaseController *)bookcaseController {
	NSString *headerIcon = [[NSBundle bundleForClass:[HWTVShowsController class]] pathForResource:@"PlexTextLogo" ofType:@"png"];
	return [BRImage imageWithPath:headerIcon];
}

- (NSInteger)numberOfShelfsInBookcaseController:(SMFBookcaseController *)bookcaseController {
	[allTvShowsSeasonsPlexMediaContainer removeAllObjects];
	return [tvShows.directories count];
}

- (NSString *)bookcaseController:(SMFBookcaseController *)bookcaseController titleForShelfAtIndex:(NSInteger)index {
	PlexMediaObject *tvshow = [tvShows.directories objectAtIndex:index];
	return tvshow.name;
}

- (BRPhotoDataStoreProvider *)bookcaseController:(SMFBookcaseController *)bookcaseController datastoreProviderForShelfAtIndex:(NSInteger)index {
	NSSet *_set = [NSSet setWithObject:[BRMediaType photo]];
	NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType photo]];
	BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello" predicate:_pred mediaTypes:_set];
	
	
	PlexMediaObject *tvshow = [tvShows.directories objectAtIndex:index];
	PlexMediaContainer *seasonsContainer = [tvshow contents];
	[allTvShowsSeasonsPlexMediaContainer addObject:seasonsContainer];
	NSArray *seasons = [seasonsContainer directories];
	for (PlexMediaObject *season in seasons) {		
		NSURL* mediaURL = [season mediaStreamURL];
		PlexPreviewAsset* ppa = [[PlexPreviewAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:season];
		[store addObject:ppa];
		[ppa release];
	}
	
	SMFControlFactory *controlFactory = [SMFControlFactory posterControlFactory];
	controlFactory.favorProxy = YES;
	controlFactory.defaultImage = [[BRThemeInfo sharedTheme] storeRentalPlaceholderImage];
	
	id provider = [BRPhotoDataStoreProvider providerWithDataStore:store controlFactory:controlFactory];
	[store release];
	return provider; 
}


#pragma mark -
#pragma mark SMFBookcaseController Delegate Methods
-(BOOL)bookcaseController:(SMFBookcaseController *)bookcaseController allowSelectionForShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index {
	DLog(@"allow selection for: %d", index);
	if (index == 1) {
		return NO;
	} else {
		return YES;
	}

}

-(void)bookcaseController:(SMFBookcaseController *)bookcaseController selectionWillOccurInShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index {
	DLog(@"select will occur");
}

-(void)bookcaseController:(SMFBookcaseController *)bookcaseController selectionDidOccurInShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index {
	DLog(@"select did occur");	
}

@end

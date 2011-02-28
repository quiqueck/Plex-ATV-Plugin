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
#pragma mark Plex_SMFBookcaseController Datasource Methods
- (NSString *)headerTitleForBookcaseController:(Plex_SMFBookcaseController *)bookcaseController {
	return @"TV Shows";
}

- (BRImage *)headerIconForBookcaseController:(Plex_SMFBookcaseController *)bookcaseController {
	NSString *headerIcon = [[NSBundle bundleForClass:[HWTVShowsController class]] pathForResource:@"PlexTextLogo" ofType:@"png"];
	return [BRImage imageWithPath:headerIcon];
}

- (NSInteger)numberOfShelfsInBookcaseController:(Plex_SMFBookcaseController *)bookcaseController {
	[allTvShowsSeasonsPlexMediaContainer removeAllObjects];
	return [tvShows.directories count];
}

- (NSString *)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController titleForShelfAtIndex:(NSInteger)index {
	PlexMediaObject *tvshow = [tvShows.directories objectAtIndex:index];
	return tvshow.name;
}

- (BRPhotoDataStoreProvider *)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController datastoreProviderForShelfAtIndex:(NSInteger)index {
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
	
	BRPosterControlFactory *tcControlFactory = [BRPosterControlFactory factory];
	[tcControlFactory setDefaultImage:[[BRThemeInfo sharedTheme] storeRentalPlaceholderImage]];
	
	id provider = [BRPhotoDataStoreProvider providerWithDataStore:store controlFactory:tcControlFactory];
	[store release];
	return provider; 
}


#pragma mark -
#pragma mark Plex_SMFBookcaseController Delegate Methods
-(BOOL)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController allowSelectionForShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index {
	DLog(@"allow selection for: %d", index);
	if (index == 1) {
		return NO;
	} else {
		return YES;
	}

}

-(void)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController selectionWillOccurInShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index {
	DLog(@"select will occur");
}

-(void)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController selectionDidOccurInShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index {
	DLog(@"select did occur");	
}

@end

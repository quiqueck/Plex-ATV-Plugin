//
//  HWTVShowsController.h
//  plex
//
//  Created by ccjensen on 26/02/2011.
//

#import <Foundation/Foundation.h>
#import "Plex_SMFBookcaseController.h"

@class PlexMediaContainer;
@interface HWTVShowsController : Plex_SMFBookcaseController <Plex_SMFBookcaseControllerDatasource, Plex_SMFBookcaseControllerDelegate> {
	PlexMediaContainer *tvShows;
	NSMutableArray *allTvShowsSeasonsPlexMediaContainer;
}

- (id)initWithPlexAllTVShows:(PlexMediaContainer *)allTVShows;

@end

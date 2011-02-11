//
//  HWDetailedMovieMetadataController.h
//  atvTwo
//
//  Created by ccjensen on 2/7/11.
//

#import <Foundation/Foundation.h>
#import <plex-oss/PlexMediaContainer.h>
#import "PlexPreviewAsset.h"

@interface HWDetailedMovieMetadataController : NSObject<SMFMoviePreviewControllerDatasource, SMFMoviePreviewControllerDelegate> {
	PlexMediaContainer* rootContainer;
	PlexMediaObject* selectedMediaItem;
	PlexPreviewAsset *selectedMediaItemPreviewData;
}
@property (readwrite, retain) PlexMediaContainer* rootContainer;
@property (retain) PlexMediaObject *selectedMediaItem;
@property (retain) PlexPreviewAsset *selectedMediaItemPreviewData;

- (id) initWithRootContainer:(PlexMediaContainer*)container;

@end


/* code to instantiate one of these views, where [pmo contents] is a container full of movies
 SMFMoviePreviewController* menuController = [[SMFMoviePreviewController alloc] init];
 HWMovieListing *dataSource = [[HWMovieListing alloc] initWithRootContainer:[pmo contents]];
 menuController.datasource = dataSource;
 
 [[[BRApplicationStackManager singleton] stack] pushController:menuController];
 [menuController autorelease];
*/
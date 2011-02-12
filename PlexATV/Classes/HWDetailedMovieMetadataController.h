//
//  HWDetailedMovieMetadataController.h
//  atvTwo
//
//  Created by ccjensen on 2/7/11.
//

#import <Foundation/Foundation.h>
#import <plex-oss/PlexMediaContainer.h>
#import "PlexPreviewAsset.h"

@interface HWDetailedMovieMetadataController : SMFMoviePreviewController<SMFMoviePreviewControllerDatasource, SMFMoviePreviewControllerDelegate> {
	PlexMediaContainer *_container;
	NSArray *_mediaObjects;
	NSArray *_assets;
	BRMediaShelfControl *mediaShelfControl;
	
	int selectedIndex;
	PlexMediaObject *selectedMediaItem;
	PlexPreviewAsset *selectedMediaItemPreviewData;
}
@property (retain) PlexMediaContainer *container;
@property (retain) NSArray *mediaObjects;
@property (retain) NSArray *assets;

@property (retain) PlexMediaObject *selectedMediaItem;
@property (retain) PlexPreviewAsset *selectedMediaItemPreviewData;

- (id) initWithPlexContainer:(PlexMediaContainer*)aContainer;
- (NSArray *)assetsForMediaObjects:(NSArray *)mediaObjects;

@end
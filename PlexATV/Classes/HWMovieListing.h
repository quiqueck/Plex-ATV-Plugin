//
//  HWMovieListing.h
//  atvTwo
//
//  Created by ccjensen on 2/7/11.
//

#import <Foundation/Foundation.h>
#import <plex-oss/PlexMediaContainer.h>
#import "PlexPreviewAsset.h"

@interface HWMovieListing : SMFMoviePreviewController<SMFMoviePreviewControllerDatasource> {
	PlexMediaContainer* rootContainer;
	NSTimer* playProgressTimer;
	PlexMediaObject* selectedMediaItem;
	PlexPreviewAsset *selectedMediaItemPreviewData;
}
@property (readwrite, retain) PlexMediaContainer* rootContainer;
@property (retain) PlexMediaObject *selectedMediaItem;
@property (retain) PlexPreviewAsset *selectedMediaItemPreviewData;

- (id) initWithRootContainer:(PlexMediaContainer*)container;

@end

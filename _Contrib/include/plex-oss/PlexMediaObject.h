//
//  PlexMediaObject.h
//  PlexPad
//
//  Created by Frank Bauer on 17.04.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlexDirectory.h"
typedef int PlexMediaObjectSeenState;
extern const PlexMediaObjectSeenState PlexMediaObjectSeenStateSeen;
extern const PlexMediaObjectSeenState PlexMediaObjectSeenStateUnseen;
extern const PlexMediaObjectSeenState PlexMediaObjectSeenStateInProgress;

typedef NSString* PlexMediaObjectTypes;
extern const PlexMediaObjectTypes PlexMediaObjectTypeMovie;
extern const PlexMediaObjectTypes PlexMediaObjectTypeSeason;
extern const PlexMediaObjectTypes PlexMediaObjectTypeShow;
extern const PlexMediaObjectTypes PlexMediaObjectTypeEpisode;
extern const PlexMediaObjectTypes PlexMediaMediaTypeImage;
extern const PlexMediaObjectTypes PlexMediaMediaTypeMovie;
@protocol NSURLLoadOperationDelegate;
@protocol PlexPosterView;
@protocol BackgroundOperationDelegate;

@class LoadPlexObjectBackgroundContentOperation,LoadURLOperation;
@interface PlexMediaObject : PlexDirectory{
	NSString* ratingKey;
	NSTimeInterval duration;
	NSDate* originallyAvailableAt;
	NSString* summary;
	PlexMediaObjectTypes type;
	UIView* popoverView;
	
	PlexImage* thumb;
	PlexImage* art;
	PlexImage* banner;
	
	BOOL popup;

	PlexMediaContainer* popupContainer;
}

@property (readwrite, retain) PlexImage* thumb;
@property (readwrite, retain) PlexImage* art;
@property (readwrite, retain) PlexImage* banner;
@property (readonly) BOOL popup;
@property (readonly) PlexMediaContainer* popupContainer;	
@property (readonly) BOOL search;
@property (readonly) NSString* summary;
@property (readonly) NSString* ratingKey;
@property (readonly) NSString* imageRatingKey;
@property (readonly) NSString* historyImageRatingKey;
@property (readonly) PlexMediaObjectTypes type;
@property (readwrite, assign) UIView* popoverView;
@property (readonly) PlexMediaObject* parentObject;

@property (readonly) BOOL isMovie;
@property (readonly) BOOL isVideo;
@property (readonly) BOOL isEpisode;
@property (readonly) BOOL isSeason;
@property (readonly) BOOL isTVShow;
	
//Episode Stuff
@property (readonly) NSTimeInterval duration;
@property (readonly) NSDate* originallyAvailableAt;

-(id)initWithAttributes:(NSDictionary*)dict parentMediaContainer:(PlexMediaContainer*)mc parentObject:(PlexMediaObject*)pmo containerType:(NSString*)ct;
-(PlexMediaContainer*)contents;
-(LoadURLOperation*)asyncContentsNotify:(id<NSURLLoadOperationDelegate>)opDelegate;
-(void)processReceivedContents:(PlexMediaContainer*)contents;
-(LoadPlexObjectBackgroundContentOperation*)loadContentAndNotify:(id<BackgroundOperationDelegate>)objOrNil;

-(void)postMediaProgress:(NSTimeInterval)tm;
-(PlexMediaContainer*)loadDetails;

-(BOOL)canPlayOnDevicePredicate;
-(BOOL)canPlayOnPlexPredicate;
-(BOOL)canPlayWithoutTranscoder;
-(BOOL)localFile;

-(NSURL*)mediaURL;
-(NSURL*)mediaStreamURL;
-(NSURL*)mediaPlexPlayURL;
-(NSURL*)audioPlexPlayURL;

-(int)rating;
-(PlexMediaObjectSeenState)seenState;

-(void)markSeen;
-(void)markSeenLocal;
-(void)markUnseen;
-(void)markUnseenLocal;
-(void)_updateParentSeenState;
-(void)rateWith:(int)rating;

-(PlexMediaContainer*)imageResourcesOfKind:(NSString*)kind;
-(void)setAsImageRessource:(NSString*)kind;

-(PlexMediaContainer*)matches;
-(PlexMediaContainer*)banners;
-(PlexMediaContainer*)posters;
-(PlexMediaContainer*)artworks;

-(void)setAsPoster;
-(void)setAsBanner;
-(void)setAsArt;
-(void)setAsMatch;

-(BOOL)shouldRemoveForRating:(const ContentRating)cr;

-(void)updateRequest:(PlexRequest*)req;
@end

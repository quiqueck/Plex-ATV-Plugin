//
//  PlexMediaObject.h
//  PlexPad
//
//  Created by Frank Bauer on 17.04.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlexDirectory.h"
#import "DownloadOrPlayViewControllerDelegate.h"
#import "PlaybackWhereViewControllerDelegate.h"

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
@interface PlexMediaObject : PlexDirectory<PlaybackWhereViewControllerDelegate, DownloadOrPlayViewControllerDelegate> {
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
@property (readonly) PlexMediaObjectTypes type;
@property (readwrite, assign) UIView* popoverView;
@property (readonly) PlexMediaObject* parentObject;
	
//Episode Stuff
@property (readonly) NSTimeInterval duration;
@property (readonly) NSDate* originallyAvailableAt;

-(id)initWithAttributes:(NSDictionary*)dict parentMediaContainer:(PlexMediaContainer*)mc parentObject:(PlexMediaObject*)pmo containerType:(NSString*)ct;
-(PlexMediaContainer*)contents;
-(LoadURLOperation*)asyncContentsNotify:(id<NSURLLoadOperationDelegate>)opDelegate;
-(void)processReceivedContents:(PlexMediaContainer*)contents;
-(LoadPlexObjectBackgroundContentOperation*)loadContentAndNotify:(id<BackgroundOperationDelegate>)objOrNil;

-(IBAction)openMenuScreen:(UIView*)container;
-(void)openMenu;
-(void)postMediaProgress:(NSTimeInterval)tm;
-(void)openWithoutAskDownload:(UIView<PlexPosterView>*)sender;
-(IBAction)open:(UIView<PlexPosterView>*)sender;
-(void)playInPlex;
-(IBAction)playOnDevice;
-(void)makeAvailableOffline;
-(PlexMediaContainer*)loadDetails;

-(BOOL)canPlayOnDevice;
-(BOOL)canPlayOnPlex;
-(NSURL*)mediaStreamURL;
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
@end

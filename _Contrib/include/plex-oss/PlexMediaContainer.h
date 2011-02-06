//
//  PlexMediaContainer.h
//  PlexPad
//
//  Created by Frank Bauer on 17.04.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlexObject.h"
#import "PlexMediaObject.h"
@class PlexRequest;


typedef NSUInteger PlexViewModes;
extern const PlexViewModes PlexViewModeUndefined;
extern const PlexViewModes PlexViewModeList;
extern const PlexViewModes PlexViewModeInfoList;
extern const PlexViewModes PlexViewModeMediaPreview;
extern const PlexViewModes PlexViewModeShowcase;
extern const PlexViewModes PlexViewModeCoverflow;
extern const PlexViewModes PlexViewModePanelStream;
extern const PlexViewModes PlexViewModeWallStream;
extern const PlexViewModes PlexViewModeSongs;
extern const PlexViewModes PlexViewModeSeasons;
extern const PlexViewModes PlexViewModeAlbums;
extern const PlexViewModes PlexViewModeEpisodes;
extern const PlexViewModes PlexViewModeImageStream;
extern const PlexViewModes PlexViewModePictures;
extern const PlexViewModes PlexViewModeIcons;

typedef NSString* PlexViewGroups;
extern const PlexViewGroups PlexViewGroupMovie;
extern const PlexViewGroups PlexViewGroupShow;
extern const PlexViewGroups PlexViewGroupSecondary;
extern const PlexViewGroups PlexViewGroupSeason;
extern const PlexViewGroups PlexViewGroupEpisode;
extern const PlexViewGroups PlexViewGroupStoreInfo;
extern const PlexViewGroups PlexViewGroupInfoGrid;
extern const PlexViewGroups PlexViewGroupStoreEntry;
extern const PlexViewGroups PlexViewGroupEvent;
extern const PlexViewGroups PlexViewGroupSong;
extern const PlexViewGroups PlexViewGroupArtist;
extern const PlexViewGroups PlexViewGroupAlbum;
extern const PlexViewGroups PlexViewGroupTrack;

typedef NSString* PlexFlagTypes;
extern const PlexFlagTypes PlexFlagTypeStudio;
extern const PlexFlagTypes PlexFlagTypeContentRating;
extern const PlexFlagTypes PlexFlagTypeContentVideoCodec;
extern const PlexFlagTypes PlexFlagTypeContentVideoFrameRate;
extern const PlexFlagTypes PlexFlagTypeContentAudioCodec;
extern const PlexFlagTypes PlexFlagTypeContentVideoResolution;
extern const PlexFlagTypes PlexFlagTypeContentAudioChannels;
extern const PlexFlagTypes PlexFlagTypeContentAspectRation;

typedef NSString* PlexClontentType;
extern const PlexClontentType PlexContentSongs;

struct _PlexMediaContainerFlags{
	BOOL hasSummaries:1;
	BOOL hasPopups:1;
	BOOL hasThumbs:1;
	BOOL hasMedia:1;
	BOOL hasOnlyShows:1;
	BOOL hasImages:1;
	BOOL replaceParent:1;
	BOOL sectionRoot:1;
	
	BOOL multipleSeasons:1;
	BOOL multipleShows:1;
	BOOL rootNode:1;
	BOOL searchResultContainer:1;
	BOOL hasOnlyEpisodes:1;
	BOOL hasOnlyMovies:1;
	BOOL hasPhotos:1;
	BOOL hasMatches:1;
};
typedef struct _PlexMediaContainerFlags PlexMediaContainerFlags;


@interface PlexMediaContainer : PlexObject<NSXMLParserDelegate> {
	id formatter;
	NSMutableArray* directories;
	PlexMediaContainer* parentFilterContainer;
	PlexRequest* request;
	PlexMediaObject* parentObject;
	//id<PlexDataPresenter> formatter;

	NSString* backTitle;
	
	NSString* header;
	NSString* message;
	NSString* identifier;
	
	PlexMediaContainerFlags flags;
	
	PlexViewModes viewMode;
	PlexViewGroups viewGroup;
	
	NSString* mediaTagPrefix;
	NSString* mediaTagVersion;
	
	PlexClontentType content;
	
	PlexImage* thumb;
	PlexImage* art;
	PlexImage* banner;
}

@property (readwrite, retain) PlexImage* thumb;
@property (readwrite, retain) PlexImage* art;
@property (readwrite, retain) PlexImage* banner;
	

@property (readonly) PlexMediaObject* parentObject;
@property (readonly) PlexMediaContainer* parentFilterContainer;
@property (readonly) NSMutableArray* directories;
@property (readonly) PlexRequest* request;
@property (readonly) NSString* baseKey;
@property (readwrite, retain) NSString* currentTitle;
@property (readwrite, retain) NSString* backTitle;
@property (readonly) NSString* header;
@property (readonly) NSString* message;
@property (readonly) NSString* identifier;
@property (readonly) NSString* imageRatingKey;
@property (readonly) BOOL requestsMessage;
@property (readonly) BOOL replaceParent;
@property (readonly) BOOL hasSummaries;
@property (readonly) BOOL hasPopups;
@property (readonly) BOOL hasThumbs;
@property (readonly) BOOL hasMedia;
@property (readonly) BOOL hasOnlyShows;
@property (readonly) BOOL hasOnlyEpisodes;
@property (readonly) BOOL hasImages;
@property (readwrite) BOOL sectionRoot;
@property (readonly) BOOL leafeNode;
@property (readonly) BOOL multipleSeasons;
@property (readonly) BOOL multipleShows;
@property (readwrite) BOOL rootNode;
@property (readonly) BOOL searchResultContainer;

@property (readonly) PlexViewModes viewMode;
@property (readonly) PlexViewGroups viewGroup;
@property (readonly) NSString* mediaTagPrefix;
@property (readonly) NSString* mediaTagVersion;
@property (readonly) PlexClontentType content;





-(id)initWithRequest:(PlexRequest*)req baseKey:(NSString*)bk fromObject:(PlexMediaObject*)pmo;
-(void)didReceiveMemoryWarning;
-(void)freeBannersAndArt;
-(void)updateRequest:(PlexRequest*)req;
	
-(PlexMediaContainer*)reload;
-(void)loadAllThumbnailsInBackground;
-(PlexMediaObject*)findEqualObject:(PlexObject*)o;

-(PlexImage*)flagForType:(PlexFlagTypes)type named:(NSString*)name;

-(void)setKey:(NSString*)v;
-(PlexMediaContainer*)searchFor:(NSString*)q;
	
-(PlexMediaObject*)findEqualObject:(PlexObject*)o;
-(PlexMediaObject*)findObjectWithKey:(const NSString*)objKey;
-(PlexMediaObject*)findObjectWithLastKey:(const NSString*)objKey;
-(void)reloadAttributes;
@end
	

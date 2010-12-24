//
//  PlexMediaContainer.h
//  PlexPad
//
//  Created by Frank Bauer on 17.04.10.
//  Copyright 2010 F. Bauer. All rights reserved.
//
// Redistribution and use of the code or any derivative works are 
// permitted provided that the following conditions are met:
//   - Redistributions may not be sold, nor may they be used in 
//     a commercial product or activity.
//   - Redistributions must reproduce the above copyright notice, 
//     this list of conditions and the following disclaimer in the 
//     documentation and/or other materials provided with the 
//     distribution.
//   - It is not permitted to redistribute a modified version of 
//     this file
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>
#import "PlexObject.h"
#import "PlexMediaObject.h"
@class PlexRequest;
@protocol PlexDataPresenter;
@protocol ListViewCellProtocol;
@protocol BookPageView;

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

#ifdef __IPHONE_4_0
@interface PlexMediaContainer : PlexObject<NSXMLParserDelegate> {
#else
@interface PlexMediaContainer : PlexObject {
#endif
	NSMutableArray* directories;
	PlexMediaContainer* parentFilterContainer;
	PlexRequest* request;
	PlexMediaObject* parentObject;
	id<PlexDataPresenter> formatter;

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


-(Class<ListViewCellProtocol>)listViewCellClassForOrientation:(UIInterfaceOrientation)io;


-(id)initWithRequest:(PlexRequest*)req baseKey:(NSString*)bk fromObject:(PlexMediaObject*)pmo;
-(void)didReceiveMemoryWarning;
-(void)freeBannersAndArt;
	
-(void)displayMessage;
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
	
#import "PlexMediaContainer + SkinResources.h"

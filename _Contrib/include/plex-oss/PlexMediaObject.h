//
//  PlexMediaObject.h
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

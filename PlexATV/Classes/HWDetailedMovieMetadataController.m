//
//  HWDetailedMovieMetadataController.m
//  atvTwo
//
//  Created by ccjensen on 2/7/11.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

#define LOCAL_DEBUG_ENABLED 1

#import "HWDetailedMovieMetadataController.h"
#import "PlexMediaProvider.h"

//these are in the AppleTV.framework, but cannot #import <AppleTV/AppleTV.h> due to
//naming conflicts with Backrow.framework. below is a hack!
@interface BRThemeInfo (PlexExtentions)
- (id)ccBadge;
- (id)hdPosterBadge;
- (id)dolbyDigitalBadge;
- (id)storeRentalPlaceholderImage;
@end

@implementation HWDetailedMovieMetadataController
@synthesize assets;
@synthesize selectedMediaItemPreviewData;

+ (NSArray *)assetsForMediaObjects:(NSArray *)mObjects {
	NSMutableArray *newAssets = [NSMutableArray arrayWithCapacity:[mObjects count]];
	
	for (PlexMediaObject *mediaObj in mObjects) {		
		NSURL* mediaURL = [mediaObj mediaStreamURL];
		PlexPreviewAsset* pma = [[PlexPreviewAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:mediaObj];
		[newAssets addObject:pma];
		[pma release];
	}
	
#if LOCAL_DEBUG_ENABLED
	NSLog(@"converted %d assets", [newAssets count]);
#endif
	return newAssets;
}

- (id)initWithPreviewAssets:(NSArray*)previewAssets withSelectedIndex:(int)selIndex {
	if (self = [super init]) {
		self.assets = previewAssets;
#if LOCAL_DEBUG_ENABLED
    NSLog(@"init with asset count:%d and index:%d", [self.assets count], selIndex);
#endif
		if ([self.assets count] > selIndex) {
			selectedIndex = selIndex;
			self.selectedMediaItemPreviewData = [self.assets objectAtIndex:selectedIndex];
		} else if ([self.assets count] > 0) {
			selectedIndex = 0;
			self.selectedMediaItemPreviewData = [self.assets objectAtIndex:selectedIndex];
		} else {
			//fail, container has no items
		}
		
		self.datasource = self;
		self.delegate = self;
    
#if LOCAL_DEBUG_ENABLED
    NSLog(@"init done. assets rigged");
#endif
	}
	return self;
}

- (id)initWithPlexContainer:(PlexMediaContainer*)aContainer withSelectedIndex:(int)selIndex {
	NSArray *previewAssets = [HWDetailedMovieMetadataController assetsForMediaObjects:aContainer.directories];	
	return [self initWithPreviewAssets:previewAssets withSelectedIndex:selIndex];
}

-(void)dealloc {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"deallocing HWMovieListing");
#endif
	self.assets = nil;
	self.selectedMediaItemPreviewData = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Delegate Methods
-(void)controller:(SMFMoviePreviewController *)c selectedControl:(BRControl *)ctrl {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"controller selected %@", ctrl);
#endif
	if ([ctrl isKindOfClass:[BRButtonControl class]]) {
		//one of the buttons have been pushed
		BRButtonControl *buttonControl = (BRButtonControl *)ctrl;
//		[self _changeFocusTo:mediaShelfControl];
//		[mediaShelfControl _scrollIndexToVisible:selectedIndex];
//		[mediaShelfControl _restoreLastSelection];
		
	} else if ([ctrl isKindOfClass:[BRMediaShelfControl class]]) {
		//one of the other media items have been selected
		BRMediaShelfControl *mediaShelfControl = (BRMediaShelfControl *)ctrl;
		selectedIndex = mediaShelfControl.focusedIndex;
		
		self.selectedMediaItemPreviewData = [self.assets objectAtIndex:selectedIndex];
		
		//[mediaShelfControl _saveCurrentSelection];
		
		//refresh
		[self _removeAllControls];
		[self drawSelf];
		mediaShelfControl = [self valueForKey:@"_shelfControl"];
		[mediaShelfControl _scrollIndexToVisible:selectedIndex];
		//wanted to reset selection to the one selected, but does not seem to work
		//[self _changeFocusTo:mediaShelfControl];
		//[mediaShelfControl _loadControlAtIndex:selectedIndex];
	}
}


#pragma mark -
#pragma mark datasource methods
-(NSString *)title {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"title: %@", [self.selectedMediaItemPreviewData title]);
#endif
	return [self.selectedMediaItemPreviewData title];
}

-(NSString *)subtitle {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"subtitle: %@", [self.selectedMediaItemPreviewData broadcaster]);
#endif
	return [self.selectedMediaItemPreviewData broadcaster];
}

-(NSString *)summary {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"summary: %@", [self.selectedMediaItemPreviewData mediaSummary]);
#endif
	return [self.selectedMediaItemPreviewData mediaSummary];
}

-(NSArray *)headers {
	return [NSArray arrayWithObjects:@"Details",@"Actors",@"Director",@"Producers",nil];
}

-(NSArray *)columns {
	//the table will hold all the columns
	NSMutableArray *table = [NSMutableArray array];
	
	// ======= details column ======
	NSMutableArray *details = [NSMutableArray array];
	
	BRGenre *genre = [self.selectedMediaItemPreviewData primaryGenre];
	[details addObject:[genre displayString]];
	
	NSString *released = [NSString stringWithFormat:@"Released %@", [self.selectedMediaItemPreviewData yearCreated]];
	[details addObject:released];
	
	NSString *duration = [NSString stringWithFormat:@"%d minutes", [self.selectedMediaItemPreviewData duration]/60];
	[details addObject:duration];
	
	NSMutableArray *badges = [NSMutableArray array];
	if ([self.selectedMediaItemPreviewData isHD])
		[badges addObject:[[BRThemeInfo sharedTheme] hdPosterBadge]];
	if ([self.selectedMediaItemPreviewData hasDolbyDigitalAudioTrack])
		[badges addObject:[[BRThemeInfo sharedTheme] dolbyDigitalBadge]];
	if ([self.selectedMediaItemPreviewData hasClosedCaptioning])
		[badges addObject:[[BRThemeInfo sharedTheme] ccBadge]];
	[details addObject:badges];
	
	BRImage *starRating = [self.selectedMediaItemPreviewData starRatingImage];
	[details addObject:starRating];
	
	[table addObject:details];
	
	
	// ======= actors column ======
	NSArray *actors = [self.selectedMediaItemPreviewData cast];
	[table addObject:actors];
	
	
	// ======= director column ======
	NSMutableArray *directorAndWriters = [NSMutableArray arrayWithArray:[self.selectedMediaItemPreviewData directors]];
	[directorAndWriters addObject:@" "];
	NSAttributedString *subHeadingWriters = [[NSAttributedString alloc]initWithString:@"Writers" attributes:[[BRThemeInfo sharedTheme]metadataSummaryFieldAttributes]];
	[directorAndWriters addObject:subHeadingWriters];
	[subHeadingWriters release];
	[directorAndWriters addObjectsFromArray:[self.selectedMediaItemPreviewData writers]];
	
	[table addObject:directorAndWriters];
	
	
	// ======= producers column ======
	NSArray *producers = [self.selectedMediaItemPreviewData producers];
	[table addObject:producers];
	
	
	// ======= done building table ======
#if LOCAL_DEBUG_ENABLED
	NSLog(@"table: %@", table);
#endif
	return table;
}

-(NSString *)rating {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"rating: %@", [self.selectedMediaItemPreviewData rating]);
#endif
	return [self.selectedMediaItemPreviewData rating];
}

-(BRImage *)coverArt {
	BRImage *coverArt = nil;
	if ([self.selectedMediaItemPreviewData hasCoverArt]) {
		NSString *coverArtPath = [NSString stringWithFormat:@"%@%@",[self.selectedMediaItemPreviewData.pmo.request base], [self.selectedMediaItemPreviewData.pmo.attributes valueForKey:@"thumb"]];
#if LOCAL_DEBUG_ENABLED
		NSLog(@"coverArtPath: %@", coverArtPath);
#endif
		NSURL *coverArtUrl = [NSURL URLWithString:coverArtPath];
		coverArt = [BRImage imageWithURL:coverArtUrl];
	}
	return coverArt;
}

-(NSArray *)buttons {
	// built-in images:
	// deleteActionImage, menuActionUnfocusedImage, playActionImage,
	// previewActionImage, queueActionImage, rateActionImage
    NSMutableArray *buttons = [NSMutableArray array];
    BRButtonControl* b = [[BRButtonControl actionButtonWithImage:[[BRThemeInfo sharedTheme]previewActionImage] 
                                                        subtitle:@"Preview" 
                                                           badge:nil] retain];
    [buttons addObject:b];
    
    b = [[BRButtonControl actionButtonWithImage:[[BRThemeInfo sharedTheme]playActionImage] 
                                       subtitle:@"Play"
                                          badge:nil]retain];
    
    [buttons addObject:b];
    
    b = [[BRButtonControl actionButtonWithImage:[[BRThemeInfo sharedTheme]queueActionImage] 
                                       subtitle:@"Queue" 
                                          badge:nil]retain];
    
    [buttons addObject:b];
    
    b = [[BRButtonControl actionButtonWithImage:[[BRThemeInfo sharedTheme]rateActionImage] 
                                       subtitle:@"More" 
                                          badge:nil]retain];
    [buttons addObject:b];
    return buttons;
    
}

-(BRPhotoDataStoreProvider *)providerForShelf {
	NSSet *_set = [NSSet setWithObject:[BRMediaType photo]];
	NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType photo]];
	BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello" predicate:_pred mediaTypes:_set];
	
	for (PlexPreviewAsset *asset in self.assets) {
		[store addObject:asset];
	}
	
	BRPosterControlFactory *tcControlFactory = [BRPosterControlFactory factory];
	[tcControlFactory setDefaultImage:[[BRThemeInfo sharedTheme] storeRentalPlaceholderImage]];
	
	id provider = [BRPhotoDataStoreProvider providerWithDataStore:store controlFactory:tcControlFactory];
	[store release];
#if LOCAL_DEBUG_ENABLED
	NSLog(@"providerForShelf: %@", provider);
#endif
	return provider;
}

@end

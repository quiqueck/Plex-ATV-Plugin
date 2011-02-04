//
//  PlexImage.h
//  PlexPad
//
//  Created by Frank Bauer on 17.04.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MemoryImage.h"

typedef NSUInteger PlexImageType;
extern const PlexImageType PlexImageTypeUnknown;
extern const PlexImageType PlexImageTypeThumbnail;
extern const PlexImageType PlexImageTypeArtwork;
extern const PlexImageType PlexImageTypeBanner;
extern const PlexImageType PlexImageTypePhoto;
extern const PlexImageType PlexImageTypeFlag;
extern const PlexImageType PlexImageTypeIcon;
extern const PlexImageType PlexImageTypeOfflineThumbnail;

//we need this, to better perform on the shelfView
@protocol BackgroundOperationDelegate;
@class PlexImage;
@protocol TraceableLayerProtocol<NSObject>
@property (readwrite, nonatomic) BOOL isVisibleOnShelf;
@property (readwrite) BOOL waitsForImage;
@property (readwrite, assign, nonatomic) PlexImage* attachedImage;
//CALayer
@property(retain) id contents;
@property CGRect frame;
@property CGPoint position;
@end

@class Machine, BackgroundOperation;

@interface PlexImage : MemoryObject {
    Machine* machine;
    PlexImageType type;
    NSString* ratingKey;
    NSString* uid;
    
	BOOL didLoadImage, lowPriority;
	CGSize maxImageSize;
	NSURL* imageURL;
    
    
	MemoryImage* image;
	
	id<TraceableLayerProtocol> layer;
	UIImageView* imageView;
	BOOL cancelBackgroundLoad;
	BackgroundOperation* backgroundOperation;
}

@property (readwrite, assign) Machine* machine;
@property (readwrite, assign) BackgroundOperation* backgroundOperation;
@property (readonly) BOOL hasImage;
@property (readonly) BOOL didLoadImage;
@property (readwrite) BOOL lowPriority;
@property (readonly, retain) MemoryImage* image;
@property (readonly) UIImage* saveImage;
@property (readonly) NSURL* imageURL;
@property (readonly) NSString* ratingKey;
@property (readonly) NSString* uid;
@property (readonly) PlexImageType type;
@property (readonly) NSString* version;
@property (readonly) NSString* hostMachine;
@property (readonly) NSString* relativePath;
@property (readwrite) CGSize maxImageSize;
@property (readwrite, retain, nonatomic) id<TraceableLayerProtocol> layer;
@property (readwrite, retain) UIImageView* imageView;
@property (readwrite) BOOL cancelBackgroundLoad;;

+(void)freeCache;
+(UIImage*) defaultPoster;
+(id)cloneFrom:(PlexImage*)src forMachine:(Machine*)mach originalPath:(NSString*)path image:(UIImage*)img;

-(id)initForRatingKey:(NSString*)rk forMachine:(Machine*)mach ofType:(PlexImageType)tp originalPath:(NSString*)path parentPath:(NSString*)parentPath; 
-(void)didReceiveMemoryWarning;

-(BOOL)loadImage;
-(void)loadInBackground;
-(void)loadInBackgroundAndNotify:(id<BackgroundOperationDelegate>)delegateOrNil;
-(void)loadInBackgroundIfNeeded;
-(void)loadInBackgroundIfNeededAndNotify:(id<BackgroundOperationDelegate>)delegateOrNil;


//these are use to get finer granularity for locks during threaded loading
-(BOOL)_loadImageFromCache;
-(BOOL)_loadImage;
-(BOOL)_storeImageInCache;
@end

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

@class PlexRequest, BackgroundOperation;

@interface PlexImage : MemoryObject {
	PlexRequest* request;
	BOOL didLoadImage, lowPriority;
	CGSize maxImageSize;
	NSString* imagePath;
	MemoryImage* image;
	
	id<TraceableLayerProtocol> layer;
	UIImageView* imageView;
	BOOL cancelBackgroundLoad;
	BackgroundOperation* backgroundOperation;
}

@property (readwrite, assign) BackgroundOperation* backgroundOperation;
@property (readonly) BOOL hasImage;
@property (readonly) BOOL didLoadImage;
@property (readwrite) BOOL lowPriority;
@property (readonly, retain) MemoryImage* image;
@property (readonly) UIImage* saveImage;
@property (readonly) NSString* imagePath;
@property (readwrite) CGSize maxImageSize;
@property (readwrite, retain, nonatomic) id<TraceableLayerProtocol> layer;
@property (readwrite, retain) UIImageView* imageView;
@property (readwrite) BOOL cancelBackgroundLoad;;

+(void)freeCache;
+(UIImage*) defaultPoster;

-(id)initWithPath:(NSString*)path requestObject:(PlexRequest*)req;
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

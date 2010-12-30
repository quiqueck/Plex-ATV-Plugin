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

@class TraceableLayer, PlexRequest, BackgroundOperation;

@interface PlexImage : MemoryObject {
	PlexRequest* request;
	BOOL didLoadImage, lowPriority;
	CGSize maxImageSize;
	NSString* imagePath;
	MemoryImage* image;
	
	TraceableLayer* layer;
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
@property (readwrite, retain, nonatomic) TraceableLayer* layer;
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

//
//  PlexImage.h
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

-(void)_loadImage;
@end

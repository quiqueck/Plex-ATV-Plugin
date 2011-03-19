//
//  PlexObject.h
//  PlexPad
//
//  Created by Frank Bauer on 17.04.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemoryObject.h"

@class PlexMediaContainer;
@class PlexRequest;
@class PlexImage;
@interface PlexObject : MemoryObject {

	NSString* key;
	NSString* name;
	NSString* containerType;
	
	
	
	BOOL backgroundLoadCanceled;
	BOOL loadingBackgroundData;
	
	NSMutableDictionary* attr;
#if DEBUG
	BOOL logDealloc;
#endif
}

@property (readwrite, retain) NSMutableDictionary* attributes;
@property (readonly) NSString* key;
@property (readonly) NSString* lastKeyComponent;
@property (readonly) NSInteger sectionKey;
@property (readonly) PlexRequest* request;
@property (readwrite, retain) NSString* name;
@property (readonly, retain) NSString* containerType;
#if DEBUG
@property (readwrite) BOOL logDealloc;
#endif


@property (readonly) BOOL hasBackgroundData;
@property (readonly) BOOL backgroundLoadCanceled;
@property (readonly) BOOL loadingBackgroundData;
-(void)_init:(NSDictionary*)dict;

-(id)initWithContainerType:(NSString*)ct;
-(id)initWithAttributes:(NSDictionary*)dict containerType:(NSString*)ct;
-(void)didReceiveMemoryWarning;

-(void)doLoadBackgroundData;
-(void)loadBackgroundData;
-(void)cancelLoadBackgroundData;
-(void)finishedLoadBackgroundData;

-(void)refreshContainingSection:(BOOL)force;
@end
	

//
//  PlexDirectory.h
//  PlexPad
//
//  Created by Frank Bauer on 17.04.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlexObject.h"

extern const NSString* PlexMediaToken;
extern const NSString* PlexMediaPartToken;

@class PlexImage;

@interface PlexDirectory : PlexObject<NSXMLParserDelegate>  {
	PlexMediaContainer* mediaContainer;
	PlexDirectory* parentDirectory;
	BOOL localKey;
	
	BOOL hasMedia;
	NSMutableDictionary* subObjects;
}

@property (readonly) PlexDirectory* parentDirectory;
@property (readwrite, assign) PlexMediaContainer* mediaContainer;
@property (readonly) NSMutableDictionary* subObjects;
@property (readonly) BOOL hasMedia;
@property (readonly) BOOL localKey;
@property (readonly) NSUInteger uid;

-(id)initWithAttributes:(NSDictionary*)dict parentMediaContainer:(PlexMediaContainer*)mc parentObject:(PlexDirectory*)pmo containerType:(NSString*)ct;

-(NSString*)listSubObjects:(NSString*)type usingKey:(NSString*)k;
-(PlexDirectory*)mediaResource;
-(NSString*)debugSummary;
-(PlexImage*)plexImageFromKey;
@end
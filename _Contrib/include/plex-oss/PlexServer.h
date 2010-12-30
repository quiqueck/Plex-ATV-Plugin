//
//  PlexServer.h
//  PlexPad
//
//  Created by Frank Bauer on 23.05.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlexMediaObject.h"

@interface PlexServer : PlexMediaObject {
	NSString* host;
	NSString* machineIdentifier;
	NSString* version;
}

@property(readonly) NSString* host;
@property(readonly) NSString* machineIdentifier;
@property(readonly) NSString* version;

-(id)initWithAttributes:(NSDictionary*)dict parentMediaContainer:(PlexMediaContainer*)mc parentObject:(PlexMediaObject*)pmo isServer:(BOOL)server;
@end

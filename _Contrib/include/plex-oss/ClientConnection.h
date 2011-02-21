//
//  ClientConnection.h
//  PlexPad
//
//  Created by Frank Bauer on 19.01.11.
//  Copyright 2011 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ClientConnection : NSObject<NSCoding> {
	NSString* name;
	NSString* hostName;
}

@property(readonly, retain) NSString* name;
@property(readonly, retain) NSString* hostName;

+(ClientConnection*)clientConnectionNamed:(NSString*)in_name hostName:(NSString*)in_hn;
-(id)initForName:(NSString*)in_name hostName:(NSString*)in_hn;
@end

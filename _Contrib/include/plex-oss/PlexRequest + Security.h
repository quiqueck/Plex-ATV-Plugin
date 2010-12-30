//
//  PlexRequest + Security.h
//  PlexPad
//
//  Created by Frank Bauer on 11.07.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlexRequest.h"

@interface PlexRequest (Security)
+(NSData*)privateKey;
-(NSString*)publicKey;
-(NSString*)timeStamp;
-(NSString*)getDeviceSessionHeader;
-(void)addAuthenticationHeadersToRequest:(NSMutableURLRequest*)req;
-(void)addStreamimngHeadersToRequest:(NSMutableURLRequest*)req;
-(void)renewPasswordHash;

-(NSString*)sessionUserName;
-(NSString*)sessionPassword;
-(NSString*)_sessionPasswordHeaderValue;

#if BUILD_ATV_LIB
+(void)setStreamingKey:(NSString*)privKey forPublicKey:(NSString*)publKey;
#endif
@end

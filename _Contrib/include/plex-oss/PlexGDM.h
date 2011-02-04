//
//  PlexGDM.h
//  PlexPad
//
//  Created by Frank Bauer on 14.01.11.
//  Copyright 2011 Ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ambertation-plex/PollingThread.h>
#include <netinet/in.h>

@protocol PlexGDBDelegate<NSObject>
-(void)gdmReceivedNewResource:(NSString*)machineID withHeaders:(NSDictionary*)dict httpVersion:(NSString*)ver responseCode:(NSInteger)code sourceAddress:(NSString*)ip;
-(void)gdmReceivedChangedResource:(NSString*)machineID withHeaders:(NSDictionary*)dict httpVersion:(NSString*)ver responseCode:(NSInteger)code sourceAddress:(NSString*)ip;
-(void)gdmReceivedContent:(NSString*)content forResource:(NSString*)machineID withHeaders:(NSDictionary*)dict httpVersion:(NSString*)ver responseCode:(NSInteger)code sourceAddress:(NSString*)ip;
-(void)gdmRemovedResource:(NSString*)machineID withHeaders:(NSDictionary*)dict sourceAddress:(NSString*)ip;
@end


@interface PlexGDM : PollingThread {
	NSTimeInterval			forgetAfterInterval;
	id<PlexGDBDelegate>		delegate;
	
	NSMutableDictionary*	lastMachineIDs;
	
	//thread private
	int sockfd;
	struct sockaddr_in their_addr;
}

@property (readwrite, assign) id<PlexGDBDelegate> delegate;
@property (readwrite, assign) NSTimeInterval forgetAfterInterval;

-(void)invalidateMachineWithID:(NSString*)machineID;
@end

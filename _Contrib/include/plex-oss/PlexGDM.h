//
//  PlexGDM.h
//  PlexPad
//
//  Created by Frank Bauer on 14.01.11.
//  Copyright 2011 Ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlexGDBDelegate<NSObject>
-(void)gdmReceivedNewResource:(NSString*)machineID withHeaders:(NSDictionary*)dict httpVersion:(NSString*)ver responseCode:(NSInteger)code sourceAddress:(NSString*)ip;
-(void)gdmReceivedChangedResource:(NSString*)machineID withHeaders:(NSDictionary*)dict httpVersion:(NSString*)ver responseCode:(NSInteger)code sourceAddress:(NSString*)ip;
-(void)gdmReceivedContent:(NSString*)content forResource:(NSString*)machineID withHeaders:(NSDictionary*)dict httpVersion:(NSString*)ver responseCode:(NSInteger)code sourceAddress:(NSString*)ip;
-(void)gdmRemovedResource:(NSString*)machineID withHeaders:(NSDictionary*)dict sourceAddress:(NSString*)ip;
@end


@interface PlexGDM : NSObject {
	NSTimeInterval		forgetAfterInterval;
	NSTimeInterval		pollingInterval;
	NSThread*           thread;
	NSCondition*        cond;
	bool                run;
	BOOL				  isRunning;
	id<PlexGDBDelegate> delegate;
	
	NSMutableDictionary*		  lastMachineIDs;
}

@property (readwrite, assign) id<PlexGDBDelegate> delegate;
@property (readonly) BOOL isRunning;

@property (readwrite, assign) NSTimeInterval forgetAfterInterval;
@property (readwrite, assign) NSTimeInterval pollingInterval;

-(id)init;
-(void)start;
-(void)stop;

-(void)invalidateMachineWithID:(NSString*)machineID;
@end

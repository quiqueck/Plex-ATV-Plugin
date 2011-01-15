//
//  PlexGDM.h
//  PlexPad
//
//  Created by Frank Bauer on 14.01.11.
//  Copyright 2011 Ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlexGDBDelegate

-(void)gdmReceivedPacketWithHeaders:(NSDictionary*)dict httpVersion:(NSString*)ver responseCode:(NSInteger)code sourceAddress:(NSString*)ip;

@end


@interface PlexGDM : NSObject {
  NSThread*           thread;
  NSCondition*        cond;
  bool                run;
  id<PlexGDBDelegate> delegate;
}

@property (readwrite, assign) id<PlexGDBDelegate> delegate;

-(id)init;
-(void)start;
-(void)stop;
@end

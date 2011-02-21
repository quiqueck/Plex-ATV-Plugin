//
//  MachineAutoDetector.h
//  PlexPad
//
//  Created by Frank Bauer on 16.01.11.
//  Copyright 2011 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MachineAutoDetector, MachineConnectionBase, MachineManager, Machine;

@protocol MachineAutoDetectionProtocol <NSObject>
@end

@interface MachineAutoDetector : NSObject {
	id<MachineAutoDetectionProtocol> delegate;
	MachineManager* manager;
}

@property (readwrite, assign) id<MachineAutoDetectionProtocol> delegate;

+(MachineAutoDetector*)detectorInManager:(MachineManager*)manager;
-(id)initInManager:(MachineManager*)manager;
-(void)start;
-(void)stop;
-(BOOL)isRunning;

-(void)machineWillBeDeleted:(Machine*)m;
@end

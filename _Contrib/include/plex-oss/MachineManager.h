//
//  MachineManager.h
//  PlexPad
//
//  Created by Frank Bauer on 14.01.11.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ambertation-plex/Ambertation.h>
#import "MachineAutoDetector.h"

typedef int ConnectionInfoType;
extern const ConnectionInfoType ConnectionInfoTypeRootLevel;
extern const ConnectionInfoType ConnectionInfoTypeLibrarySections;
extern const ConnectionInfoType ConnectionInfoTypeClients;

@class Machine, ClientConnection;

@protocol MachineManagerDelegate <NSObject>
-(void)machineWasAdded:(Machine*)m;
-(void)machineWasRemoved:(Machine*)m;
-(void)machineWasChanged:(Machine*)m;
-(void)machine:(Machine*)m receivedInfoForConnection:(MachineConnectionBase*)con updated:(ConnectionInfoType)updateMask;
-(void)machine:(Machine*)m changedClientTo:(ClientConnection*)cc;
@end;

typedef int MachineRole;
extern const MachineRole MachineRoleNone;
extern const MachineRole MachineRoleServer;
extern const MachineRole MachineRoleClient;
extern const MachineRole MachineRoleClientServer;

@interface MachineManager : NSObject<MachineAutoDetectionProtocol> {
	id<MachineManagerDelegate> delegate;
	
	NSSet* discoveryMethods;
	NSMutableArray* machines;
	Machine* localhost;
	
	
  NSTimeInterval stateMonitorInterval;
	NSTimer* stateMonitorTimer;
}

@property (readwrite, assign) id<MachineManagerDelegate> delegate;
@property (readwrite, retain) Machine* localhost;
@property (readonly, retain) NSArray* threadSaveMachines;

SINGLETON_INTERFACE(MachineManager)

-(void)startAutoDetection;
-(void)stopAutoDetection;
-(BOOL)autoDetectionActive;

-(void)writeMachinePreferences;

-(void)addConnection:(MachineConnectionBase*)con;
-(void)removeConnection:(MachineConnectionBase*)con;

-(NSArray*)threadSaveMachines;
-(NSUInteger)machineCount;

-(void)addMachine:(Machine*)m;
-(void)changedMachine:(Machine*)machineOrNil;
-(void)removeMachine:(Machine*)m;
-(void)removeMachineAtIndex:(NSUInteger)idx;
-(Machine*)machineAtIndex:(int)idx;
-(Machine*)machineForMachineID:(NSString*)mid;


-(void)updateMachineStatesNow;
-(void)startMonitoringMachineState;
-(void)setMachineStateMonitorPriority:(BOOL)high;
-(void)stopMonitoringMachineState;
@end

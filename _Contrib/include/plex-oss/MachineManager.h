//
//  Machine.h
//  PlexPad
//
//  Created by Frank Bauer on 26.07.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ambertation-plex/Ambertation.h>

@class ServiceBrowser;
@class Machine;
@protocol MachineManagerDelegate
-(void)machineWasAdded:(Machine*)m;
-(void)machineStateDidChange:(Machine*)m;
-(void)machineResolved:(Machine*)m;
-(void)machineDidNotResolve:(Machine*)m;
-(void)machineReceivedClients:(Machine*)m;
@end;

typedef int MachineRole;
extern const MachineRole MachineRoleNone;
extern const MachineRole MachineRoleServer;
extern const MachineRole MachineRoleClient;
extern const MachineRole MachineRoleClientServer;

extern NSString* PMSBonjourID;
extern NSString* PlexBonjourID;;
extern NSString* PMSBounjourIdent;

static inline BOOL isServerService(NSNetService* s) {
	NSRange r = [[s type] rangeOfString:PMSBounjourIdent];
	return r.length>0;
}

@interface MachineManager : NSObject<NSNetServiceBrowserDelegate> {
	NSNetServiceBrowser* serviceBrowserPMS;
	NSNetServiceBrowser* serviceBrowserPlex;
	
	ServiceBrowser* dnsBrowserPMS;
	ServiceBrowser* dnsBrowserPlex;
	
	id<MachineManagerDelegate> delegate;
	
	NSMutableArray* machines;
	Machine* localhost;
}

@property (readwrite, assign) id<MachineManagerDelegate> delegate;
@property (readwrite, retain) Machine* localhost;
@property (readonly, retain) NSMutableArray* machines;

SINGLETON_INTERFACE(MachineManager)

-(void)startAutoDetection;
-(void)stopAutoDetection;
-(BOOL)autoDetectionActive;
-(void)writeMachinePreferences;

-(NSArray*)machines;
-(void)addMachine:(Machine*)m;
-(void)changedMachine:(Machine*)machineOrNil;
-(void)sendMachineChangeNotificationFor:(Machine*)m;
-(void)removeMachine:(Machine*)m;
-(void)removeMachineAtIndex:(NSUInteger)idx;
-(Machine*)machineAtIndex:(int)idx;

-(void)updateUnknownRoles;
-(void)updateOnlineStates;

-(NSArray*)serialize;
-(void)loadSerializedArray:(NSArray*)ar;
@end

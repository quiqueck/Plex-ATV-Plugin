//
//  Machine.h
//  PlexPad
//
//  Created by Frank Bauer on 26.07.10.
//  Copyright 2010 F. Bauer. All rights reserved.
//
// Redistribution and use of the code or any derivative works are 
// permitted provided that the following conditions are met:
//   - Redistributions may not be sold, nor may they be used in 
//     a commercial product or activity.
//   - Redistributions must reproduce the above copyright notice, 
//     this list of conditions and the following disclaimer in the 
//     documentation and/or other materials provided with the 
//     distribution.
//   - It is not permitted to redistribute a modified version of 
//     this file
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.
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

//
//  Machine.h
//  PlexPad
//
//  Created by Frank Bauer on 26.07.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MachineManager.h"
#import <ambertation-plex/SimplePing.h>


typedef int PlayOnType;
extern const PlayOnType PlayOnTypePlex;
extern const PlayOnType PlayOnTypeAsk;
extern const PlayOnType PlayOnTypeDevice;

static inline BOOL runsClient(MachineRole mr) {
	return (mr&MachineRoleClient) == MachineRoleClient;
}

static inline BOOL runsServer(MachineRole mr) {
	return (mr&MachineRoleServer) == MachineRoleServer;
}

static inline MachineRole removeMachineRole(MachineRole now, MachineRole r){
	r = ~r;
	return now & r;
}

static inline MachineRole addMachineRole(MachineRole now, MachineRole r){
	return now | r;
}

@class PlexRequest, PlexCachedRequest;
@interface Machine : NSObject<SimplePingDelegateNotificationDelegate, NSNetServiceDelegate> {
	MachineManager* parent;
	MachineRole role;
	NSNetService* serverService;
	NSNetService* clientService;
	id<MachineManagerDelegate> didResolveDelegate;
	
	NSString* uid;
	NSString* serverName;
	
	NSString* hostName;
	int port;
	NSString* mac;
	NSString* ip;
	
	int version;
	
	BOOL isOnline;
	BOOL localhost;
	BOOL waitsForPing;
	
	float quality;
	BOOL autoConnect;
	BOOL autoReturn;
	PlayOnType playOn;
	NSString* username;
  NSString* machineID;
	
	Machine* clientMachine;
	PlexRequest* request;
  NSDictionary* gdmDictionary;
	
	PlexCachedRequest* clients;
	PlexCachedRequest* servers;
}

@property (readwrite) int version;
@property (readwrite, retain) Machine* clientMachine;
@property (readwrite, assign) MachineManager* parent;
@property (readwrite, retain) NSNetService* serverService;
@property (readwrite, retain) NSNetService* clientService;
@property (readwrite) MachineRole role;
@property (readwrite, retain) NSString* hostName;
@property (readwrite, retain) NSString* ip;
@property (readonly) NSString* serverHostName;
@property (readwrite, retain) NSString* serverName;
@property (readonly, retain) NSString* uid;
@property (readwrite, retain) NSString* machineID;
@property (readwrite, retain) NSString* mac;
@property (readwrite) int port;
@property (readonly) BOOL bonjour;
@property (readonly) BOOL gdm;
@property (readonly, retain) PlexRequest* request;
@property (readwrite) BOOL isOnline;
@property (readwrite) BOOL localhost;
@property (readonly) NSString* roleString;

@property (readwrite) float quality;
@property (readwrite) BOOL autoConnect;
@property (readwrite) BOOL autoReturn;
@property (readwrite) PlayOnType playOn;
@property (readwrite, retain) NSString* userName;
@property (readonly, retain) NSString* password;
@property (readwrite) int streamQuality;

@property (readonly) BOOL hasClients;
@property (readonly) NSArray* clients;
@property (readonly) BOOL hasValidClientInfo;
@property (readonly) Machine* autoClientMachine;
@property (readonly) Machine* selectedClientMachine;

-(int)maximumQuality;
+(int)versionFromVersionString:(NSString*)versStr;

-(id)initLocalhostForManager:(MachineManager*)mm;
-(id)initWithNetService:(NSNetService*) netService manager:(MachineManager*)parent;
-(id)initWithServerName:(NSString*)serverName hostName:(NSString*)hostName port:(int)port role:(MachineRole)r manager:(MachineManager*)parent etherID:(NSString*)etherIDOrNil;
-(void)didReceiveMemoryWarning;
-(void)linkWithService:(NSNetService*)ns;
-(void)linkWithGDMDictionary:(NSDictionary*)dict fromAddress:(NSString*)ip;
-(void)resolveAndNotify:(id<MachineManagerDelegate>)del;

-(void)lookupEthernetID;
-(void)lookupEthernetIDSync;
-(NSString*)findEthernetID;
-(void)ping;
-(void)wol;

-(BOOL)isHostEqual:(id)object;
-(BOOL)isHostAndPortEqual:(id)object;

-(void)renewPasswordHash;
-(NSDictionary*)dictionaryFromContent;
- (id)initWithDictionary:(NSDictionary *)dict manager:(MachineManager*)parent;
-(void)setLocalhostFromDictionary:(NSDictionary*)dict;

-(void)startMonitoring;
-(void)stopMonitoring;
-(void)invalidateMachineLists;
@end

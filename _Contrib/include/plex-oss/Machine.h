//
//  Machine.h
//  PlexPad
//
//  Created by Frank Bauer on 14.01.11.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MachineManager.h"
#import "MachineCapabilities.h"
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

typedef NSUInteger ConditionallyAddErrorCode;
extern const ConditionallyAddErrorCode ConditionallyAddErrorCodeWrongMachineID;
extern const ConditionallyAddErrorCode ConditionallyAddErrorCodeCouldNotConnect;
extern const ConditionallyAddErrorCode ConditionallyAddErrorCodeNeedCredentials;

@class Machine;
@protocol TestAndConditionallyAddConnectionProtocol
-(void)machine:(Machine*) m didAcceptConnection:(MachineConnectionBase*) con;
-(void)machine:(Machine*) m didNotAcceptConnection:(MachineConnectionBase*) con error:(NSError*)err;
@end

typedef struct _MachineStateRecord{
    BOOL inLocalNetwork;
    BOOL canConnect;
    BOOL isOnline;
    BOOL authenticationNeeded;
} MachineStateRecord;

@class MachineConnectionBase, ClientConnection, PlexMediaContainer, PlexRequest, PlexMediaObject;
@interface Machine : NSObject<NSCoding> {
  NSString* uid; 
  NSString* machineID;
  MachineManager* parent;
  PlexRequest* request;
    
  //pms properties
  MachineCapabilities* capabilities;
  NSUInteger	streamingBitrate;
  BOOL autoConnect;
  BOOL autoReturn;
  PlayOnType playOn;
  
  //authentication
  NSString* userName;
  
  //connection
  MachineConnectionBase* bestConnection;
  NSString* serverName;
  NSMutableArray* connections;
  BOOL localhost;
  
  //cache for best connection
  PlexMediaContainer* rootLevel;
  PlexMediaContainer* librarySections;
  NSArray* clientConnections;
    
  
  //connection state
  MachineRole role;
  MachineStateRecord lastMachineStateRecord;
  
  //clients
  NSString* clientHostName;
  
  //caching (for offline machines)
  NSString* qualityValues;
  NSString* qualityBitrates;
  NSString* qualityHeights;
    
  //remember what we played last...
  NSMutableArray* playHistory;
    
  //Browsing state
  NSMutableDictionary* sectionFilters;
  NSMutableDictionary* selectedItems;
  NSMutableDictionary* searchQuerries;
  NSMutableArray* currentPosition;  
}

+(NSString*)stringFromVersion:(int)ver;
+(NSString*)stringFromMachineRole:(MachineRole)r;
+(NSString*)stringFromPlayOnType:(PlayOnType)p;
-(id)initWithServerName:(NSString*)serverName manager:(MachineManager*)parent machineID:(NSString*)mid;

-(void)didReceiveMemoryWarning;
-(void)sendMachineChangedOnlineOrContentState;
-(void)sendMachineChangeNotificationForConnection:(MachineConnectionBase*)con;

@property (readwrite, retain) NSString* serverName;
@property (readonly, assign) NSString* usersServerName;
@property (readwrite) PlayOnType playOn;
@property (readwrite) BOOL autoConnect;
@property (readwrite) BOOL autoReturn;

@property (readonly, retain) NSString* userName;
@property (readonly, assign) NSString* password;
-(void)setUsername:(NSString*)usernameOrNil andPassword:(NSString*)pwdOrNil;


@property (readonly) NSString* machineID;
@property (readwrite) int version;
@property (readonly) BOOL localhost;
@property (readonly) PlexRequest* request;


@property (readonly) NSMutableArray* connections;
@property (readonly) MachineConnectionBase* bestConnection;
-(void)removeConnection:(MachineConnectionBase*)c;
-(void)testAndConditionallyAddConnectionForHostName:(NSString*)hn notify:(id<TestAndConditionallyAddConnectionProtocol>)targetOrNil;
-(void)testAndConditionallyAddConnectionForHostName:(NSString*)hn port:(NSUInteger)p notify:(id<TestAndConditionallyAddConnectionProtocol>)targetOrNil;
-(void)testAndConditionallyAddConnectionForHostName:(NSString*)hn port:(NSUInteger)p etherID:(NSString*)m notify:(id<TestAndConditionallyAddConnectionProtocol>)targetOrNil;
-(void)testAndConditionallyAddConnectionForHostName:(NSString*)hn ip:(NSString*)i port:(NSUInteger)p etherID:(NSString*)m notify:(id<TestAndConditionallyAddConnectionProtocol>)targetOrNil;
-(void)chooseBestConnection;

@property (readwrite, assign) NSUInteger streamingBitrate;
@property (readwrite, assign) PlexStreamingQuality streamQuality;

@property (readonly) NSString* ip;
@property (readonly) NSUInteger port;
@property (readonly) NSString* hostName;
@property (readonly) MachineRole role;
@property (readonly) BOOL isOnline;
@property (readonly) BOOL canConnect;
@property (readonly) BOOL isComplete;
-(void)renewPasswordHash;

@property(readonly, retain) MachineCapabilities* capabilities;
-(BOOL)supports:(MachineCapability)capability;

-(void)startUpdateConnectionStates;
-(void)wol;

@property (readonly) BOOL hasClients;
@property (readonly) NSArray* clients;
@property (readonly) ClientConnection* suggestedClientConnection;
@property (readonly) ClientConnection* usersClientConnection;
@property (readwrite, assign) ClientConnection* clientConnection;

@property (readonly, assign) PlexMediaContainer* librarySections;
@property (readonly, assign) PlexMediaContainer* rootLevel;
@property (readonly, assign) NSArray* clientConnections;

@property (readonly, retain) NSArray* playbackHistory;
-(void)willPlayMediaObject:(PlexMediaObject*)pmo;

-(NSString*)filterForSection:(NSString*)section;
-(void)setFilter:(NSString*)f forSection:(NSString*)section;
-(NSArray*)lastSeenContainerPath;
-(void)setLastSeenContainerPath:(NSArray*)pos;
-(void)setLastSearchQuery:(NSString*)q forSection:(NSString*)section;
-(NSString*)lastSearchQueryForSection:(NSString*)section;
-(void)setSelectionIndex:(CGFloat)idx key:(NSString*)key selectedObject:(PlexMediaObject*)objOrNil;
-(CGFloat)selectionIndexForKey:(NSString*)key;
@end

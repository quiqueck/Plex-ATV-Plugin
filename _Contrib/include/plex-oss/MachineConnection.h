//
//  MachineConnection.h
//  PlexPad
//
//  Created by Frank Bauer on 16.01.11.
//  Copyright 2011 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MachineConnectionBase.h"

@class  PlexMediaContainer, 
        PlexCachedRequest,
        PlexRequest;
@interface MachineConnection : MachineConnectionBase {
	PlexMediaContainer* rootLevel;
	PlexMediaContainer* librarySections;
}

@property (readonly, retain) PlexMediaContainer* rootLevel;
@property (readonly, retain) PlexMediaContainer* librarySections;


-(NSArray*)_loadClientsFromRequest:(PlexRequest*)pr;
-(PlexMediaContainer*)_processRootLevelContainer:(PlexMediaContainer*) realRoot;

-(BOOL)autoDownloadLibrarySections;
-(BOOL)autoDownloadRootLevel;
@end

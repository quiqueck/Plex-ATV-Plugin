//
//  MemoryObject.h
//  PlexPad
//
//  Created by Frank Bauer on 19.06.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MEMORY_DEBUG 0

#if MEMORY_DEBUG
@interface MemoryObject : NSObject {
	@public
	int retaining;
	int globalid;
}

+(void)dumpMemory;
@end

#else 
typedef NSObject MemoryObject;
#endif


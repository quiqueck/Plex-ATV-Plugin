//
//  MemoryImage.h
//  PlexPad
//
//  Created by Frank Bauer on 19.06.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MEMORY_DEBUG_IMG 0
#define MEMORY_DEBUG_IMG_WRITE 1


#if MEMORY_DEBUG_IMG
@interface MemoryImage : UIImage {
@public
	int retaining;
	int globalid;
}

+(void)dumpMemory;
@end

#else 
typedef UIImage MemoryImage;
#endif
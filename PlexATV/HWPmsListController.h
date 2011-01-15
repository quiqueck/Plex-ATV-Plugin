//
//  HWPmsListController.h
//  atvTwo
//
//  Created by Serendipity on 10/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <plex-oss/MachineManager.h>
#import "SMFPreferences.h"

@interface HWPmsListController : BRMediaMenuController<MachineManagerDelegate> {
	NSMutableArray		*_names;
	
}
//list provider
- (float)heightForRow:(long)row;
- (long)itemCount;
- (id)itemForRow:(long)row;
- (BOOL)rowSelectable:(long)selectable;
- (id)titleForRow:(long)row;
- (void)setNeedsUpdate;

@end

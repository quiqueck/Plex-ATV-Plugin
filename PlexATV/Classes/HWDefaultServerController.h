//
//  HWDefaultServersController.h
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//


#import <plex-oss/MachineManager.h>

@interface HWDefaultServerController : BRMediaMenuController<MachineManagerDelegate> {
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
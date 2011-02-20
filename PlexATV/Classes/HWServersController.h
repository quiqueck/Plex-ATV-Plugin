//
//  HWServersController.h
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//

#import <Foundation/Foundation.h>
#import <plex-oss/Machine.h>

@interface HWServersController : SMFMediaMenuController<MachineManagerDelegate> {
	NSMutableArray *_machines;
	NSArray *_machineSortDescriptors;
}

@property (assign) NSMutableArray *machines;

//custom methods
- (void)showAddNewMachineWizard;
- (void)showEditMachineDetailsViewForMachine:(Machine *)machine;

//list provider
- (float)heightForRow:(long)row;
- (long)itemCount;
- (id)itemForRow:(long)row;
- (BOOL)rowSelectable:(long)selectable;
- (id)titleForRow:(long)row;
- (void)setNeedsUpdate;

@end

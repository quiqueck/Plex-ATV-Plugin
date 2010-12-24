
#import <plex-oss/MachineManager.h>
@interface HWBasicMenu : BRMediaMenuController<MachineManagerDelegate> {

	NSMutableArray		*_names;

}
//list provider
- (float)heightForRow:(long)row;
- (long)itemCount;
- (id)itemForRow:(long)row;
- (BOOL)rowSelectable:(long)selectable;
- (id)titleForRow:(long)row;

@end

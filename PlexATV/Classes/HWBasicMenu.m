

#import "HWBasicMenu.h"
#import "HWPlexDir.h"
#import <plex-oss/MachineManager.h>
#import <plex-oss/Machine.h>
#import <plex-oss/PlexRequest.h>

@implementation HWBasicMenu

- (id) init
{
	if((self = [super init]) != nil) {
		
		//NSLog(@"%@ %s", self, _cmd);
		
		[self setListTitle:@"Local Servers"];
		
		BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];
		
    [self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		
		_names = [[NSMutableArray alloc] init];
		
    //make sure we are the delegate
    [[MachineManager sharedMachineManager] setDelegate:self];
    
    //add all available servers
    for (Machine* m in [[MachineManager sharedMachineManager] machines]){
      if (runsServer(m.role))
        [_names addObject:m];
    }
    
    //start the auto detection
		[[MachineManager sharedMachineManager] startAutoDetection];
		
		[[self list] setDatasource:self];
		
		return ( self );
		
	}
	
	return ( self );
}	


-(void)dealloc
{
	[[MachineManager sharedMachineManager] setDelegate:nil];
	[[MachineManager sharedMachineManager] stopAutoDetection];
	[_names release];

	[super dealloc];
}


- (id)previewControlForItem:(long)item

{
	BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[HWBasicMenu class]] pathForResource:@"PlexLogo" ofType:@"png"]];
	
	
	BRImageAndSyncingPreviewController *obj = [[BRImageAndSyncingPreviewController alloc] init];
	
	[obj setImage:theImage];
	
	return [obj autorelease];
	
}

- (BOOL)shouldRefreshForUpdateToObject:(id)object{
  return YES;
}

- (void)itemSelected:(long)selected {
  if (selected<0 || selected>=_names.count) return;
	Machine* m = [_names objectAtIndex:selected];
	NSLog(@"item selected: %@", m);
	
	HWPlexDir* menuController = [[HWPlexDir alloc] init];
  menuController.rootContainer = [m.request rootLevel];
  [[[BRApplicationStackManager singleton] stack] pushController:menuController];
  [menuController autorelease];
}

- (float)heightForRow:(long)row {
	return 50.0f;
}

- (long)itemCount {
	return _names.count;
}

- (id)itemForRow:(long)row {
	if (row >= [_names count] || row<0)
		return nil;

	BRMenuItem * result = [[BRMenuItem alloc] init];
	Machine *m = [_names objectAtIndex:row];
	[result setText:m.serverName withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
	[result addAccessoryOfType: m.hostName!=nil && ![m.hostName empty]]; //folder
	
	
	return [result autorelease];
}

- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (id)titleForRow:(long)row {
	if (row >= [_names count] || row<0)
		return @"";
	Machine* m = [_names objectAtIndex:row];
	return m.serverName;
}

-(void)setNeedsUpdate{
  NSLog(@"Updating UI");
//  [self updatePreviewController];
//	[self refreshControllerForModelUpdate];
  [self.list reload];
}

#pragma mark
#pragma mark Machine Manager Delegate
-(void)machineWasAdded:(Machine*)m{
  if (!runsServer(m.role)) return;
  
	[_names addObject:m];
	NSLog(@"Added %@", m);
	
	[m resolveAndNotify:self];
	[self setNeedsUpdate];
}

-(void)machineStateDidChange:(Machine*)m{
  if (m==nil) return;
  
  if (runsServer(m.role) && ![_names containsObject:m]){
    [self machineWasAdded:m];
    return;
  } else if (!runsServer(m.role) && [_names containsObject:m]){
    [_names removeObject:m];
    NSLog(@"Removed %@", m);
  } else {
    NSLog(@"Changed %@", m);
  }
	
	[self setNeedsUpdate];
}

-(void)machineResolved:(Machine*)m{
	NSLog(@"Resolved %@", m);
}

-(void)machineDidNotResolve:(Machine*)m{
	NSLog(@"Unable to Resolve %@", m);
}

-(void)machineReceivedClients:(Machine*)m{
	NSLog(@"Got list of clients %@", m);
}
@end



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
		
		[[MachineManager sharedMachineManager] setDelegate:self];
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



- (void)itemSelected:(long)selected {
  	NSLog(@"0");
  if (selected<0 || selected>=_names.count) return;
	NSLog(@"1");
  NSLog(@"%@, %ld", _names, selected);
	Machine* m = [_names objectAtIndex:selected];
	NSLog(@"item selected: %@", m);
	
	HWPlexDir* menuController = [[HWPlexDir alloc] init];
  NSLog(@"2");
  NSLog(@"%@", m.request);
  NSLog(@"%@", [m.request rootLevel]);
	menuController.rootContainer = [m.request rootLevel];
  NSLog(@"3");
	[[[BRApplicationStackManager singleton] stack] pushController:menuController];
  NSLog(@"4");
	[menuController autorelease];
  NSLog(@"5");
}

- (float)heightForRow:(long)row {
	return 0.0f;
}

- (long)itemCount {
	return [_names count];
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


-(void)machineWasAdded:(Machine*)m{
	[_names addObject:m];
	NSLog(@"Added %@", m);
	
	[m resolveAndNotify:self];
	[self updatePreviewController];
	[self refreshControllerForModelUpdate];
}

-(void)machineStateDidChange:(Machine*)m{
  if (m==nil) return;
  
  if (![_names containsObject:m]){
    [self machineWasAdded:m];
    return;
  }
  
	NSLog(@"Changed %@", m);
	[self updatePreviewController];
	[self refreshControllerForModelUpdate];
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

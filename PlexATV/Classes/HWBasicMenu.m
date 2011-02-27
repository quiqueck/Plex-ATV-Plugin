

#import "HWBasicMenu.h"
#import "HWPlexDir.h"
#import <plex-oss/MachineManager.h>
#import <plex-oss/Machine.h>
#import <plex-oss/PlexRequest.h>

@implementation HWBasicMenu

- (id) init
{
	if((self = [super init]) != nil) {
		
		DLog(@"--- %@ %s", self, _cmd);
		
		[self setListTitle:@"Server List"];
		
		BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];
		
    [self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		
		_names = [[NSMutableArray alloc] init];
		
    //make sure we are the delegate
    [[ProxyMachineDelegate shared] registerDelegate:self];
    
    //start the auto detection
		[[MachineManager sharedMachineManager] startAutoDetection];
		
		[[self list] setDatasource:self];
		
		return ( self );
		
	}
	
	return ( self );
}	


-(void)dealloc
{
  DLog(@"--- %@ %s", self, _cmd);
  
	[[MachineManager sharedMachineManager] stopAutoDetection];
	[_names release];

	[super dealloc];
}

- (void)wasBuried{
  DLog(@"--- Did burrie controller %@", self);
  [super wasBuried];
}

- (void)wasExhumed{
  DLog(@"--- Did exhume controller %@", self);
  [super wasExhumed];
}

- (void)wasPushed{
  DLog(@"--- Did push controller %@ %@", self, _names);
  [[ProxyMachineDelegate shared] registerDelegate:self];
  
  [super wasPushed];
}

- (void)wasPopped{
  DLog(@"--- Did pop controller %@", self);
  [[ProxyMachineDelegate shared] removeDelegate:self];
  
  [super wasPopped];
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
	DLog(@"machine selected: %@", m);
	
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
  NSString* name = [NSString stringWithFormat:@"%@", m.serverName, m];
	[result setText:name withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
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
  DLog(@"Updating UI");
//  [self updatePreviewController];
//	[self refreshControllerForModelUpdate];
  [self.list reload];
}

#pragma mark
#pragma mark Machine Manager Delegate
-(void)machineWasRemoved:(Machine*)m{
  DLog(@"Removed %@", m);
  [_names removeObject:m];
}

-(void)machineWasAdded:(Machine*)m{
  if (!runsServer(m.role)) return;
  if ([_names containsObject:m]) return;
  
	[_names addObject:m];
	DLog(@"Added %@", m);
	
	//[m resolveAndNotify:self];
	[self setNeedsUpdate];
}

-(void)machineWasChanged:(Machine*)m{
  if (m==nil) return;
  
  if (runsServer(m.role) && ![_names containsObject:m]){
    [self machineWasAdded:m];
    return;
  } else if (!runsServer(m.role) && [_names containsObject:m]){
    [_names removeObject:m];
    DLog(@"Removed %@", m);
  } else {
    DLog(@"Changed %@", m);
  }
	
	[self setNeedsUpdate];
}

-(void)machine:(Machine*)m receivedInfoForConnection:(MachineConnectionBase*)con{
}

-(void)machine:(Machine*)m changedClientTo:(ClientConnection*)cc{
}
@end

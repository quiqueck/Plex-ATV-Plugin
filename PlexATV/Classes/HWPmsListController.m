//
//  HWPmsListController.m
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//



#import "HWPmsListController.h"
#import <plex-oss/MachineManager.h>
#import <plex-oss/Machine.h>
#import <plex-oss/PlexRequest.h>
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation HWPmsListController

- (id) init
{
	if((self = [super init]) != nil) {		
		[self setListTitle:@"Select default server"];
		BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];
		
		[self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		
		_names = [[NSMutableArray alloc] init];
		
		//make sure we are the delegate
		[[ProxyMachineDelegate shared] registerDelegate:self];
		
		//start the auto detection
		[[MachineManager sharedMachineManager] startAutoDetection];
		
		[[self list] setDatasource:self];
	}
	return self;
}	


-(void)dealloc
{
	[[MachineManager sharedMachineManager] stopAutoDetection];
	[_names release];
	
	[super dealloc];
}

- (void)wasPushed{
	NSLog(@"--- Did push controller %@ %@", self, _names);
	[[ProxyMachineDelegate shared] registerDelegate:self];
	
	[super wasPushed];
}

- (void)wasPopped{
	NSLog(@"--- Did pop controller %@", self);
	[[ProxyMachineDelegate shared] removeDelegate:self];
	
	[super wasPopped];
}



- (id)previewControlForItem:(long)item

{
	BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[HWPmsListController class]] pathForResource:@"PlexLogo" ofType:@"png"]];
	BRImageAndSyncingPreviewController *obj = [[BRImageAndSyncingPreviewController alloc] init];
	[obj setImage:theImage];
	return [obj autorelease];
}

- (BOOL)shouldRefreshForUpdateToObject:(id)object{
	return YES;
}

- (void)itemSelected:(long)selected {
	Machine* m = [_names objectAtIndex:selected];
	NSLog(@"machine selected: %@", m);
	
	[[HWUserDefaults preferences] setObject:m.serverName forKey:PreferencesDefaultServerName];
	[[HWUserDefaults preferences] setObject:m.uid forKey:PreferencesDefaultServerUid];
	
	[self setNeedsUpdate];
}

- (float)heightForRow:(long)row {
	return 50.0f;
}

- (long)itemCount {
	return _names.count;
}

- (id)itemForRow:(long)row {
	BRMenuItem * result = [[BRMenuItem alloc] init];
	
	Machine *m = [_names objectAtIndex:row];
	NSString* name = [NSString stringWithFormat:@"%@", m.serverName, m];
	[result setText:name withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
	
	NSString *defaultServerUid = [[HWUserDefaults preferences] objectForKey:PreferencesDefaultServerUid];
	if ([m.uid isEqualToString:defaultServerUid]) {
		[result addAccessoryOfType:17]; //checkmark
	}
	
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
-(void)machineWasRemoved:(Machine*)m{
	NSLog(@"Removed %@", m);
	[_names removeObject:m];
}

-(void)machineWasAdded:(Machine*)m{
	if (!runsServer(m.role)) return;
	
	[_names addObject:m];
	NSLog(@"Added %@", m);
	
    //[m resolveAndNotify:self];
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
	[[MachineManager sharedMachineManager] addMachine:m];
}

-(void)machineDidNotResolve:(Machine*)m{
	NSLog(@"Unable to Resolve %@", m);
}

-(void)machineReceivedClients:(Machine*)m{
	NSLog(@"Got list of clients %@", m);
}
@end

//
//  HWServersController.m
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//

#define LOCAL_DEBUG_ENABLED 1

#import "HWServersController.h"
#import <plex-oss/MachineManager.h>
#import <plex-oss/PlexRequest.h>
#import "Constants.h"
#import "HWServerDetailsController.h"

@implementation HWServersController

@synthesize machines = _machines;

- (id) init
{
	if((self = [super init]) != nil) {		
		[self setListTitle:@"All Servers"];
		BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];
		
		[self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		
		_machines = [[NSMutableArray alloc] init];
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"serverName" ascending:YES];
		_machineSortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[sortDescriptor release];
		
		[[self list] setDatasource:self];
 		[[self list] addDividerAtIndex:1 withLabel:@"List of Servers"];
		
		//make sure we are the delegate
		[[ProxyMachineDelegate shared] registerDelegate:self];
		
		//start the auto detection
		[[MachineManager sharedMachineManager] startAutoDetection];
		[[MachineManager sharedMachineManager] startMonitoringMachineState];
	}
	return self;
}

-(void)dealloc
{
	[[MachineManager sharedMachineManager] stopAutoDetection];
	[[MachineManager sharedMachineManager] stopMonitoringMachineState];
	
	self.machines = nil;
	[_machineSortDescriptors release];
	
	[super dealloc];
}

- (void)wasPushed {
#ifdef LOCAL_DEBUG_ENABLED
	DLog(@"--- Did push controller");
#endif
	[[ProxyMachineDelegate shared] registerDelegate:self];
	[self.machines removeAllObjects];
	[self.machines addObjectsFromArray:[[MachineManager sharedMachineManager] threadSafeMachines]];
	[self.machines sortUsingDescriptors:_machineSortDescriptors];
	
	[self.list reload];
}

- (void)wasPopped {
#ifdef LOCAL_DEBUG_ENABLED
	DLog(@"--- Did pop controller");
#endif
	[[ProxyMachineDelegate shared] removeDelegate:self];
	
	[super wasPopped];
}


#pragma mark -
#pragma mark Edit Machine Manager's Machine List Methods
- (void)showAddNewMachineWizard {
	HWServerDetailsController *serverDetailsController = [[HWServerDetailsController alloc] initAndShowAddNewMachineWizard];
	[[self stack] pushController:serverDetailsController];
	[serverDetailsController release];
}

- (void)showEditMachineDetailsViewForMachine:(Machine *)machine {
	HWServerDetailsController *serverDetailsController = [[HWServerDetailsController alloc] initWithMachine:machine];
	[[self stack] pushController:serverDetailsController];
	[serverDetailsController release];
}


#pragma mark -
#pragma mark Menu Controller Delegate Methods
- (id)previewControlForItem:(long)item {
	BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[HWServersController class]] pathForResource:@"PlexLogo" ofType:@"png"]];
	BRImageAndSyncingPreviewController *obj = [[BRImageAndSyncingPreviewController alloc] init];
	[obj setImage:theImage];
	return [obj autorelease];
}

- (BOOL)shouldRefreshForUpdateToObject:(id)object {
	return YES;
}

- (void)itemSelected:(long)selected {
#ifdef LOCAL_DEBUG_ENABLED
	DLog(@"itemSelected: %d",selected);
#endif
	if (selected == 0) {
		[self showAddNewMachineWizard];
	} else {
		Machine* m = [self.machines objectAtIndex:selected -1]; //-1 'cause of the "Add remote server" that screws up things
#ifdef LOCAL_DEBUG_ENABLED
		DLog(@"machine selected: %@", m);
#endif
		[self showEditMachineDetailsViewForMachine:m];
	}
}

- (float)heightForRow:(long)row {
	return 0.0f;
}

- (long)itemCount {
	return self.machines.count + 1;
}

- (id)itemForRow:(long)row {
	BRMenuItem * result = [[BRMenuItem alloc] init];
	
	if(row == 0){
		[result setText:@"Add new server" withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		[result addAccessoryOfType:0];
	} else {
		Machine *m = [self.machines objectAtIndex:row-1];
		NSString *serverName;
		
		if (m.usersServerName) {
			serverName = m.usersServerName;
		} else if (m.serverName) {
			serverName = m.serverName;
		} else {
			serverName = @"<Unknown>"; //if machine has no connections
		}

		[result setText:serverName withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		
		[result addAccessoryOfType:1]; //folder
		if (m.canConnect) {
			[result addAccessoryOfType:18]; //online
		} else {
			[result addAccessoryOfType:19]; //offline
		}
		
	}	
	
	return [result autorelease];
}

- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (id)titleForRow:(long)row {
	if (row >= [self.machines count] || row<0)
		return @"";
	Machine* m = [self.machines objectAtIndex:row];
	return m.serverName;
}

-(void)setNeedsUpdate{
#ifdef LOCAL_DEBUG_ENABLED
	DLog(@"Updating UI");
#endif
	[self.list reload];
}

//handle custom event
-(BOOL)brEventAction:(BREvent *)event
{
	int remoteAction = [event remoteAction];
	if ([(BRControllerStack *)[self stack] peekController] != self)
		remoteAction = 0;
	
	int itemCount = [[(BRListControl *)[self list] datasource] itemCount];
	switch (remoteAction)
	{
		case kBREventRemoteActionSelectHold: {
			return YES;
			break;
		}
		case kBREventRemoteActionSwipeLeft:
		case kBREventRemoteActionLeft:
			return YES;
			break;
		case kBREventRemoteActionSwipeRight:
		case kBREventRemoteActionRight:
			return YES;
			break;
		case kBREventRemoteActionPlayPause:
			if([event value] == 1)
				[self playPauseActionForRow:[self getSelection]];
			return YES;
			break;
		case kBREventRemoteActionUp:
		case kBREventRemoteActionHoldUp:
			if([self getSelection] == 0 && [event value] == 1)
			{
				[self setSelection:itemCount-1];
				return YES;
			}
			break;
		case kBREventRemoteActionDown:
		case kBREventRemoteActionHoldDown:
			if([self getSelection] == itemCount-1 && [event value] == 1)
			{
				[self setSelection:0];
				return YES;
			}
			break;
	}
	return [super brEventAction:event];
}

#pragma mark -
#pragma mark Machine Delegate Methods
-(void)machineWasRemoved:(Machine*)m{
#if LOCAL_DEBUG_ENABLED
	DLog(@"MachineManager: Removed machine %@", m);
#endif
	[self.machines removeObject:m];
	[self.machines sortUsingDescriptors:_machineSortDescriptors];
	[self.list reload];
}

-(void)machineWasAdded:(Machine*)m {	
#if LOCAL_DEBUG_ENABLED
	DLog(@"MachineManager: Added machine %@", m);
#endif
	[self.machines addObject:m];
	[self.machines sortUsingDescriptors:_machineSortDescriptors];
	[self.list reload];
}

-(void)machine:(Machine*)m receivedInfoForConnection:(MachineConnectionBase*)con updated:(ConnectionInfoType)updateMask {
#if LOCAL_DEBUG_ENABLED
	DLog(@"MachineManager: Received Info For connection %@ from machine %@", con, m);
#endif
}

-(void)machineWasChanged:(Machine*)m {
	if (m==nil) return;	
	//something changed, refresh
	[self.list reload];
}

-(void)machine:(Machine*)m changedClientTo:(ClientConnection*)cc{}

@end

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
@synthesize serverName = _serverName;
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize hostName = _hostName;
@synthesize portNumber = _portNumber;

- (id) init
{
	if((self = [super init]) != nil) {		
		[self setListTitle:@"All Servers"];
		BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];
		
		[self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		
		[self resetDialogFlags];
		
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
	self.serverName = nil;
	self.userName = nil;
	self.password = nil;
	self.hostName = nil;
	self.portNumber = 0;
	
	[_machineSortDescriptors release];
	
	[super dealloc];
}

- (void)wasPushed {
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"--- Did push controller");
#endif
	[[ProxyMachineDelegate shared] registerDelegate:self];
	[self.machines removeAllObjects];
	[self.machines addObjectsFromArray:[[MachineManager sharedMachineManager] threadSafeMachines]];
	[self.machines sortUsingDescriptors:_machineSortDescriptors];
	
	[self.list reload];
}

- (void)wasPopped {
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"--- Did pop controller");
#endif
	[[ProxyMachineDelegate shared] removeDelegate:self];
	
	[super wasPopped];
}

#pragma mark -
#pragma mark Modify Machine Methods
- (void)showEditMachineView:(Machine *)machine {
	HWServerDetailsController *serverDetailsController = [[[HWServerDetailsController alloc] init] autorelease];
	serverDetailsController.machine = machine;
	[[[BRApplicationStackManager singleton] stack] pushController:serverDetailsController];
}

- (void)addNewMachineWithServerName:(NSString *)serverName userName:(NSString *)userName password:(NSString *)password
{
	Machine *machine = [[Machine alloc] initWithServerName:serverName manager:[MachineManager sharedMachineManager] machineID:nil];	
	[machine setUsername:userName andPassword:password];
	
	//show server details
	[self showEditMachineView:machine];
}

- (void)resetDialogFlags
{	
	hasCompletedAddNewServerWizardStep1 = NO;
	hasCompletedAddNewServerWizardStep2 = NO;
	hasCompletedAddNewServerWizardStep3 = NO;	
}

- (void)resetMachineSettingVariables
{	
	self.serverName = nil;
	self.userName = nil;
	self.password = nil;
	self.hostName = nil;
	self.portNumber = NSNotFound;
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
	NSLog(@"itemSelected: %d",selected);
#endif
	if (selected == 0) {
		[self resetDialogFlags];
		[self resetMachineSettingVariables];
		
		//start the "add server" wizard
		[self showEnterHostNameDialogBoxWithInitialText:@""];
		
	} else {
		Machine* m = [self.machines objectAtIndex:selected -1]; //-1 'cause of the "Add remote server" that screws up things
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"machine selected: %@", m);
#endif
		[self showEditMachineView:m];
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
		[result setText:@"Add server" withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		[result addAccessoryOfType:0];
	} else {
		Machine *m = [self.machines objectAtIndex:row-1];
		[result setText:m.serverName withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		
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
	NSLog(@"Updating UI");
#endif
	[self.list reload];
}


#pragma mark -
#pragma mark Dialog Boxes and Data Entry
- (void)showEnterHostNameDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Server - Host" 
			   secondaryInfoText:@"Please enter the IP address or hostname to a remote server. Port number will be added automatically" 
				  textFieldLabel:@"IP/hostname"
				 withInitialText:initalText];
}

- (void)showEnterServerNameDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Server - Name" 
			   secondaryInfoText:@"You may enter a custom server name to be associated with this remote server" 
				  textFieldLabel:@"Server name (optional)" 
				 withInitialText:initalText];
}

- (void)showEnterUsernameDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Server - Secure Server Access - Username" 
			   secondaryInfoText:@"Supply the username to log in to the server if Secure Server Access is enabled" 
				  textFieldLabel:@"Username" 
				 withInitialText:initalText];
}

- (void)showEnterPasswordDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Server - Secure Server Access - Password" 
			   secondaryInfoText:@"Supply the password to log in to the server if Secure Server Access is enabled" 
				  textFieldLabel:@"Password" 
				 withInitialText:initalText];
}

- (void)showDialogBoxWithTitle:(NSString *)title 
			 secondaryInfoText:(NSString *)infoText 
				textFieldLabel:(NSString *)textFieldLabel
			   withInitialText:(NSString *)initialText
{
	BRTextEntryController *textCon = [[BRTextEntryController alloc] init];
	[textCon editor];
	[textCon setTextFieldDelegate:self];
	[textCon setTitle:title];
	[textCon setSecondaryInfoText:infoText];
	[textCon setTextEntryTextFieldLabel:textFieldLabel];
	[textCon setInitialTextEntryText:initialText];
	[[self stack] pushController:textCon];
}

- (void)textDidEndEditing:(id)text
{
	NSString *textEntered = [text stringValue];
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"text string: %@", textEntered);
#endif
	if (!hasCompletedAddNewServerWizardStep1) {
		hasCompletedAddNewServerWizardStep1 = YES;
		self.hostName = textEntered;
		[[self stack] popController];
		
		[self showEnterServerNameDialogBoxWithInitialText:@""];
		
	} else if (!hasCompletedAddNewServerWizardStep2) {
		hasCompletedAddNewServerWizardStep2 = YES;
		//if no custom name was entered, use the host name
		self.serverName = [textEntered isEqualToString:@""] ? self.hostName : textEntered;
		[[self stack] popController];
		
		[self showEnterUsernameDialogBoxWithInitialText:@""];
		
	} else if (!hasCompletedAddNewServerWizardStep3) {
		hasCompletedAddNewServerWizardStep3 = YES;
		self.userName = textEntered;
		[[self stack] popController];
		
		[self showEnterPasswordDialogBoxWithInitialText:@""];
		
	} else {
		//final step completed
		self.password = textEntered;
		[[self stack] popController];
		
		//add machine
		[self addNewMachineWithServerName:self.serverName userName:self.userName password:self.password];
		
		[self setNeedsUpdate];
	}
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
	NSLog(@"MachineManager: Removed machine %@", m);
#endif
	[self.machines removeObject:m];
	[self.machines sortUsingDescriptors:_machineSortDescriptors];
	[self.list reload];
}

-(void)machineWasAdded:(Machine*)m {	
#if LOCAL_DEBUG_ENABLED
	NSLog(@"MachineManager: Added machine %@", m);
#endif
	[self.machines addObject:m];
	[self.machines sortUsingDescriptors:_machineSortDescriptors];
	[self.list reload];
}

-(void)machine:(Machine*)m receivedInfoForConnection:(MachineConnectionBase*)con updated:(ConnectionInfoType)updateMask {
#if LOCAL_DEBUG_ENABLED
	NSLog(@"MachineManager: Received Info For connection %@ from machine %@", con, m);
#endif
}

-(void)machineWasChanged:(Machine*)m {
	if (m==nil) return;	
	//something changed, refresh
	[self.list reload];
}

-(void)machine:(Machine*)m changedClientTo:(ClientConnection*)cc{}

#pragma mark -
#pragma mark TestAndConditionallyAddConnectionProtocol Methods
-(void)machine:(Machine*) m didAcceptConnection:(MachineConnectionBase*) con {
	
}

-(void)machine:(Machine*) m didNotAcceptConnection:(MachineConnectionBase*) con error:(NSError*)err {
	
}

@end

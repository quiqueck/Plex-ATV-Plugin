//
//  HWServerDetailsController.m
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//

#define LOCAL_DEBUG_ENABLED 0

#import "HWServerConnectionsController.h"
#import <plex-oss/MachineManager.h>
#import <plex-oss/Machine.h>
#import <plex-oss/PlexRequest.h>
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation HWServerDetailsController

#define EditServerDialog @"EditServerDialog"

@synthesize serverName = _serverName;
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize hostName = _hostName;
@synthesize portNumber = _portNumber;
@synthesize etherId = _etherId;

- (id) init
{
	if((self = [super init]) != nil) {		
		[self setListTitle:@"All Servers"];
		BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];
		
		[self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		
		[self resetDialogFlags];
		
		_machines = [[NSMutableArray alloc] init];
		
		[[self list] setDatasource:self];
 		[[self list] addDividerAtIndex:1 withLabel:@"List of Servers"];
		
		//make sure we are the delegate
		[[ProxyMachineDelegate shared] registerDelegate:self];
		
		//start the auto detection
		[[MachineManager sharedMachineManager] startAutoDetection];
		
		//[self loadInPersistentMachines];
	}
	return self;
}

-(void)dealloc
{
	[[MachineManager sharedMachineManager] stopAutoDetection];
	[_machines release];
	self.serverName = nil;
	self.userName = nil;
	self.password = nil;
	self.hostName = nil;
	self.etherId = nil;
	self.portNumber = 0;
	
	[super dealloc];
}

- (void)wasPushed {
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"--- Did push controller %@ %@", self, _machines);
#endif
	[[ProxyMachineDelegate shared] registerDelegate:self];
	[self.list reload];
	[super wasPushed];
}

- (void)wasPopped {
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"--- Did pop controller %@ %@", self, _machines);
#endif
	[[ProxyMachineDelegate shared] removeDelegate:self];
	
	[super wasPopped];
}

#pragma mark -
#pragma mark Modify Machine Methods
- (void)addNewMachineWithServerName:(NSString *)serverName userName:(NSString *)userName password:(NSString *)password hostName:(NSString *)hostName portNumber:(int)portNumber etherId:(NSString *)etherId
{
	Machine *machine = [[Machine alloc] initWithServerName:serverName manager:[MachineManager sharedMachineManager] machineID:nil];	
	[machine testAndConditionallyAddConnectionForHostName:hostName port:portNumber etherID:etherId notify:self];
}

- (void)modifyMachine:(Machine *)m
{
	
}

- (void)resetDialogFlags
{
	isEditingHostName = NO;
	isEditingServerName = NO;
	isEditingUserName = NO;
	isEditingPassword = NO;
	
	hasCompletedAddNewRemoteServerWizardStep1 = NO;
	hasCompletedAddNewRemoteServerWizardStep2 = NO;
	hasCompletedAddNewRemoteServerWizardStep3 = NO;	
}

- (void)resetMachineSettingVariables
{	
	self.serverName = nil;
	self.userName = nil;
	self.password = nil;
	self.hostName = nil;
	self.portNumber = NSNotFound;
	self.etherId = nil;
}

#pragma mark -
#pragma mark Menu Controller Delegate Methods
- (id)previewControlForItem:(long)item {
	BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[HWServerConnectionsController class]] pathForResource:@"PlexLogo" ofType:@"png"]];
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
		
		//start the "add remote server" wizard
		[self showEnterHostNameDialogBoxWithInitialText:@""];
		
	} else {
		Machine* m = [_machines objectAtIndex:selected -1]; //-1 'cause of the "Add remote server" that screws up things
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"machine selected: %@", m);
#endif
		[self showEditServerViewForRow:selected];
	}
}

- (float)heightForRow:(long)row {
	return 0.0f;
}

- (long)itemCount {
	return _machines.count + 1;
}

- (id)itemForRow:(long)row {
	BRMenuItem * result = [[BRMenuItem alloc] init];
	
	if(row == 0){
		[result setText:@"Add server" withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		[result addAccessoryOfType:0];
	} else {
		Machine *m = [_machines objectAtIndex:row-1];
		NSString* name = [NSString stringWithFormat:@"%@ (Host: %@)", m.serverName, m.hostName];
		[result setText:name withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		
		[result addAccessoryOfType:1]; //folder
		//		if ([m.userName length] > 0) {
		//			//lock and arrow would be perfect, but can only have single accessory :(
		//			[result addAccessoryOfType:5]; //lock
		//		}
	}	
	
	return [result autorelease];
}

- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (id)titleForRow:(long)row {
	if (row >= [_machines count] || row<0)
		return @"";
	Machine* m = [_machines objectAtIndex:row];
	return m.serverName;
}

-(void)setNeedsUpdate{
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"Updating UI");
#endif
    //  [self updatePreviewController];
    //	[self refreshControllerForModelUpdate];
	[self.list reload];
}


#pragma mark -
#pragma mark Dialog Boxes and Data Entry
- (void)showEnterHostNameDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Remote server - Host" 
			   secondaryInfoText:@"Please enter the IP address or hostname to a remote server. Port number will be added automatically" 
				  textFieldLabel:@"IP address:"
				 withInitialText:initalText];
}

- (void)showEnterServerNameDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Remote server - Name" 
			   secondaryInfoText:@"You may enter a custom server name to be associated with this remote server" 
				  textFieldLabel:@"Server name (optional):" 
				 withInitialText:initalText];
}

- (void)showEnterUsernameDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Remote server - Secure Server Access - Username" 
			   secondaryInfoText:@"Supply the username to log in to the PMS if Secure Server Access is enabled" 
				  textFieldLabel:@"Username:" 
				 withInitialText:initalText];
}

- (void)showEnterPasswordDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Remote server - Secure Server Access - Password" 
			   secondaryInfoText:@"Supply the password to log in to the PMS if Secure Server Access is enabled" 
				  textFieldLabel:@"Password:" 
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
	
	//adding a new remote server
	
	if (!hasCompletedAddNewRemoteServerWizardStep1) {
		hasCompletedAddNewRemoteServerWizardStep1 = YES;
		self.hostName = textEntered;
		[[self stack] popController];
		
		[self showEnterServerNameDialogBoxWithInitialText:@""];
		
	} else if (!hasCompletedAddNewRemoteServerWizardStep2) {
		hasCompletedAddNewRemoteServerWizardStep2 = YES;
		//if no custom name was entered, use the host name
		self.serverName = [textEntered isEqualToString:@""] ? self.hostName : textEntered;
		[[self stack] popController];
		
		[self showEnterUsernameDialogBoxWithInitialText:@""];
		
	} else if (!hasCompletedAddNewRemoteServerWizardStep3) {
		hasCompletedAddNewRemoteServerWizardStep3 = YES;
		self.userName = textEntered;
		[[self stack] popController];
		
		[self showEnterPasswordDialogBoxWithInitialText:@""];
		
	} else {
		//final step completed
		self.password = textEntered;
		[[self stack] popController];
		
		//add machine
		[self addNewMachineWithServerName:self.serverName userName:self.userName password:self.password hostName:self.hostName portNumber:self.portNumber etherId:self.etherId];
		
		[self setNeedsUpdate];		
	}
}

- (void)showEditServerViewForRow:(long)row {
    //get the currently selected row
	Machine* _machine = [_machines objectAtIndex:row-1]; //always -1 since we have "Add remote" as 0 in list
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"showEditRemoteServerViewForRow. row: %d, machine: %@", row, _machine);
#endif
	
	HWServerConnectionsController *serverConnectionsController
}

- (void)optionSelected:(id)sender {
	BROptionDialog *option = sender;
	Machine *_machine = [option.userInfo objectForKey:@"machine"];
	
	if([[sender selectedText] isEqualToString:@"Edit host name"]) {
		
		[[self stack] popController];
		isEditingHostName = YES;
		[self showEnterHostNameDialogBoxWithInitialText:_machine.ip];
		
	} else if([[sender selectedText] isEqualToString:@"Edit server name"]) {
		
		[[self stack] popController];
		isEditingServerName = YES;
		[self showEnterServerNameDialogBoxWithInitialText:_machine.serverName];
		
	} else if([[sender selectedText] isEqualToString:@"Edit login username"]) {
		
		[[self stack] popController];
		isEditingUserName = YES;
		[self showEnterUsernameDialogBoxWithInitialText:_machine.userName];
		
	} else if([[sender selectedText] isEqualToString:@"Edit login password"]) {
		
		[[self stack] popController];
		isEditingPassword = YES;
		[self showEnterPasswordDialogBoxWithInitialText:_machine.password];
		
	} else if([[sender selectedText] isEqualToString:@"Remove from server list"]) {
		
		[[self stack] popController]; //need this so we don't go back to option dialog when going back
		//remove the machine
		[self removeRemoteMachine:_machine];
		[self setNeedsUpdate];
		
		//set the selection to the to top of the list to avoid a weird UI bug where the selection box
		//goes halfway off the screen
		[self.list setSelection:0]; 
		
	} else if ([[sender selectedText] isEqualToString:@"Go back"]) {
		
		//go back to movie listing...
		[[self stack] popController];
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
#pragma mark Machine Manager Delegate
-(void)machineWasRemoved:(Machine*)m{
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"Removed %@", m);
#endif
	[_machines removeObject:m];
}

-(void)machineWasAdded:(Machine*)m{
#warning <Machine Manager Update> Please check this...
	if (!runsServer(m.role) /*|| m.bonjour*/) return;
	
	[_machines addObject:m];
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"Added %@", m);
#endif
	
    //[m resolveAndNotify:self];
	[self setNeedsUpdate];
}

-(void)machineWasChanged:(Machine*)m{
	if (m==nil) return;
	
	if (runsServer(m.role) && ![_machines containsObject:m]){
		[self machineWasAdded:m];
		return;
	} else if (!runsServer(m.role) && [_machines containsObject:m]){
		[_machines removeObject:m];
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"Removed %@", m);
#endif
	} else {
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"Changed %@", m);
#endif
	}
	
	[self setNeedsUpdate];
}

-(void)machine:(Machine*) m didAcceptConnection:(MachineConnectionBase*) con {}

-(void)machine:(Machine*) m didNotAcceptConnection:(MachineConnectionBase*) con error:(NSError*)err {}

-(void)machine:(Machine*)m receivedInfoForConnection:(MachineConnectionBase*)con{}

-(void)machine:(Machine*)m changedClientTo:(ClientConnection*)cc{}

@end

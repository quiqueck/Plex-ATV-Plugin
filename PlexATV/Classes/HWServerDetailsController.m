//
//  HWServerDetailsController.m
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//
//
#define LOCAL_DEBUG_ENABLED 0

#import "HWServerDetailsController.h"
#import <plex-oss/PlexRequest.h>
#import "Constants.h"

@implementation HWServerDetailsController

#define ConnectionDialogIdentifier @"ConnectionDialogIdentifier"

#define ServerPropertyServerNameIndex 0
#define ServerPropertyUserNameIndex 1
#define ServerPropertyPasswordIndex 2

#define ListSaveIndex 3
#define ListResetIndex 4
#define ListCancelIndex 5

#define ListAddNewConnection 6

#define ListItemCount 7


@synthesize machine = _machine;
@synthesize selectedConnection = _selectedConnection;
@synthesize serverName = _serverName;
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize hostName = _hostName;
@synthesize portNumber = _portNumber;

- (id) init
{
	if((self = [super init]) != nil) {
		BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];
		[self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		[[self list] setDatasource:self];
		[[self list] addDividerAtIndex:ListItemCount-1 withLabel:@"Connections"];
		
		connectionsBeingTested = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)dealloc
{
	self.machine = nil;
	self.selectedConnection = nil;
	self.serverName = nil;
	self.userName = nil;
	self.password = nil;
	self.hostName = nil;
	
	[super dealloc];
}

- (void)wasPushed {
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"--- Did push controller %@ %@", self, _machine);
#endif
	[self setListTitle:self.machine.serverName];
	isEditingServerName, isEditingUserName, isEditingPassword = NO;
	[self resetServerSettings];
	[self.list reload];
	[super wasPushed];
}

- (void)wasPopped {
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"--- Did pop controller %@ %@", self, _machine);
#endif	
	[super wasPopped];
}

- (void)saveAndDismissView {
	self.machine.serverName = self.serverName;
#warning frank, how can I set these attributes?
	//	self.machine.userName = self.userName;
	//	self.machine.password = self.password;
	[self dismissView];
}

- (void)dismissView {
	[[self stack] popController];
}

#pragma mark -
#pragma mark Modify Attributes Methods
- (void)resetServerSettings
{	
	self.serverName = self.machine.serverName;
	self.userName = self.machine.userName ? self.machine.userName : @"None";
	self.password = self.machine.password ? self.machine.password : @"None";
}

- (void)resetDialogVariables
{	
	hasCompletedAddNewConnectionWizardStep1 = NO;
	self.hostName = nil;
	self.portNumber = NSNotFound;
}

#pragma mark -
#pragma mark Menu Controller Delegate Methods
- (id)previewControlForItem:(long)item {
	BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[HWServerDetailsController class]] pathForResource:@"PlexLogo" ofType:@"png"]];
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
	if (selected == ServerPropertyServerNameIndex) {
		isEditingServerName = YES;
		[self showEnterServerNameDialogBoxWithInitialText:self.serverName];
		
	} else if (selected == ServerPropertyUserNameIndex) {
		isEditingUserName = YES;
		[self showEnterUsernameDialogBoxWithInitialText:self.serverName];
		
	} else if (selected == ServerPropertyPasswordIndex) {
		isEditingPassword = YES;
		[self showEnterPasswordDialogBoxWithInitialText:self.serverName];
		
	} else if (selected == ListSaveIndex) {
		[self saveAndDismissView];
		
	} else if (selected == ListResetIndex) {
		[self resetServerSettings];
		[self.list reload];
		
	} else if (selected == ListCancelIndex) {
		[self dismissView];
		
	} else if (selected == ListAddNewConnection) {
		[self resetDialogVariables];
		//start the "add new connection" wizard
		[self showEnterHostNameDialogBoxWithInitialText:@""];
		
	} else {
		//connection selected
		int adjustedSelected = selected - ListItemCount;
		MachineConnectionBase *connection = [self.machine.connections objectAtIndex:adjustedSelected];
		self.selectedConnection = connection;
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"connection selected: %@", connection);
#endif
		[self showEditConnectionViewForConnection:self.selectedConnection];
	}
	
}

- (float)heightForRow:(long)row {
	return 0.0f;
}

- (long)itemCount {
	//predefined items + all the connections belonging to this machine
	return ListItemCount+[[self.machine connections] count];
}

- (id)itemForRow:(long)row {
	SMFMenuItem *result;
	NSString *title = [self titleForRow:row];
	for (NSString *connectionsBeingTested in connectionsBeingTested) {
		if ([title isEqualToString:connectionsBeingTested]) {
			//show spinner as it's still being evaluated
			result = [SMFMenuItem progressMenuItem];
		} else {
			//not in progress
			result = [SMFMenuItem folderMenuItem];
		}
	}
	[result setTitle:title];
	return result;
}

- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (id)titleForRow:(long)row {
	NSString *title;
	if (row == ServerPropertyServerNameIndex) {
		title = [NSString stringWithFormat:@"Servername [%@]", self.serverName];
		
	} else if (row == ServerPropertyUserNameIndex) {
		title = [NSString stringWithFormat:@"Username [%@]", self.userName];
		
	} else if (row == ServerPropertyPasswordIndex) {
		title = [NSString stringWithFormat:@"Password [%@]", self.password];
		
	} else if (row == ListSaveIndex) {
		title = @"Save";
		
	} else if (row == ListResetIndex) {
		title = @"Reset changes";
		
	} else if (row == ListCancelIndex) {
		title = @"Cancel";
		
	} else if (row == ListAddNewConnection) {
		title = @"Add new connection";
		
	} else {
		int adjustedRow = row - ListItemCount;
		MachineConnectionBase *connection = [self.machine.connections objectAtIndex:adjustedRow];
		title = [NSString stringWithFormat:@"%@ [%d]", connection.hostName, connection.port];
	}
	return title;
}

- (void)setNeedsUpdate {
	[self.list reload];
}


#pragma mark -
#pragma mark Dialog Boxes and Data Entry
- (void)showEnterServerNameDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Server - Name" 
			   secondaryInfoText:@"You may enter a custom server name to be associated with this remote server" 
				  textFieldLabel:@"Server name (optional)" 
				 withInitialText:initalText];
}

- (void)showEnterUsernameDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Server - Secure Server Access - Username" 
			   secondaryInfoText:@"Supply the username to log in to the PMS if Secure Server Access is enabled" 
				  textFieldLabel:@"Username"
				 withInitialText:initalText];
}

- (void)showEnterPasswordDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Server - Secure Server Access - Password" 
			   secondaryInfoText:@"Supply the password to log in to the PMS if Secure Server Access is enabled" 
				  textFieldLabel:@"Password"
				 withInitialText:initalText];
}

- (void)showEnterHostNameDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Server - IP/Hostname" 
			   secondaryInfoText:@"Please enter the IP address or hostname to a remote server. Port number will be added automatically" 
				  textFieldLabel:@"IP/Hostname"
				 withInitialText:initalText];
}

- (void)showEnterPortNumberDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Server - Port Number" 
			   secondaryInfoText:@"Please enter the IP address or hostname to a remote server. Port number will be added automatically" 
				  textFieldLabel:@"Port Number"
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
	if (isEditingServerName || isEditingUserName || isEditingPassword || isEditingConnectionHostName || isEditingConnectionPortNumber) {
		//editing current property
		if (isEditingServerName) {
			isEditingServerName = NO;
			self.serverName = textEntered;
			
		} else if (isEditingUserName) {
			isEditingUserName = NO;
			self.userName = textEntered;
			
		} else if (isEditingPassword) {
			isEditingPassword = NO;
			self.password = textEntered;
			
		} else if (isEditingConnectionHostName) {
			isEditingConnectionHostName = NO;
			self.selectedConnection.hostName = textEntered;
			
		} else if (isEditingConnectionPortNumber) {
			isEditingConnectionPortNumber = NO;
			self.selectedConnection.port = [textEntered intValue];
		}
	} else {
		//creating new connection
		if (!hasCompletedAddNewConnectionWizardStep1) {
			hasCompletedAddNewConnectionWizardStep1 = YES;
			self.hostName = textEntered;
			[[self stack] popController];
			[self showEnterPortNumberDialogBoxWithInitialText:@""];
		} else {
			//final step completed
			self.portNumber = [textEntered intValue];
			//add and test connection
			[self.machine testAndConditionallyAddConnectionForHostName:self.hostName port:self.portNumber notify:self];
			[connectionsBeingTested addObject:self.hostName];
			
			[[self stack] popController];
		}
	}
	
	
	[self.list reload];
}

#pragma mark -
#pragma mark BROptionDialog Methods
- (void)showEditConnectionViewForConnection:(MachineConnectionBase *)connection {
	BROptionDialog *option = [[BROptionDialog alloc] init];
	[option setIdentifier:ConnectionDialogIdentifier];
	
	[option setUserInfo:[[NSDictionary alloc] initWithObjectsAndKeys:
						 connection, @"connection",
						 nil]];
	
	[option setPrimaryInfoText:@"Edit connection"];
	NSString *secondaryInfo = [NSString stringWithFormat:@"%@ [%d]", connection.hostName, connection.port];
	[option setSecondaryInfoText:secondaryInfo];
	
	[option addOptionText:@"Edit IP/host name"];
	[option addOptionText:@"Edit port number"];
	[option addOptionText:@"Remove connection"];
	[option addOptionText:@"Go back"];
	[option setActionSelector:@selector(optionSelected:) target:self];
	[[self stack] pushController:option];
	[option release];	
}

- (void)optionSelected:(id)sender {
	BROptionDialog *option = sender;
	MachineConnectionBase *connection = [option.userInfo objectForKey:@"connection"];
	
	if([[sender selectedText] isEqualToString:@"Edit IP/host name"]) {
		[[self stack] popController];
		isEditingConnectionHostName = YES;
		[self showEnterHostNameDialogBoxWithInitialText:connection.hostName];
		
	} else if([[sender selectedText] isEqualToString:@"Edit port number"]) {
		[[self stack] popController];
		isEditingConnectionPortNumber = YES;
		[self showEnterPortNumberDialogBoxWithInitialText:[NSString stringWithFormat:@"%d", connection.port]];
		
	} else if([[sender selectedText] isEqualToString:@"Remove from server list"]) {
		[[self stack] popController]; //need this so we don't go back to option dialog when going back
		//remove the connection
		[self setNeedsUpdate];
		
		//set the selection to the to top of the connections list to avoid a weird UI bug where the selection box
		//goes halfway off the screen
		[self.list setSelection:ListItemCount-1];
		
	} else if ([[sender selectedText] isEqualToString:@"Go back"]) {
		//go back to connection listing...
		[[self stack] popController];
	}
}

#pragma mark -
#pragma mark TestAndConditionallyAddConnectionProtocol Methods
-(void)machine:(Machine*)m didAcceptConnection:(MachineConnectionBase*)con {
	
}

-(void)machine:(Machine*)m didNotAcceptConnection:(MachineConnectionBase*)con error:(NSError*)err {
	
}

@end

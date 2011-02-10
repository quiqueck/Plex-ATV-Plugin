//
//  HWServerDetailsController.m
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//
//
#define LOCAL_DEBUG_ENABLED 1

#import "HWServerDetailsController.h"
#import <plex-oss/PlexRequest.h>
#import <plex-oss/MachineConnectionBase.h>
#import "Constants.h"

@implementation HWServerDetailsController

#define ConnectionDialogIdentifier @"ConnectionDialogIdentifier"
#define DefaultServerPortNumber @"32400"

#define ServerPropertyServerNameIndex 0
#define ServerPropertyUserNameIndex 1
#define ServerPropertyPasswordIndex 2

#define ListAddNewConnection 3

#define ListItemCount 4


@synthesize machine = _machine;
@synthesize serverName = _serverName;
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize hostName = _hostName;
@synthesize portNumber = _portNumber;

- (id) init {
	if((self = [super init]) != nil) {
		BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];
		[self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		[[self list] setDatasource:self];
		[[self list] addDividerAtIndex:ListItemCount-1 withLabel:@"Connections"];
		[[self list] addDividerAtIndex:ListItemCount withLabel:@"Current connections"];
	}
	return self;
}

- (id)initAndShowAddNewMachineWizard {
	self = [self init];
	isCreatingNewMachine = YES;
	return self;
}

- (id)initWithMachine:(Machine *)machine {
	self = [self init];
	self.machine = machine;
	return self;
}

-(void)dealloc {
	self.machine = nil;
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
	if (isCreatingNewMachine) {
		[self startAddNewMachineWizard];
	} else {
		[self setListTitle:self.machine.serverName];
		[self.list reload];
	}
	[super wasPushed];
}

- (void)wasPopped {
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"--- Did pop controller %@ %@", self, _machine);
#endif	
	[super wasPopped];
}


#pragma mark -
#pragma mark Adding Wizard Methods
- (void)startAddNewMachineWizard {
	//reset wizard variables
	hasCompletedAddNewMachineWithConnectionWizardStep1 = NO;
	hasCompletedAddNewMachineWithConnectionWizardStep2 = NO;
	hasCompletedAddNewMachineWithConnectionWizardStep3 = NO;
	hasCompletedAddNewMachineWithConnectionWizardStep4 = NO;
	self.hostName, self.userName, self.password = nil;
	self.portNumber = NSNotFound;
	
	[self showEnterServerNameDialogBoxWithInitialText:@""];
}

- (void)addNewMachineWizardWithInput:(NSString *)input {
	if (!hasCompletedAddNewMachineWithConnectionWizardStep1) {
		hasCompletedAddNewMachineWithConnectionWizardStep1 = YES;		
		self.serverName = input;
		[[self stack] popController];
		
		[self showEnterHostNameDialogBoxWithInitialText:@""];
		
	} else if (!hasCompletedAddNewMachineWithConnectionWizardStep2) {
		hasCompletedAddNewMachineWithConnectionWizardStep2 = YES;
		self.hostName = input;
		[[self stack] popController];
		
		[self showEnterPortNumberDialogBoxWithInitialText:DefaultServerPortNumber];
	
	} else if (!hasCompletedAddNewMachineWithConnectionWizardStep3) {
		hasCompletedAddNewMachineWithConnectionWizardStep3 = YES;
		self.portNumber = [input intValue];
		[[self stack] popController];
		
		[self showEnterUsernameDialogBoxWithInitialText:@""];
		
	} else if (!hasCompletedAddNewMachineWithConnectionWizardStep4) {
		hasCompletedAddNewMachineWithConnectionWizardStep4 = YES;
		self.userName = input;
		[[self stack] popController];
		
		[self showEnterPasswordDialogBoxWithInitialText:@""];
		
	} else {
		//final step completed, create a "dummy" machine and test the connection
		self.password = input;
		
		Machine *machine = [[Machine alloc] initWithServerName:self.serverName manager:[MachineManager sharedMachineManager] machineID:nil];
		[machine setUsername:self.userName andPassword:self.password];
		
		[machine testAndConditionallyAddConnectionForHostName:self.hostName port:self.portNumber notify:self];
		
		[[self stack] popController];
		isCreatingNewMachine = NO;
	}
}

- (void)startAddNewConnectionWizard {
	isCreatingNewConnection = YES;
	
	//reset wizard variables
	hasCompletedAddNewConnectionWizardStep1 = NO;
	self.hostName = nil;
	self.portNumber = NSNotFound;
	
	[self showEnterHostNameDialogBoxWithInitialText:@""];
}

- (void)addNewConnectionWizardWithInput:(NSString *)input {
	
	if (!hasCompletedAddNewConnectionWizardStep1) {
		hasCompletedAddNewConnectionWizardStep1 = YES;
		self.hostName = input;
		[[self stack] popController];
		
		[self showEnterPortNumberDialogBoxWithInitialText:DefaultServerPortNumber];
		
	} else {
		//final step completed, test the connection
		self.portNumber = [input intValue];
		
		[self.machine testAndConditionallyAddConnectionForHostName:self.hostName port:self.portNumber notify:self];
		
		//show information screen with spinner
		
		/*[ATMessageView showMessage:NSLocalizedString(@"testing the connection before adding it...", nil) 
		 caption:NSLocalizedString(@"Please Wait", nil) 
		 icon:nil 
		 canClose:NO];
		 */
		
		[[self stack] popController];
		isCreatingNewConnection = NO;
	}
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
		[self showEnterUsernameDialogBoxWithInitialText:self.userName];
		
	} else if (selected == ServerPropertyPasswordIndex) {
		isEditingPassword = YES;
		[self showEnterPasswordDialogBoxWithInitialText:self.userName];
		
	} else if (selected == ListAddNewConnection) {
		//start the "add new connection" wizard
		[self startAddNewConnectionWizard];
		
	} else {
		//connection selected
		int adjustedSelected = selected - ListItemCount;
		MachineConnectionBase *connection = [self.machine.connections objectAtIndex:adjustedSelected];
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"connection selected: %@", connection);
#endif
		[self showEditConnectionViewForConnection:connection];
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
	result = [SMFMenuItem folderMenuItem];
	[result setTitle:title];
	return result;
}

- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (id)titleForRow:(long)row {
	NSString *title;
	if (row == ServerPropertyServerNameIndex) {
		title = [NSString stringWithFormat:@"Servername     %@", self.machine.serverName ? self.machine.serverName : self.machine.usersServerName];
		
	} else if (row == ServerPropertyUserNameIndex) {
		title = [NSString stringWithFormat:@"Username       %@", self.machine.userName ? self.machine.userName : @"None"];
		
	} else if (row == ServerPropertyPasswordIndex) {
		title = [NSString stringWithFormat:@"Password       %@", self.machine.password ? self.machine.password : @"None"];
		
	} else if (row == ListAddNewConnection) {
		title = @"Add new connection";
		
	} else {
		int adjustedRow = row - ListItemCount;
		MachineConnectionBase *connection = [self.machine.connections objectAtIndex:adjustedRow];
		title = [NSString stringWithFormat:@"%@ : %d", connection.hostName, connection.port];
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
			   secondaryInfoText:@"You may enter a custom server name to be associated with this new server" 
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

- (void)showEnterHostNameDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Server - IP/Hostname" 
			   secondaryInfoText:@"Please enter the IP address or hostname to access the server" 
				  textFieldLabel:@"IP/Hostname"
				 withInitialText:initalText];
}

- (void)showEnterPortNumberDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Server - Port Number" 
			   secondaryInfoText:@"Please enter the port number to access the server (default is 32400)" 
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
	if (isCreatingNewMachine) {
		[self addNewMachineWizardWithInput:textEntered];
	} else if (isCreatingNewConnection) {
		[self addNewConnectionWizardWithInput:textEntered];
	} else {
		//editing current property
		if (isEditingServerName) {
			isEditingServerName = NO;
			self.machine.serverName = textEntered;
			
		} else if (isEditingUserName) {
			isEditingUserName = NO;
			[self.machine setUsername:textEntered andPassword:self.machine.password];
			
		} else if (isEditingPassword) {
			isEditingPassword = NO;
			[self.machine setUsername:self.machine.userName andPassword:textEntered];
		}
		[[self stack] popController];
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
	
	[option setPrimaryInfoText:@"Remove connection"];
	NSString *secondaryInfo = [NSString stringWithFormat:@"%@ [%d]", connection.hostName, connection.port];
	[option setSecondaryInfoText:secondaryInfo];
	
	[option addOptionText:@"Remove connection"];
	[option addOptionText:@"Go back"];
	[option setActionSelector:@selector(optionSelected:) target:self];
	[[self stack] pushController:option];
	[option release];	
}

- (void)optionSelected:(id)sender {
	BROptionDialog *option = sender;
	
	if([[sender selectedText] isEqualToString:@"Remove from server list"]) {
		//remove the connection
		MachineConnectionBase *connection = [option.userInfo objectForKey:@"connection"];
		[self.machine removeConnection:connection];
		
		
		[self setNeedsUpdate];
		[[self stack] popController]; //need this so we don't go back to option dialog when going back
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
-(void)machine:(Machine*) m didAcceptConnection:(MachineConnectionBase*) con {
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"machine %@ didAcceptConnection %@", m, con);
#endif
	// add machine to MM (because so far you did not have a machine 
	// for the PMS you were just connecting to)
	
}

-(void)machine:(Machine*) m didNotAcceptConnection:(MachineConnectionBase*) con error:(NSError*)err {
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"machine %@ didNotAcceptConnection %@ with error %@", m, con, err);
#endif
	if (err.code==ConditionallyAddErrorCodeCouldNotConnect) {
		// We could not establish a connection to that machine. 
		// It is either firewalled, not running or the connection data is wrong
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"Machine is either firewalled, not running or the connection data is wrong");
#endif
		
	} else if (err.code==ConditionallyAddErrorCodeNeedCredentials) {
		// We were able to connect, but it looks like the username/password 
		// was wrong, so we were unable to determine which PMS it is
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"Machine login details are incorrect");
#endif
		
	} else if (err.code==ConditionallyAddErrorCodeWrongMachineID) {
		// the connection just added is another way to contact a machine we 
		// already know. In this case, you should add the connection 
		// (using testAndConditionallyAddConnectionForHostName again) 
		// to the machine stored in err.userInfo[machineForConnection]
		//Machine *m = [err.userInfo objectForKey:@"machineForConnection"];
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"Machine is a duplicate. Add this connection to the other machine");
#endif
		
	} else {
		//other kind of failure, cancel operation and reset
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"Connection failed for uknown reason");
#endif
	}	
}

@end

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
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation HWServerDetailsController

#define SecondsBeforeDismissingPrompt 5.0
#define ConnectionDialogIdentifier @"ConnectionDialogIdentifier"
#define DefaultServerPortNumber @"32400"

#define ServerPropertyServerNameIndex	0
#define ServerPropertyUserNameIndex		1
#define ServerPropertyPasswordIndex		2
#define ServerExcludedFromList			3
//---------------------------------------
#define ServerRefreshSections			4
#define ListAddNewConnection			5
//---------------------------------------
#define ListItemCount					6


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
		[[self list] addDividerAtIndex:ListItemCount-2 withLabel:@"Actions"];
		[[self list] addDividerAtIndex:ListItemCount withLabel:@"Current connections"];
		
		//create the wait screen
		waitPromptControl = [[BRWaitPromptControl alloc] init];
		[waitPromptControl setFrame:[BRWindow interfaceFrame]];
		[waitPromptControl setBackgroundColor:[[SMFThemeInfo sharedTheme]blackColor]];
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
	//controller is retained by MM until testConnection calls have been returned
	
	[waitPromptControl release];
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

- (BOOL)isExcludedFromServerList {
	NSArray *machinesExcludedFromServerList = [[HWUserDefaults preferences] objectForKey:PreferencesMachinesExcludedFromServerList];
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"MachineID [%@], Excluded Machines [%@]", _machine.machineID, machinesExcludedFromServerList);
#endif
	return [machinesExcludedFromServerList containsObject:self.machine.machineID];
}

#pragma mark -
#pragma mark Adding Wizard Methods
- (void)startAddNewMachineWizard {
	//set prompt text
	[waitPromptControl setPromptText:@"Testing the connection\nto the new server"];
	
	//reset wizard variables
	isCreatingNewConnection = NO;
	hasCompletedAddNewMachineWithConnectionWizardStep1 = NO;
	hasCompletedAddNewMachineWithConnectionWizardStep2 = NO;
	self.userName, self.password = nil;
	
	[self showEnterServerNameDialogBoxWithInitialText:@""];
}

- (void)addNewMachineWizardWithInput:(NSString *)input {
	[[[BRApplicationStackManager singleton] stack] popController];
	if (!hasCompletedAddNewMachineWithConnectionWizardStep1) {
		hasCompletedAddNewMachineWithConnectionWizardStep1 = YES;		
		self.serverName = input;
		
		[self showEnterUsernameDialogBoxWithInitialText:@""];
	
	} else if (!hasCompletedAddNewMachineWithConnectionWizardStep2) {
		hasCompletedAddNewMachineWithConnectionWizardStep2 = YES;
		self.userName = input;
		
		[self showEnterPasswordDialogBoxWithInitialText:@""];
		
	} else {
		//final step completed of adding machine, 
		self.password = input;
		
		//create a "dummy" machine and retrieve connection information
		Machine *m = [[Machine alloc] initWithServerName:self.serverName manager:[MachineManager sharedMachineManager] machineID:nil];
		self.machine = m;
		[m release];
		[self.machine setUsername:self.userName andPassword:self.password];
		
		[self startAddNewConnectionWizard];
	}
}

- (void)startAddNewConnectionWizard {
	//set the prompt text unless the connection being added is part of a new machine
	if (!isCreatingNewMachine)
		[waitPromptControl setPromptText:@"Testing new connection"];
	
	isCreatingNewConnection = YES;
	
	//reset wizard variables
	hasCompletedAddNewConnectionWizardStep1 = NO;
	self.hostName = nil;
	self.portNumber = NSNotFound;
	
	[self showEnterHostNameDialogBoxWithInitialText:@""];
}

- (void)addNewConnectionWizardWithInput:(NSString *)input {
	[[[BRApplicationStackManager singleton] stack] popController];
	
	if (!hasCompletedAddNewConnectionWizardStep1) {
		hasCompletedAddNewConnectionWizardStep1 = YES;
		self.hostName = input;
		
		[self showEnterPortNumberDialogBoxWithInitialText:DefaultServerPortNumber];
		
	} else {
		//final step completed, test the connection
		self.portNumber = [input intValue];
		
		[self.machine testAndConditionallyAddConnectionForHostName:self.hostName port:self.portNumber notify:self];
		
		//show information screen with spinner		
		[self addControl:waitPromptControl];
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
	
	} else if (selected == ServerExcludedFromList) {
		//toggle whether the server is excluded from the server list
		BOOL isExcluded = [self isExcludedFromServerList];
		NSMutableArray *machinesExcludedFromServerList = [NSMutableArray arrayWithArray:[[HWUserDefaults preferences] objectForKey:PreferencesMachinesExcludedFromServerList]];
		NSString *machineID = [self.machine.machineID copy];
		if (isExcluded) {
			//remove machine from exclusion list
			[machinesExcludedFromServerList removeObject:machineID];
		} else {
			//add machine to exclusion list
			[machinesExcludedFromServerList addObject:machineID];
		}
		[machineID release];
		[[HWUserDefaults preferences] setObject:machinesExcludedFromServerList forKey:PreferencesMachinesExcludedFromServerList];
		[self.list reload];
		
	} else if (selected == ServerRefreshSections) {
		//tell pms to refresh all sections
		[self.machine.request refreshAllSections:NO];
		isRefreshingAllSections = YES;
		[self.list reload];
		
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
	BRMenuItem *menuItem = [[[BRMenuItem alloc] init] autorelease];
	int accessoryType;
	NSString *title = [self titleForRow:row];
	if (row == ServerRefreshSections) {
		menuItem = [[[BRMenuItem alloc] init] autorelease];
		if (isRefreshingAllSections) {
			accessoryType = 6; //spinner icon
		} else {
			accessoryType = 3; //refresh icon
		}
		
	} else if (row == ServerExcludedFromList) {
		accessoryType = 0; //nothing
		
	} else if (row == ListAddNewConnection) {
		accessoryType = 12; //stack/new
		
	} else {
		accessoryType = 1; //folder
	}
	[menuItem addAccessoryOfType:accessoryType];
	[menuItem setText:title withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
	return menuItem;
}

- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (id)titleForRow:(long)row {
	NSString *title;
	if (row == ServerPropertyServerNameIndex) {
		title = [NSString stringWithFormat:@"Servername     %@", self.machine.usersServerName ? self.machine.usersServerName : self.machine.serverName];
		
	} else if (row == ServerPropertyUserNameIndex) {
		title = [NSString stringWithFormat:@"Username        %@", [self.machine.userName length] > 0 ? self.machine.userName : @"None"];
		
	} else if (row == ServerPropertyPasswordIndex) {
		title = [NSString stringWithFormat:@"Password         %@", [self.machine.password length] > 0 ? self.machine.password : @"None"];

	} else if (row == ServerExcludedFromList) {
		title = [NSString stringWithFormat:@"List Status        %@", [self isExcludedFromServerList] ? @"Excluded" : @"Included"];
		
	} else if (row == ServerRefreshSections) {
		title = @"Tell server to refresh all sections";
		
	} else if (row == ListAddNewConnection) {
		title = @"Add new connection";
		
	} else {
		int adjustedRow = row - ListItemCount;
		MachineConnectionBase *connection = [self.machine.connections objectAtIndex:adjustedRow];
		title = [NSString stringWithFormat:@"%@ : %d", connection.hostName, connection.port];
	}
	NSLog(@"new title: %@", title);
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
	[self showDialogBoxWithTitle:@"Connection - IP/Hostname" 
			   secondaryInfoText:@"Please enter the IP address or hostname for this connection" 
				  textFieldLabel:@"IP/Hostname"
				 withInitialText:initalText];
}

- (void)showEnterPortNumberDialogBoxWithInitialText:(NSString *)initalText {
	[self showDialogBoxWithTitle:@"Connection - Port Number" 
			   secondaryInfoText:@"Please enter the port number for this connection (default is 32400)" 
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
	[[[BRApplicationStackManager singleton] stack] pushController:textCon];
	
	NSLog(@"newMachine: %@", isCreatingNewMachine ? @"YES" : @"NO");
	NSLog(@"newConnection: %@", isCreatingNewConnection ? @"YES" : @"NO");
	NSLog(@"isEditingPW: %@", isEditingPassword ? @"YES" : @"NO");
	NSLog(@"isEditingUsername: %@", isEditingUserName ? @"YES" : @"NO");
	NSLog(@"isEditingServername: %@", isEditingServerName ? @"YES" : @"NO");
}

- (void)textDidEndEditing:(id)text
{
	NSString *textEntered = [text stringValue];
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"text string: %@", textEntered);
#endif
	if (isCreatingNewConnection) {
		[self addNewConnectionWizardWithInput:textEntered];
	} else if (isCreatingNewMachine) {
		[self addNewMachineWizardWithInput:textEntered];
	} else {
		//editing current property
		if (isEditingServerName) {
			isEditingServerName = NO;
			self.machine.serverName = textEntered;
#warning does this change required MM writePrefs ^^
			
		} else if (isEditingUserName) {
			isEditingUserName = NO;
			[self.machine setUsername:textEntered andPassword:self.machine.password];
			
		} else if (isEditingPassword) {
			isEditingPassword = NO;
			[self.machine setUsername:self.machine.userName andPassword:textEntered];
		}
		[[[BRApplicationStackManager singleton] stack] popController];
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
	[[[BRApplicationStackManager singleton] stack] pushController:option];
	[option release];	
}

- (void)optionSelected:(id)sender {
	BROptionDialog *option = sender;
	
	if([[sender selectedText] isEqualToString:@"Remove connection"]) {
		//remove the connection
		MachineConnectionBase *connection = [option.userInfo objectForKey:@"connection"];
		[self.machine removeConnection:connection];
		
		[self setNeedsUpdate];
		[[[BRApplicationStackManager singleton] stack] popController]; //need this so we don't go back to option dialog when going back
		//set the selection to the to top of the connections list to avoid a weird UI bug where the selection box
		//goes halfway off the screen
		[self.list setSelection:ListItemCount-1];
		
	} else if ([[sender selectedText] isEqualToString:@"Go back"]) {
		//go back to server details/connection listing...
		[[[BRApplicationStackManager singleton] stack] popController];
	}
}

#pragma mark -
#pragma mark TestAndConditionallyAddConnectionProtocol Methods
-(void)machine:(Machine*)m didAcceptConnection:(MachineConnectionBase*)con {
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"machine %@ didAcceptConnection %@", m, con);
#endif
	NSString *promptText;
	if (isCreatingNewMachine) {
		isCreatingNewMachine = NO;
		isCreatingNewConnection = NO;
		// add machine to MM (because so far you did not have a machine 
		// for the PMS you were just connecting to)
		[[MachineManager sharedMachineManager] addMachine:m];
#warning the lines below are needed to write prefs, but libPlex needs some changes to enable pref writing to custom domain
		//[[MachineManager sharedMachineManager] writeMachinePreferences];
		//[[HWUserDefaults preferences] synchronize];
		promptText = @"Success\n New server added";
	} else {
		isCreatingNewConnection = NO;
		// add connection to machine
		promptText = @"Success\n New connection added";
	}	
	[waitPromptControl setPromptText:promptText];
	
	[waitPromptControl controlWasDeactivated];	
	//wait x amount of seconds then hide waitPromptControl
	[waitPromptControl performSelector:@selector(removeFromParent) withObject:nil afterDelay:SecondsBeforeDismissingPrompt];
	[self.list reload];
}

-(void)machine:(Machine*)m didNotAcceptConnection:(MachineConnectionBase*)con error:(NSError*)err {
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"machine %@ didNotAcceptConnection %@ with error %@", m, con, err);
#endif
	isCreatingNewMachine = NO;
	isCreatingNewConnection = NO;
	NSString *promptText;
	
	if (err.code==ConditionallyAddErrorCodeCouldNotConnect) {
		// We could not establish a connection to that machine. 
		// It is either firewalled, not running or the connection data is wrong
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"Machine is either firewalled, not running or the connection data is wrong");
#endif
		promptText = @"Could not connect.\n Please verify the details, and try again";
		//stop spinner
		[waitPromptControl controlWasDeactivated];
		
		//wait x amount of seconds then hide waitPromptControl and pop view 
		[waitPromptControl performSelector:@selector(removeFromParent) withObject:nil afterDelay:SecondsBeforeDismissingPrompt];
		[[[BRApplicationStackManager singleton] stack] performSelector:@selector(popController) withObject:nil afterDelay:SecondsBeforeDismissingPrompt];
	
		
	} else if (err.code==ConditionallyAddErrorCodeNeedCredentials) {
		// We were able to connect, but it looks like the username/password 
		// was wrong, so we were unable to determine which PMS it is
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"Machine login details are incorrect");
#endif
		promptText = @"User credentials incorrect.\n Please verify the login details, and try again";
		//stop spinner
		[waitPromptControl controlWasDeactivated];
		
		//wait x amount of seconds then hide waitPromptControl and pop view 
		[waitPromptControl performSelector:@selector(removeFromParent) withObject:nil afterDelay:SecondsBeforeDismissingPrompt];
		[[[BRApplicationStackManager singleton] stack] performSelector:@selector(popController) withObject:nil afterDelay:SecondsBeforeDismissingPrompt];
		
		
	} else if (err.code==ConditionallyAddErrorCodeWrongMachineID) {
		// the connection just added is another way to contact a machine we 
		// already know. In this case, you should add the connection 
		// (using testAndConditionallyAddConnectionForHostName again) 
		// to the machine stored in err.userInfo[machineForConnection]
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"Machine is a duplicate. Add this connection to the other machine");
#endif
		Machine *alreadyExistingMachine = [err.userInfo objectForKey:@"machineForConnection"];
		self.machine = alreadyExistingMachine;
		self.hostName = con.hostName;
		self.portNumber = con.port;
		
		[self.machine testAndConditionallyAddConnectionForHostName:self.hostName port:self.portNumber notify:self];
		promptText = [NSString stringWithFormat:@"This connection links to an existing server:\n%@\nWill attempt to add connection", self.machine.usersServerName ? self.machine.usersServerName : self.machine.serverName];
		
		isCreatingNewConnection = YES;
		
	} else {
		//other kind of failure, cancel operation and reset
#ifdef LOCAL_DEBUG_ENABLED
		NSLog(@"Connection failed for uknown reason.");
#endif
		promptText = @"Unknown error";
		
		//stop spinner
		[waitPromptControl controlWasDeactivated];
		
		//wait x amount of seconds then hide waitPromptControl and pop view 
		[waitPromptControl performSelector:@selector(removeFromParent) withObject:nil afterDelay:SecondsBeforeDismissingPrompt];
		[[[BRApplicationStackManager singleton] stack] performSelector:@selector(popController) withObject:nil afterDelay:SecondsBeforeDismissingPrompt];
	}
	
	[waitPromptControl setPromptText:promptText];
}

@end

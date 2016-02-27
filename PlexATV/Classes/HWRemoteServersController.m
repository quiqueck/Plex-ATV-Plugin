//
//  HWRemoteServersController.m
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//

#define LOCAL_DEBUG_ENABLED 0

#import "HWRemoteServersController.h"
#import <plex-oss/MachineManager.h>
#import <plex-oss/Machine.h>
#import <plex-oss/PlexRequest.h>
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation HWRemoteServersController

#define EditServerDialog @"EditServerDialog"

@synthesize hostName = _hostName;
@synthesize serverName = _serverName;
@synthesize userName = _userName;
@synthesize password = _password;

- (id) init
{
	if((self = [super init]) != nil) {		
		[self setListTitle:@"Remote Servers"];
		BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];
		
		[self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		
		//setup variables
		isEditingHostName = NO;
		isEditingServerName = NO;
		isEditingUserName = NO;
		isEditingPassword = NO;
		
		hasCompletedAddNewRemoteServerWizardStep1 = NO;
		hasCompletedAddNewRemoteServerWizardStep2 = NO;
		hasCompletedAddNewRemoteServerWizardStep3 = NO;
		
		_machines = [[NSMutableArray alloc] init];
		
		[[self list] setDatasource:self];
 		[[self list] addDividerAtIndex:1 withLabel:@"List of Remote Servers"];
		
		//make sure we are the delegate
		[[ProxyMachineDelegate shared] registerDelegate:self];
		
		//start the auto detection
		[[MachineManager sharedMachineManager] startAutoDetection];
		
		[self loadInPersistentMachines];
	}
	return self;
}

- (void)loadInPersistentMachines {
	//load in persistent machines
	persistentRemoteServers = [[[HWUserDefaults preferences] arrayForKey:PreferencesRemoteServerList] mutableCopy];
	if (!persistentRemoteServers) {
		persistentRemoteServers = [[NSMutableArray alloc] init];
	}
	
	NSArray *currentMachines = _machines;//[[MachineManager sharedMachineManager] machines];
	for (NSDictionary *persistentRemoteServer in persistentRemoteServers) {
		NSString *hostName = [persistentRemoteServer objectForKey:PreferencesRemoteServerHostName];
		NSString *serverName = [persistentRemoteServer objectForKey:PreferencesRemoteServerName];
		NSString *userName = [persistentRemoteServer objectForKey:PreferencesRemoteServerUserName];
		NSString *password = [persistentRemoteServer objectForKey:PreferencesRemoteServerPassword];
		
		//check if the machine manager already knows about this machine
		NSPredicate *machinePredicate = [NSPredicate predicateWithFormat:@"hostName == %@ AND serverName == %@", hostName, serverName];
		NSArray *matchingMachines = [currentMachines filteredArrayUsingPredicate:machinePredicate];
		if ([matchingMachines count] == 0) {
#ifdef LOCAL_DEBUG_ENABLED
			NSLog(@"Adding persistant remote machine with hostName [%@] and serverName [%@] ", hostName, serverName);
#endif
			Machine *m = [[Machine alloc] initWithServerName:serverName hostName:hostName port:32400 role:MachineRoleServer manager:[MachineManager sharedMachineManager] etherID:nil];
			m.ip = hostName;
			m.userName = userName;
#warning quiqueck: how can we set the password?
			//m.password = password;
			
			[m resolveAndNotify:self];
			[m autorelease];
		} else {
#ifdef LOCAL_DEBUG_ENABLED
			NSLog(@"Machine already exists with hostName [%@] and serverName [%@] ", hostName, serverName);
#endif
		}
		
	}
}


-(void)dealloc
{
	[[MachineManager sharedMachineManager] stopAutoDetection];
	[_machines release];
	self.hostName = nil;
	self.serverName = nil;
	self.userName = nil;
	self.password = nil;
	
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
#pragma mark Modify Remote Server List
- (NSDictionary *)persistentRemoteServerWithHostName:(NSString *)aHostName andServerName:(NSString *)aServerName {
	NSDictionary *result = nil;
	for (NSDictionary *persistentRemoteServer in persistentRemoteServers) {
		NSString *hostName = [persistentRemoteServer objectForKey:PreferencesRemoteServerHostName];
		NSString *serverName = [persistentRemoteServer objectForKey:PreferencesRemoteServerName];
		if ([aServerName isEqualToString:serverName] && [aHostName isEqualToString:hostName]) {
			result = persistentRemoteServer;
			break;
		}
	}
	return result;
}

- (void)modifyRemoteMachine:(Machine *)m withHostName:(NSString *)hostName serverName:(NSString *)serverName userName:(NSString *)userName password:(NSString *)password {
	NSDictionary *oldEntry = [self persistentRemoteServerWithHostName:m.hostName andServerName:m.serverName];
	NSDictionary *newEntry = [NSDictionary dictionaryWithObjectsAndKeys: 
							  hostName, PreferencesRemoteServerHostName,
							  serverName, PreferencesRemoteServerName,
							  userName, PreferencesRemoteServerUserName,
							  password, PreferencesRemoteServerPassword,
							  nil];
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"Replacing persistent remote server entry [%@] [%@]", oldEntry, newEntry);
#endif
	int indexOfEntry = [persistentRemoteServers indexOfObject:oldEntry];
	
	[persistentRemoteServers replaceObjectAtIndex:indexOfEntry withObject:newEntry];
	[[HWUserDefaults preferences] setObject:persistentRemoteServers forKey:PreferencesRemoteServerList];
	
	//update machine	
	m.serverName = serverName;
	m.hostName = hostName;
	m.ip = hostName;
	m.userName = userName;
#warning quiqueck: how can we set the password?
	//m.password = password;
#warning quiqueck: is this next line needed?
	[m resolveAndNotify:self];
}

- (void)addNewRemoteMachineWithHostName:(NSString *)hostName serverName:(NSString *)serverName userName:(NSString *)userName password:(NSString *)password {
	//yes, the password is stored in plain text
	NSDictionary *newRemoteServer = [NSDictionary dictionaryWithObjectsAndKeys:
									 hostName, PreferencesRemoteServerHostName,
									 serverName, PreferencesRemoteServerName,
									 userName, PreferencesRemoteServerUserName,
									 password, PreferencesRemoteServerPassword,
									 nil];
	[persistentRemoteServers addObject:newRemoteServer];
	[[HWUserDefaults preferences] setObject:persistentRemoteServers forKey:PreferencesRemoteServerList];
	
	Machine *m = [[Machine alloc] initWithServerName:serverName hostName:hostName port:32400 role:MachineRoleServer manager:[MachineManager sharedMachineManager] etherID:nil];
	m.ip = hostName;
	m.userName = userName;
#warning quiqueck: how can we set the password?
	//m.password = password;
	
	[m resolveAndNotify:self];
	[m autorelease];
}

- (void)removeRemoteMachine:(Machine *)m {
	NSDictionary *persistentRemoteServer = [self persistentRemoteServerWithHostName:m.hostName andServerName:m.serverName];
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"Removing persistent remote server entry [%@]", persistentRemoteServer);
#endif
	[persistentRemoteServers removeObject:persistentRemoteServer];
	[[HWUserDefaults preferences] setObject:persistentRemoteServers forKey:PreferencesRemoteServerList];
	
	[[MachineManager sharedMachineManager] removeMachine:m];
}


#pragma mark -
#pragma mark Menu Controller Delegate Methods
- (id)previewControlForItem:(long)item {
	BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[HWRemoteServersController class]] pathForResource:@"PlexLogo" ofType:@"png"]];
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
		//reset variables
		hasCompletedAddNewRemoteServerWizardStep1 = NO;
		hasCompletedAddNewRemoteServerWizardStep2 = NO;
		hasCompletedAddNewRemoteServerWizardStep3 = NO;
		self.hostName = nil;
		self.serverName = nil;
		self.userName = nil;
		self.password = nil;
		
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
		[result setText:@"Add remote server" withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		[result addAccessoryOfType:0];
	} else {
		Machine *m = [_machines objectAtIndex:row-1];
		NSString* name = [NSString stringWithFormat:@"%@ (Host: %@)", m.serverName, m.hostName];
		[result setText:name withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		
		//[result addAccessoryOfType:1]; //folder
		if ([m.userName length] > 0) {
			//lock and arrow would be perfect, but can only have single accessory :(
			[result addAccessoryOfType:5]; //lock
		}
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
#pragma mark Text input stuff
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
	
	//check if the user was adding a new remote server, or editing details of previous one
	if (isEditingHostName || isEditingServerName || isEditingUserName || isEditingPassword) {
		//editing a previously created remote server
		
		long selected = [self getSelection];
		Machine *m = [_machines objectAtIndex:selected-1]; //always -1 since we have "Add remote" as 0 in list
		
		//setup all the variables, and then we will be modifying just one of them
		NSString *hostName = m.hostName;
		NSString *serverName = m.serverName;
		NSString *userName = m.userName;
		NSString *password = m.password;
		
		if (isEditingHostName) {
			//editing a previous entered remote server's host name
			isEditingHostName = NO;
			hostName = textEntered;
		} else if (isEditingServerName) {
			//editing a previous entered remote server's custom server name
			isEditingServerName = NO;
			serverName = textEntered;
		} else if (isEditingUserName) {
			isEditingUserName = NO;
			userName = textEntered;
		} else if (isEditingPassword) {
			isEditingPassword = NO;
			userName = textEntered;
		}
		
		[self modifyRemoteMachine:m withHostName:hostName serverName:serverName userName:userName password:password];
		
		[[self stack] popController];
		[self setNeedsUpdate];
		
	} else {
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
			[self addNewRemoteMachineWithHostName:self.hostName serverName:self.serverName userName:self.userName password:self.password];
			
			[self setNeedsUpdate];
		}

	}
}

- (void)showEditServerViewForRow:(long)row {
    //get the currently selected row
	Machine* _machine = [_machines objectAtIndex:row-1]; //always -1 since we have "Add remote" as 0 in list
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"showEditRemoteServerViewForRow. row: %d, machine: %@, bonjour: %@", row, _machine, _machine.bonjour);
#endif
	
	if (!_machine.bonjour){
		BROptionDialog *option = [[BROptionDialog alloc] init];
		[option setIdentifier:EditServerDialog];
		
		[option setUserInfo:[[NSDictionary alloc] initWithObjectsAndKeys:
							 _machine, @"machine",
							 nil]];
		
		[option setPrimaryInfoText:@"Edit remote server"];
		NSString *secondaryInfo = [NSString stringWithFormat:@"%@ (Host: %@)", _machine.serverName, _machine.hostName];
		[option setSecondaryInfoText:secondaryInfo];
		
		[option addOptionText:@"Edit host name"];
		[option addOptionText:@"Edit server name"];
		[option addOptionText:@"Edit login username"];
		[option addOptionText:@"Edit login password"];
		[option addOptionText:@"Remove from server list"];
		[option addOptionText:@"Go back"];
		[option setActionSelector:@selector(optionSelected:) target:self];
		[[self stack] pushController:option];
		[option release];
	}
	
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
	if (!runsServer(m.role) || m.bonjour) return;
	
	[_machines addObject:m];
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"Added %@", m);
#endif
	
    //[m resolveAndNotify:self];
	[self setNeedsUpdate];
}

-(void)machineStateDidChange:(Machine*)m{
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

-(void)machineResolved:(Machine*)m{
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"Resolved %@", m);
#endif
	if (![_machines containsObject:m]){
		[[MachineManager sharedMachineManager] addMachine:m];
	}
}

-(void)machineDidNotResolve:(Machine*)m{
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"Unable to Resolve %@", m);
#endif
}

-(void)machineReceivedClients:(Machine*)m{
#ifdef LOCAL_DEBUG_ENABLED
	NSLog(@"Got list of clients %@", m);
#endif
}

@end

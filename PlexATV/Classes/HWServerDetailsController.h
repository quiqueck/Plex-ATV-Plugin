//
//  HWServerDetailsController.h
//  atvTwo
//
//  Created by ccjensen on 02/02/2011.
//

#import <Foundation/Foundation.h>
#import <plex-oss/Machine.h>
#import <plex-oss/MachineConnectionBase.h>

@interface HWServerDetailsController : SMFMediaMenuController <TestAndConditionallyAddConnectionProtocol> {
	Machine *_machine;
	MachineConnectionBase *_selectedConnection;
	
	BOOL hasCompletedAddNewConnectionWizardStep1;
	NSMutableArray *connectionsBeingTested;
	
	BOOL isEditingServerName;
	BOOL isEditingUserName;
	BOOL isEditingPassword;
	
	BOOL isEditingConnectionHostName;
	BOOL isEditingConnectionPortNumber;
	
	NSString *_serverName;
	NSString *_userName;
	NSString *_password;
	
	NSString *_hostName;
	int _portNumber;
}
@property (retain) Machine *machine;
@property (retain) MachineConnectionBase *selectedConnection;
@property (copy) NSString *serverName;
@property (copy) NSString *userName;
@property (copy) NSString *password;
@property (copy) NSString *hostName;
@property (assign) int portNumber;

//custom methods
- (void)saveAndDismissView;
- (void)dismissView;
- (void)resetServerSettings;
- (void)resetDialogVariables;

- (void)showEnterServerNameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterUsernameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterPasswordDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterHostNameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterPortNumberDialogBoxWithInitialText:(NSString *)initalText;

- (void)showDialogBoxWithTitle:(NSString *)title secondaryInfoText:(NSString *)infoText textFieldLabel:(NSString *)textFieldLabel withInitialText:(NSString *)initialText;

- (void)showEditConnectionViewForConnection:(MachineConnectionBase *)connection;

//list provider
- (float)heightForRow:(long)row;
- (long)itemCount;
- (id)itemForRow:(long)row;
- (BOOL)rowSelectable:(long)selectable;
- (id)titleForRow:(long)row;
- (void)setNeedsUpdate;

@end

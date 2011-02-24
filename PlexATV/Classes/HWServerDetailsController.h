//
//  HWServerDetailsController.h
//  atvTwo
//
//  Created by ccjensen on 02/02/2011.
//

#import <Foundation/Foundation.h>
#import <plex-oss/Machine.h>
#import <plex-oss/MachineConnectionBase.h>

@interface HWServerDetailsController : SMFMediaMenuController <TestAndConditionallyAddConnectionProtocol, SMFListDropShadowDatasource,SMFListDropShadowDelegate> {
	Machine *_machine;
	BRWaitPromptControl *waitPromptControl;
	SMFListDropShadowControl *listDropShadowControl; //popup
	
	//add new machine flags
	BOOL isCreatingNewMachine;
	BOOL hasCompletedAddNewMachineWithConnectionWizardStep1; //if completed proceed to step 2
	BOOL hasCompletedAddNewMachineWithConnectionWizardStep2; //if completed proceed to step 3
	
	//editing machine specific flags
	BOOL isEditingServerName;
	BOOL isEditingUserName;
	BOOL isEditingPassword;
	BOOL isDeletingMachine;
	
	//add new connection flags
	BOOL isCreatingNewConnection;
	BOOL hasCompletedAddNewConnectionWizardStep1; //if completed proceed to step 2
	
	//editing connection specific variables
	BOOL isDeletingConnection;
	MachineConnectionBase *_selectedConnection;
	
	//action flags
	BOOL isRefreshingAllSections;
	
	NSString *_serverName;
	NSString *_userName;
	NSString *_password;
	NSString *_hostName;
	uint _portNumber;
}
@property (retain) Machine *machine;
@property (copy) NSString *serverName;
@property (copy) NSString *userName;
@property (copy) NSString *password;
@property (copy) NSString *hostName;
@property (assign) uint portNumber;
@property (retain) MachineConnectionBase *selectedConnection;

//custom methods
- (id)initAndShowAddNewMachineWizard;
- (id)initWithMachine:(Machine *)machine;

- (BOOL)isExcludedFromServerList;

- (void)startAddNewMachineWizard;
- (void)addNewMachineWizardWithInput:(NSString *)input;
- (void)startAddNewConnectionWizard;
- (void)addNewConnectionWizardWithInput:(NSString *)input;

- (void)showEnterHostNameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterPortNumberDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterServerNameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterUsernameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterPasswordDialogBoxWithInitialText:(NSString *)initalText;

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

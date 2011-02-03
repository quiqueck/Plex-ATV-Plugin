//
//  HWRemoteServersController.h
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//

#import <Foundation/Foundation.h>
#import "SMFramework.h"

@interface HWRemoteServersController : SMFMediaMenuController<MachineManagerDelegate> {
	NSMutableArray		*_machines;
	NSMutableArray *persistentRemoteServers;
	
	//add new server variables
	BOOL hasCompletedAddNewRemoteServerWizardStep1; //if completed proceed to step 2
	BOOL hasCompletedAddNewRemoteServerWizardStep2; //if completed proceed to step 3
	BOOL hasCompletedAddNewRemoteServerWizardStep3; //if completed proceed to step 4
	
	NSString *_hostName;
	NSString *_serverName;
	NSString *_userName;
	NSString *_password;
	
	BOOL isEditingHostName;
	BOOL isEditingServerName;
	BOOL isEditingUserName;
	BOOL isEditingPassword;
}
@property (copy) NSString *hostName;
@property (copy) NSString *serverName;
@property (copy) NSString *userName;
@property (copy) NSString *password;

//custom methods
- (void)loadInPersistentMachines;
- (NSDictionary *)persistentRemoteServerWithHostName:(NSString *)aHostName andServerName:(NSString *)aServerName;

- (void)modifyRemoteMachine:(Machine *)m withHostName:(NSString *)hostName serverName:(NSString *)serverName userName:(NSString *)userName password:(NSString *)password;
- (void)addNewRemoteMachineWithHostName:(NSString *)hostName serverName:(NSString *)serverName userName:(NSString *)userName password:(NSString *)password;
- (void)removeRemoteMachine:(Machine *)m;

- (void)showEnterHostNameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterServerNameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterUsernameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterPasswordDialogBoxWithInitialText:(NSString *)initalText;
- (void)showDialogBoxWithTitle:(NSString *)title secondaryInfoText:(NSString *)infoText textFieldLabel:(NSString *)textFieldLabel withInitialText:(NSString *)initialText;
- (void)showEditServerViewForRow:(long)row;

//list provider
- (float)heightForRow:(long)row;
- (long)itemCount;
- (id)itemForRow:(long)row;
- (BOOL)rowSelectable:(long)selectable;
- (id)titleForRow:(long)row;
- (void)setNeedsUpdate;

@end

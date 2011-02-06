//
//  HWServersController.h
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//

#import <Foundation/Foundation.h>
#import <plex-oss/Machine.h>

@interface HWServersController : SMFMediaMenuController<MachineManagerDelegate, TestAndConditionallyAddConnectionProtocol> {
	NSMutableArray *_machines;
	
	//add new server variables
	BOOL hasCompletedAddNewRemoteServerWizardStep1; //if completed proceed to step 2
	BOOL hasCompletedAddNewRemoteServerWizardStep2; //if completed proceed to step 3
	BOOL hasCompletedAddNewRemoteServerWizardStep3; //if completed proceed to step 4
	
	NSString *_serverName;
	NSString *_userName;
	NSString *_password;
	NSString *_hostName;
	int _portNumber;
	NSString *_etherId;
}

@property (copy) NSMutableArray *machines;
@property (copy) NSString *serverName;
@property (copy) NSString *userName;
@property (copy) NSString *password;
@property (copy) NSString *hostName;
@property (assign) int portNumber;
@property (copy) NSString *etherId;

//custom methods
- (void)resetDialogFlags;
- (void)resetMachineSettingVariables;

- (void)addNewMachineWithServerName:(NSString *)serverName userName:(NSString *)userName password:(NSString *)password hostName:(NSString *)hostName portNumber:(int)portNumber etherId:(NSString *)etherId;
- (void)modifyMachine:(Machine *)m;

- (void)showEnterHostNameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterServerNameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterUsernameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterPasswordDialogBoxWithInitialText:(NSString *)initalText;
- (void)showDialogBoxWithTitle:(NSString *)title secondaryInfoText:(NSString *)infoText textFieldLabel:(NSString *)textFieldLabel withInitialText:(NSString *)initialText;

//list provider
- (float)heightForRow:(long)row;
- (long)itemCount;
- (id)itemForRow:(long)row;
- (BOOL)rowSelectable:(long)selectable;
- (id)titleForRow:(long)row;
- (void)setNeedsUpdate;

@end

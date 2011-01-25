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
	BOOL hasCompletedHostNameEntry;
	NSString *_hostName;
	NSString *_serverName;
	
	BOOL isEditingServerName;
	BOOL isEditingHostName;
}
@property (copy) NSString *hostName;
@property (copy) NSString *serverName;

//custom methods
- (void)loadInPersistentMachines;
- (NSDictionary *)persistentRemoteServerWithHostName:(NSString *)aHostName andServerName:(NSString *)aServerName;

- (void)modifyRemoteMachine:(Machine *)m withHostName:(NSString *)hostName andServerName:(NSString *)serverName;
- (void)addNewRemoteMachineWithHostName:(NSString *)hostName andServerName:(NSString *)serverName;
- (void)removeRemoteMachine:(Machine *)m;

- (void)showEnterHostNameDialogBoxWithInitialText:(NSString *)initalText;
- (void)showEnterServerNameDialogBoxWithInitialText:(NSString *)initalText;
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

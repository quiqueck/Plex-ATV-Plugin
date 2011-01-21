  //
  //  HWPmsListController.m
  //  atvTwo
  //
  //  Created by Serendipity on 10/01/2011.
  //  Copyright 2011 __MyCompanyName__. All rights reserved.
  //



#import "HWPmsListController.h"
#import <plex-oss/MachineManager.h>
#import <plex-oss/Machine.h>
#import <plex-oss/PlexRequest.h>
#import "Constants.h"
#import "SMFDefines.h"

@implementation HWPmsListController

#define RemoveServerDialog @"RemoveServerDialog"

- (id) init
{
	if((self = [super init]) != nil) {		
		[self setListTitle:@"Select default server"];
		BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];
		
		[self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		
		_names = [[NSMutableArray alloc] init];
		
      //make sure we are the delegate
    [[ProxyMachineDelegate shared] registerDelegate:self];
		
      //start the auto detection
		[[MachineManager sharedMachineManager] startAutoDetection];
		
		[[self list] setDatasource:self];
 		[[self list] addDividerAtIndex:1 withLabel:@"Servers"];
	}
	return self;
}	


-(void)dealloc
{
	[[MachineManager sharedMachineManager] stopAutoDetection];
	[_names release];
	
	[super dealloc];
}

- (void)wasPushed{
  NSLog(@"--- Did push controller %@ %@", self, _names);
  [[ProxyMachineDelegate shared] registerDelegate:self];
  
  [super wasPushed];
}

- (void)wasPopped{
  NSLog(@"--- Did pop controller %@", self);
  [[ProxyMachineDelegate shared] removeDelegate:self];
  
  [super wasPopped];
}



- (id)previewControlForItem:(long)item

{
	BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[HWPmsListController class]] pathForResource:@"PlexLogo" ofType:@"png"]];
	
	
	BRImageAndSyncingPreviewController *obj = [[BRImageAndSyncingPreviewController alloc] init];
	
	[obj setImage:theImage];
	
	return [obj autorelease];
	
}

- (BOOL)shouldRefreshForUpdateToObject:(id)object{
	return YES;
}

- (void)itemSelected:(long)selected {
	if (selected == 0) {
    [self serverSearch];    
  }
  else {
    Machine* m = [_names objectAtIndex:selected];
    NSLog(@"machine selected: %@", m);
    
    [[SMFPreferences preferences] setObject:m.serverName forKey:PreferencesDefaultServerName];
    [[SMFPreferences preferences] setObject:m.uid forKey:PreferencesDefaultServerUid];    
  }

	[self setNeedsUpdate];
}

- (float)heightForRow:(long)row {
	return 50.0f;
}

- (long)itemCount {
	return _names.count + 1;
}

- (id)itemForRow:(long)row {
  BRMenuItem * result = [[BRMenuItem alloc] init];
  
	if(row == 0){
		[result setText:@"Add remote server" withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		[result addAccessoryOfType:0];
  }
	else {
    Machine *m = [_names objectAtIndex:row-1];
    NSString* name = [NSString stringWithFormat:@"%@", m.serverName, m];
    [result setText:name withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
    
    NSString *defaultServerUid = [[SMFPreferences preferences] objectForKey:PreferencesDefaultServerUid];
    if ([m.uid isEqualToString:defaultServerUid]) {
      [result addAccessoryOfType:17]; //checkmark
    }
  }	
	
	return [result autorelease];
}

- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (id)titleForRow:(long)row {
	if (row >= [_names count] || row<0)
		return @"";
	Machine* m = [_names objectAtIndex:row];
	return m.serverName;
}

-(void)setNeedsUpdate{
	NSLog(@"Updating UI");
    //  [self updatePreviewController];
    //	[self refreshControllerForModelUpdate];
	[self.list reload];
}

#pragma mark
#pragma mark Text input stuff

- (void)serverSearch
{
  BRTextEntryController *textCon = [[BRTextEntryController alloc] init];
  [textCon editor];
  [textCon setTextFieldDelegate:self];
  [textCon setTitle:@"Add a remote server"];
  [textCon setSecondaryInfoText:@"Please enter the IP address or hostname to a remote server. Port number will be added automatically"];
  [textCon setTextEntryTextFieldLabel:@"IP address:"];
  [[self stack] pushController:textCon];
}

- (void)textDidEndEditing:(id)text
{
  NSLog(@"text string: %@", [text stringValue]);
  NSString *host = [text stringValue];
  Machine *m = [[Machine alloc] initWithServerName:host hostName:host port:32400 role:MachineRoleServer manager:[MachineManager sharedMachineManager] etherID:nil];
  m.ip = host;
  
  [m resolveAndNotify:self];
  NSLog(@"machine: %@", m);
  [m autorelease];
  [[self stack] popController];
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
      if([event value] == 1) {
          //get the index of currently selected row
				long selected = [self getSelection];
				[self showRemoveServerViewForRow:selected];
			}
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
      NSLog(@"play/pause event");
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

- (void)showRemoveServerViewForRow:(long)row {
    //get the currently selected row


	Machine* _machine = [_names objectAtIndex:row-1]; //always -1 since we have "Add remote" as 0 in list
  NSLog(@"showRemoveServerViewForRow. row: %d, machine: %@, bonjour: %@", row, _machine, _machine.bonjour);

	if (!_machine.bonjour){
		BROptionDialog *option = [[BROptionDialog alloc] init];
		[option setIdentifier:RemoveServerDialog];
		
		[option setUserInfo:[[NSDictionary alloc] initWithObjectsAndKeys:
                         _machine, @"machine",
                         nil]];
		
		[option setPrimaryInfoText:@"Remove remote server"];
		[option setSecondaryInfoText:@"You can always add the remote server again later"];
		
		[option addOptionText:[NSString stringWithFormat:@"Remove %@ from server list", _machine.serverName]];
		[option addOptionText:@"Go back"];
		[option setActionSelector:@selector(optionSelected:) target:self];
		[[self stack] pushController:option];
		[option release];
	}

}

- (void)optionSelected:(id)sender {
	BROptionDialog *option = sender;
	Machine *_machineToRemove = [option.userInfo objectForKey:@"machine"];
  
  if([[sender selectedText] hasPrefix:@"Remove"]) {
    [[self stack] popController]; //need this so we don't go back to option dialog when going back
    NSLog(@"Removing machine %@ from server list", _machineToRemove.serverName);
      [[MachineManager sharedMachineManager] removeMachine:_machineToRemove];
  } else if ([[sender selectedText] isEqualToString:@"Go back"]) {
      //go back to movie listing...
    [[self stack] popController];
  }
  
}

#pragma mark
#pragma mark Machine Manager Delegate
-(void)machineWasRemoved:(Machine*)m{
  NSLog(@"Removed %@", m);
  [_names removeObject:m];
}

-(void)machineWasAdded:(Machine*)m{
	if (!runsServer(m.role)) return;
	
	[_names addObject:m];
	NSLog(@"Added %@", m);
	
    //[m resolveAndNotify:self];
	[self setNeedsUpdate];
}

-(void)machineStateDidChange:(Machine*)m{
	if (m==nil) return;
	
	if (runsServer(m.role) && ![_names containsObject:m]){
		[self machineWasAdded:m];
		return;
	} else if (!runsServer(m.role) && [_names containsObject:m]){
		[_names removeObject:m];
		NSLog(@"Removed %@", m);
	} else {
		NSLog(@"Changed %@", m);
	}
	
	[self setNeedsUpdate];
}

-(void)machineResolved:(Machine*)m{
	NSLog(@"Resolved %@", m);
  [[MachineManager sharedMachineManager] addMachine:m];
}

-(void)machineDidNotResolve:(Machine*)m{
	NSLog(@"Unable to Resolve %@", m);
}

-(void)machineReceivedClients:(Machine*)m{
	NSLog(@"Got list of clients %@", m);
}
@end

//
//  ProxyMachineDelegate.m
//  atvTwo
//
//  Created by Frank Bauer on 14.01.11.
//

#import "ProxyMachineDelegate.h"



@implementation ProxyMachineDelegate

+(ProxyMachineDelegate*)shared {
	static ProxyMachineDelegate* _proxyMachineDelegate = nil;
	if (_proxyMachineDelegate==nil){
		_proxyMachineDelegate = [[ProxyMachineDelegate alloc] init];
	}
	
	return _proxyMachineDelegate;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		delegates = [[NSMutableArray alloc] initWithCapacity:3];
	}
	return self;
}

- (void) dealloc
{
	[delegates release];
	[super dealloc];
}

-(void)registerDelegate:(id<MachineManagerDelegate>)del{
	if ([MachineManager sharedMachineManager].delegate != self) {
		NSLog(@"Hooking up machine Delegate");
		[[MachineManager sharedMachineManager] setDelegate:self];
	}
	
	if (![delegates containsObject:del] && del!=nil){
		NSLog(@"Added machine Delegate %@", del);
		[delegates addObject:del];
		
		NSArray* mc = [[MachineManager sharedMachineManager] threadSafeMachines];
		for (Machine* m in mc){
			[del machineWasAdded:m];
		}
	}
	
	
}

-(void)removeDelegate:(id<MachineManagerDelegate>)del{
	NSLog(@"Removed machine Delegate %@", del);
	[delegates removeObject:del];
}



//required
-(void)machineWasAdded:(Machine*)m;{
	for (id<MachineManagerDelegate> d in delegates){
		NSLog(@"Send machineWasAdded to %@", d);
		[d machineWasAdded:m];
	}
}

-(void)machineWasRemoved:(Machine*)m{
	for (id<MachineManagerDelegate> d in delegates){
		NSLog(@"Send machineWasRemoved to %@", d);
		[d machineWasRemoved:m];
	}
}


//optional
-(void)machineWasChanged:(Machine*)m{
	for (id<MachineManagerDelegate> d in delegates){
		NSLog(@"Send machineWasChanged to %@", d);
		if ([d respondsToSelector:@selector(machineWasChanged:)]) {
			[d machineWasChanged:m];
		}
	}
}

-(void)machine:(Machine*)m changedConnection:(MachineConnectionBase*)con{
	for (id<MachineManagerDelegate> d in delegates){
		NSLog(@"Send machine:changedConnection to %@", d);
		if ([d respondsToSelector:@selector(machine:changedConnection:)]) {
			[d machine:m changedConnection:con];
		}
	}
}

-(void)machine:(Machine*)m updatedInfo:(ConnectionInfoType)updateMask{
	for (id<MachineManagerDelegate> d in delegates){
		NSLog(@"Send machine:updatedInfo to %@", d);
		if ([d respondsToSelector:@selector(machine:updatedInfo:)]) {
			[d machine:m updatedInfo:updateMask];
		}
	}
}

-(void)machine:(Machine*)m changedClientTo:(ClientConnection*)cc{
	for (id<MachineManagerDelegate> d in delegates){
		NSLog(@"Send machine:changedClientTo to %@", d);
		if ([d respondsToSelector:@selector(machine:changedClientTo:)]) {
			[d machine:m changedClientTo:cc];
		}
	}
}

-(void)machine:(Machine*)m receivedInfoForConnection:(MachineConnectionBase*)con updated:(ConnectionInfoType)updateMask{
	for (id<MachineManagerDelegate> d in delegates){
		NSLog(@"Send machine:receivedInfoForConnection to %@", d);
		if ([d respondsToSelector:@selector(machine:receivedInfoForConnection:updated:)]) {
			[d machine:m receivedInfoForConnection:con updated:updateMask];
		}
	}
}



@end

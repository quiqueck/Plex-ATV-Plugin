//
//  ProxyMachineDelegate.m
//  atvTwo
//
//  Created by Frank Bauer on 14.01.11.
//

#define LOCAL_DEBUG_ENABLED 0

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
#ifdef LOCAL_DEBUG_ENABLED
		DLog(@"Hooking up machine Delegate");
#endif
		[[MachineManager sharedMachineManager] setDelegate:self];
	}
	
	if (![delegates containsObject:del] && del!=nil){
#ifdef LOCAL_DEBUG_ENABLED
		DLog(@"Added machine Delegate %@", del);
#endif
		[delegates addObject:del];
		
		NSArray* mc = [[MachineManager sharedMachineManager] threadSafeMachines];
		for (Machine* m in mc){
			[del machineWasAdded:m];
		}
	}
	
	
}

-(void)removeDelegate:(id<MachineManagerDelegate>)del{
#ifdef LOCAL_DEBUG_ENABLED
	DLog(@"Removed machine Delegate %@", del);
#endif
	[delegates removeObject:del];
}



//required
-(void)machineWasAdded:(Machine*)m;{
	for (id<MachineManagerDelegate> d in delegates){
#ifdef LOCAL_DEBUG_ENABLED
		DLog(@"Send machineWasAdded to %@", d);
#endif
		[d machineWasAdded:m];
	}
}

-(void)machineWasRemoved:(Machine*)m{
	for (id<MachineManagerDelegate> d in delegates){
#ifdef LOCAL_DEBUG_ENABLED
		DLog(@"Send machineWasRemoved to %@", d);
#endif
		[d machineWasRemoved:m];
	}
}


//optional
-(void)machineWasChanged:(Machine*)m{
	for (id<MachineManagerDelegate> d in delegates){
#ifdef LOCAL_DEBUG_ENABLED
		DLog(@"Send machineWasChanged to %@", d);
#endif
		if ([d respondsToSelector:@selector(machineWasChanged:)]) {
			[d machineWasChanged:m];
		}
	}
}

-(void)machine:(Machine*)m changedConnection:(MachineConnectionBase*)con{
	for (id<MachineManagerDelegate> d in delegates){
#ifdef LOCAL_DEBUG_ENABLED
		DLog(@"Send machine:changedConnection to %@", d);
#endif
		if ([d respondsToSelector:@selector(machine:changedConnection:)]) {
			[d machine:m changedConnection:con];
		}
	}
}

-(void)machine:(Machine*)m updatedInfo:(ConnectionInfoType)updateMask{
	for (id<MachineManagerDelegate> d in delegates){
#ifdef LOCAL_DEBUG_ENABLED
		DLog(@"Send machine:updatedInfo to %@", d);
#endif
		if ([d respondsToSelector:@selector(machine:updatedInfo:)]) {
			[d machine:m updatedInfo:updateMask];
		}
	}
}

-(void)machine:(Machine*)m changedClientTo:(ClientConnection*)cc{
	for (id<MachineManagerDelegate> d in delegates){
#ifdef LOCAL_DEBUG_ENABLED
		DLog(@"Send machine:changedClientTo to %@", d);
#endif
		if ([d respondsToSelector:@selector(machine:changedClientTo:)]) {
			[d machine:m changedClientTo:cc];
		}
	}
}

-(void)machine:(Machine*)m receivedInfoForConnection:(MachineConnectionBase*)con updated:(ConnectionInfoType)updateMask{
	for (id<MachineManagerDelegate> d in delegates){
#ifdef LOCAL_DEBUG_ENABLED
		DLog(@"Send machine:receivedInfoForConnection to %@", d);
#endif
		if ([d respondsToSelector:@selector(machine:receivedInfoForConnection:updated:)]) {
			[d machine:m receivedInfoForConnection:con updated:updateMask];
		}
	}
}



@end

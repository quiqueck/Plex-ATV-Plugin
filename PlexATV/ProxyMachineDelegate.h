//
//  ProxyMachineDelegate.h
//  atvTwo
//
//  Created by Frank Bauer on 14.01.11.
//

#import <Foundation/Foundation.h>
#import <plex-oss/MachineManager.h>

@class Machine;
@interface ProxyMachineDelegate : NSObject<MachineManagerDelegate> {
  NSMutableArray* delegates;
}

+(ProxyMachineDelegate*)shared;

-(void)registerDelegate:(id<MachineManagerDelegate>)del;
-(void)removeDelegate:(id<MachineManagerDelegate>)del;
@end

//
//  HWMediaShelfController.m
//  atvTwo
//
//  Created by ccjensen on 2011-01-29.
//

#import "HWMediaShelfController2.h"
#import "SMFGridController.h"

@implementation HWMediaShelfController2

- (id) init
{
	if((self = [super init]) != nil) {	
		SMFGridController *gridControl = [[[SMFGridController alloc] init] autorelease];
		[self addControl:gridControl];
		NSLog(@"controls in me: %@",[self controls]);
	}
	return self;
	
}


@end

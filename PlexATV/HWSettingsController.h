//
//  HWSettingsController.h
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//
//  Inspired by 
//
//		MLoader.m
//		MextLoader
//
//		Created by Thomas Cool on 10/22/10.
//		Copyright 2010 tomcool.org. All rights reserved.
//

#import "SMFPreferences.h"
#import "SMFMediaMenuController.h"

@interface HWSettingsController : SMFMediaMenuController {
	SMFPreferences *userPreference;
}
- (void)setupList;

@end

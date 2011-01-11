//
//  HWSettingsController.h
//  atvTwo
//
//  Created by camelot on 10/01/2011.
//

#import "SMFPreferences.h"
#import "SMFCenteredMenuController.h"

@interface HWSettingsController : SMFCenteredMenuController {
	SMFPreferences *userPreference;
}
- (void)setupList;

@end

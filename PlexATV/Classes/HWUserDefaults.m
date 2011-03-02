//
//  HWUserDefaults.m
//  atvTwo
//
//  Created by ccjensen on 24/01/2011.
//

#import "HWUserDefaults.h"
#import "Constants.h"


@implementation HWUserDefaults

+(SMFPreferences *)preferences {
	static SMFPreferences *_plexPreferences = nil;
    
    if(!_plexPreferences) {
		//setup user preferences
        _plexPreferences = [[SMFPreferences alloc] initWithPersistentDomainName:PreferencesDomain];		
		[_plexPreferences registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
											[NSArray array], PreferencesMachinesExcludedFromServerList,
											@"Low", PreferencesQualitySetting,
											NO, PreferencesAdvancedEnableSkipFilteringOptionsMenu,
											NO, PreferencesAdvancedEnableDebug,
											nil]];
    }
	
    return _plexPreferences;
}

@end

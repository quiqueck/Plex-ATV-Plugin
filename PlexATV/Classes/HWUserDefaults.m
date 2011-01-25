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
		NSDictionary *remoteServer = [[NSDictionary alloc] initWithObjectsAndKeys: @"", PreferencesRemoteServerHostName, @"", PreferencesRemoteServerName, nil];
		NSArray *remoteServerList = [[NSArray alloc] initWithObjects:remoteServer, nil];
		[_plexPreferences registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
											NO, PreferencesUseCombinedPmsView, 
											@"<No Default Selected>", PreferencesDefaultServerName,
											@"", PreferencesDefaultServerUid,
											@"Low", PreferencesQualitySetting,
											remoteServerList, PreferencesRemoteServerList,
											nil]];
		[remoteServer release];
		[remoteServerList release];
    }
	
    return _plexPreferences;
}

@end

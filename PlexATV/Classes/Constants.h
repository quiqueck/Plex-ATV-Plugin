
#define PreferencesDomain @"com.plex.client-plugin"

#define PreferencesUseCombinedPmsView @"PreferencesUseCombinedPmsView"
#define PreferencesDefaultServerName @"PreferencesDefaultServerName"
#define PreferencesDefaultServerUid @"PreferencesDefaultServerUid"

#define PreferencesRemoteServerList @"PreferencesRemoteServerList"
#define PreferencesRemoteServerHostName @"PreferencesRemoteServerHostName"
#define PreferencesRemoteServerName @"PreferencesRemoteServerName"
#define PreferencesRemoteServerUserName @"PreferencesRemoteServerUserName"
#define PreferencesRemoteServerPassword @"PreferencesRemoteServerPassword"

#define PreferencesQualitySetting @"PreferencesQualitySetting"
#define PreferencesRemoteServerName @"PreferencesRemoteServerName"

typedef enum {
	kBRMediaPlayerStateStopped = 0,
	kBRMediaPlayerStatePaused = 1,
	kBRMediaPlayerStatePlaying = 3,
	kBRMediaPlayerStateForwardSeeking = 4,  
	kBRMediaPlayerStateForwardSeekingFast = 5,
	kBRMediaPlayerStateForwardSeekingFastest = 6,
	kBRMediaPlayerStateBackSeeking = 7,  
	kBRMediaPlayerStateBackSeekingFast = 8,
	kBRMediaPlayerStateBackSeekingFastest = 9,
} BRMediaPlayerState;

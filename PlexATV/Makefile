GO_EASY_ON_ME=1
export SDKVERSION=4.2
FW_DEVICE_IP=apple-tv.local
include theos/makefiles/common.mk

BUNDLE_NAME = plex

PlexATV_FILES = Classes/PlexPreviewAsset.m Classes/PlexSongAsset.m Classes/PlexMediaAsset.m Classes/PlexMediaAssetOld.m

PlexATV_FILES += Classes/HWSettingsController.m Classes/HWDefaultServerController.m Classes/HWAdvancedSettingsController.m
PlexATV_FILES += Classes/HWServersController.m Classes/HWServerDetailsController.m

PlexATV_FILES += Classes/SongListController.m Classes/HWPlexDir.m Classes/HWAppliance.mm Classes/HWBasicMenu.m
PlexATV_FILES += Classes/HWMediaGridController.m Classes/HWDetailedMovieMetadataController.m Classes/PlexPlaybackController.m
PlexATV_FILES += Classes/HWTVShowsController.m

PlexATV_FILES += Classes/NSArray-Shuffle.m Classes/PlexMediaProvider.m Classes/HWUserDefaults.m Classes/ProxyMachineDelegate.m 

PlexATV_INSTALL_PATH = /Applications/AppleTV.app/Appliances
PlexATV_BUNDLE_EXTENSION = frappliance
PlexATV_LDFLAGS = -undefined dynamic_lookup
PlexATV_CFLAGS = -I../_contrib/ATV2Includes
PlexATV_OBJ_FILES = ../_contrib/SMFramework/obj/SMFramework
include $(FW_MAKEDIR)/bundle.mk

after-install::
	echo $(FW_PROJECT_DIR)
	install.exec "killall -9 Lowtide"
	install.exec "killall -9 AppleTV"
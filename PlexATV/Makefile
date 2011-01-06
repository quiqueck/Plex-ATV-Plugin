GO_EASY_ON_ME=1
export SDKVERSION=4.2
FW_DEVICE_IP=apple-tv.local
include theos/makefiles/common.mk

BUNDLE_NAME = PlexATV
PlexATV_FILES = Classes/HWAppliance.mm Classes/HWBasicMenu.m Classes/HWPlexDir.m Classes/PlexMediaAsset.m Classes/PlexMediaProvider.m
PlexATV_INSTALL_PATH = /Applications/AppleTV.app/Appliances
PlexATV_BUNDLE_EXTENSION = frappliance
PlexATV_LDFLAGS = -undefined dynamic_lookup #-L$(FW_PROJECT_DIR) -lBackRow

include $(FW_MAKEDIR)/bundle.mk

after-install::
	echo $(FW_PROJECT_DIR)
<<<<<<< HEAD
=======
	install.exec "killall -9 Lowtide"
>>>>>>> ad2b7ccc4550abc774c56ecdd96218f2f9146e3a
	install.exec "killall -9 AppleTV"
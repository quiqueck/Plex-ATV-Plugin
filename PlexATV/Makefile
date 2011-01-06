GO_EASY_ON_ME=1
export SDKVERSION=4.2
FW_DEVICE_IP=apple-tv.local
include theos/makefiles/common.mk

BUNDLE_NAME = HW
HW_FILES = Classes/HWAppliance.mm Classes/HWBasicMenu.m
HW_INSTALL_PATH = /Applications/Lowtide.app/Appliances
HW_BUNDLE_EXTENSION = frappliance
HW_LDFLAGS = -undefined dynamic_lookup #-L$(FW_PROJECT_DIR) -lBackRow

include $(FW_MAKEDIR)/bundle.mk

after-install::
	echo $(FW_PROJECT_DIR)
	install.exec "killall -9 Lowtide"
	install.exec "killall -9 AppleTV"
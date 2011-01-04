#!/bin/sh
export APP_NAME="AppleTV.app"
export TARGET_DIR=/Applications/${APP_NAME}/Appliances/PLEX.frappliance

#copy local (in order to build the .deb
cp "${CODESIGNING_FOLDER_PATH}/plex" "${BUILD_DIR}/../_deb/PLEX.frapplication/Applications/${APP_NAME}/Appliances/PLEX.frappliance/"


#copy to the ATV
scp "${CODESIGNING_FOLDER_PATH}/plex" root@apple-tv.local:${TARGET_DIR}
scp "${BUILD_DIR}/../_deb/PLEX.frapplication/Applications/${APP_NAME}/Appliances/PLEX.frappliance/Info.plist" root@apple-tv.local:${TARGET_DIR}

#restart UI
ssh root@apple-tv.local 'killall AppleTV'
#ssh root@apple-tv.local 'killall Lowtide'


#!/bin/sh

#  VSSymlinkThemesScript.sh
#  DB5Demo
#
#  Created by Dimitri Stancioff on 6/29/13.

if [ "$EFFECTIVE_PLATFORM_NAME" = "-iphonesimulator" ]; then
	rm $BUILT_PRODUCTS_DIR/$EXECUTABLE_FOLDER_PATH/$2
	ln -s $1 $BUILT_PRODUCTS_DIR/$EXECUTABLE_FOLDER_PATH/$2
fi

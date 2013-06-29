#!/bin/sh

#  VSSymlinkThemesScript.sh
#  DB5Demo
#
#  Created by Dimitri Stancioff on 6/29/13.

rm $BUILT_PRODUCTS_DIR/$EXECUTABLE_FOLDER_PATH/DB5.plist
ln -s $SRCROOT/DB5Demo/DB5.plist $BUILT_PRODUCTS_DIR/$EXECUTABLE_FOLDER_PATH/DB5.plist

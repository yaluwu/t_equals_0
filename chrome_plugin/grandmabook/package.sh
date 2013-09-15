#!/bin/bash
set -e
ORIGINAL_DIR=$(pwd)
TEMP_DIR=$(mktemp -d -t grandmabook)
MAIN=$(cd $(dirname "$0"); pwd)

cp -r $MAIN $TEMP_DIR

NEW_DIR=$TEMP_DIR/grandmabook

cd $NEW_DIR
./build.sh

rm -rf $NEW_DIR/{vendor,app,node_modules,package.json,generators}
rm -rf $NEW_DIR/*.sh
rm -rf $NEW_DIR/*.zip
find $NEW_DIR -name '*~' -delete
rm -f $NEW_DIR/{.npmignore,.gitignore}

cd $TEMP_DIR

zip -r grandmabook.zip -r grandmabook

cp grandmabook.zip $ORIGINAL_DIR/grandmabook-$(date '+%s').zip
rm -rf $TEMP_DIR

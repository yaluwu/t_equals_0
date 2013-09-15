#!/bin/bash
set -e

./node_modules/coffee-script/bin/coffee  -c app/application.coffee

cat vendor/* app/*.js > grandmabook.js

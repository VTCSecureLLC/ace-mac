#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..

short_sha1=$(git rev-parse --short HEAD)
major_minor_patch=$(bundle exec semver format '%M.%m.%p')
special_build=$(bundle exec semver format '%M.%m.%p')

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $major_minor_patch" ./VATRP/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${TRAVIS_BUILD_NUMBER:-1}" ./VATRP/Info.plist


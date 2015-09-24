#!/bin/bash

short_sha1=$(git rev-parse --short HEAD)
major_minor_patch=$(bundle exec semver format '%M.%m.%p')
special_build=$(bundle exec semver format '%M.%m.%p')

defaults write ./VATRP/Info.plist CFBundleShortVersionString "$major_minor_patch"
defaults write ./VATRP/Info.plist CFBundleVersion "${TRAVIS_BUILD_NUMBER:-1}"

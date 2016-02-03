#!/bin/bash

short_sha1=$(git rev-parse --short HEAD)
major_minor_patch=$(bundle exec semver format '%M.%m.%p')
special_build=$(bundle exec semver format '%M.%m.%p')

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $major_minor_patch" ./VATRP/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${TRAVIS_BUILD_NUMBER:-1}" ./VATRP/Info.plist

linphone_mac_version="$(bundle exec semver format '%M.%m.%p')-${TRAVIS_BUILD_NUMBER:-1}-${short_sha1}"

printf "/* LinphoneMACVersion.h
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */
#define LINPHONE_MAC_VERSION \"$linphone_mac_version\"
" > $(dirname $0)/../Classes/LinphoneMACVersion.h

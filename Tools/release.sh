#!/bin/bash

# Globals
HOCKEYAPP_TEAM_IDS=${HOCKEYAPP_TEAM_IDS:-47813}
HOCKEYAPP_APP_ID=${HOCKEYAPP_APP_ID:-b7b28171bab92ce345aac7d54f435020}

# Only deploy master branch builds

if [ -z "$TRAVIS_BRANCH" ] ; then
  echo "TRAVIS_BRANCH not found. Deploy skipped"
  exit 0
fi

if [ "$TRAVIS_BRANCH" != "master" ] ; then
  echo "TRAVIS_BRANCH is not master. Deploy skipped"
  exit 0
fi

# Prepare codesigning keys

if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
  echo "Missing AWS_ACCESS_KEY_ID"
  unset BUCKET
fi
if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo "Missing AWS_SECRET_ACCESS_KEY"
  unset BUCKET
fi
if [ -n "${BUCKET}" ]; then
  which aws || brew install awscli
  aws s3 sync --quiet s3://${BUCKET}/apple/ sync/
  cd sync
  pwd
  chmod 755 apply.sh
  . ./apply.sh mac
  cd ..
fi
if [ -z "${CODE_SIGN_APPLICATION}" ]; then
  echo "Missing CODE_SIGN_APPLICATION"
fi
if [ -z "${PROVISIONING_PROFILE}" ]; then
  echo "Missing PROVISIONING_PROFILE"
fi

set -e

for file in *.dmg *.zip; do
  if [ -f "$file" ]; then
    rm -f "$file"
  fi
done

# Generate an archive for this project

XCARCHIVE=/tmp/ace-mac.xcarchive

if [ -e "${XCARCHIVE}" ]; then
  rm -fr "${XCARCHIVE}"
fi

xctool -project ACE.xcodeproj \
       -scheme VATRP \
       -sdk macosx \
       -configuration Debug \
       -derivedDataPath build/derived \
       archive \
       -archivePath $XCARCHIVE \
       CODE_SIGN_IDENTITY="$CODE_SIGN_APPLICATION"
       #PROVISIONING_PROFILE="$PROVISIONING_PROFILE"

# Prepare semantic versioning tag

SHA1=$(git rev-parse --short HEAD)

echo "$(bundle exec semver)-${TRAVIS_BUILD_NUMBER:-1}"-${SHA1} > LastCommit.txt
git log -1 --pretty=format:%B >> LastCommit.txt

tag="$(bundle exec semver)-${TRAVIS_BUILD_NUMBER:-1}"-${SHA1}

# Prepare other variables

IFS=/ GITHUB_REPO=($TRAVIS_REPO_SLUG); IFS=""

PKG_FILE=/tmp/ACE

if [ -e "${PKG_FILE}".app ]; then
  rm -fr "${PKG_FILE}".app
fi

# Generate an installer pkg from the archive

if [ -d "$XCARCHIVE" ]; then
  xcodebuild -exportArchive \
             -exportFormat app \
             -configuration Debug \
             -archivePath $XCARCHIVE \
             -exportPath $PKG_FILE \
             -exportProvisioningProfile "$PROVISIONING_PROFILE"
fi

if [ -d "$XCARCHIVE" ]; then
  # Create an application zip file from the archive build

  APP_DIR="${PKG_FILE}".app
  APP_ZIP_FILE=/tmp/ACE.app.zip
  if [ -f $APP_ZIP_FILE ]; then
    rm -f $APP_ZIP_FILE
  fi
  (cd $(dirname $APP_DIR) ; zip -r $APP_ZIP_FILE $(basename $APP_DIR))

  # Create a dSYM zip file from the archive build

  DSYM_DIR=$(find build/derived -name '*.dSYM' | head -1)
  DSYM_ZIP_FILE=${PKG_FILE}.dsym.zip
  echo 'dsym dir "$DSYM_DIR" \'
  echo 'dsym zip "$DSYM_DIR" \'

if [ -f $DSYM_ZIP_FILE ]; then
    rm -f $DSYM_ZIP_FILE
  fi
  (cd $(dirname $DSYM_DIR) ; zip -r $DSYM_ZIP_FILE $(basename $DSYM_DIR) )
fi

# Release via HockeyApp if credentials are available

if [ -z "$HOCKEYAPP_TOKEN" ]; then
  echo HOCKEYAPP_TOKEN is not defined. Neither creating installer pkg, nor deploying it to HockeyApp.
else

  if [ -d "$XCARCHIVE" ]; then

    # Distribute via HockeyApp

    echo "Uploading to HockeyApp"
    echo 'curl \'
    echo ' -F "status=2" \'
    echo ' -F "notify=1" \'
    echo ' -F "commit_sha='"${SHA1}"'" \'
    echo ' -F "build_server_url=https://travis-ci.org/'"${TRAVIS_REPO_SLUG}"'/builds/'"${TRAVIS_BUILD_ID}"'" \'
    echo ' -F "repository_url=http://github.com/'"${TRAVIS_REPO_SLUG}"'" \'
    echo ' -F "release_type=2" \'
    echo ' -F "notes='"$(git log -1 --pretty=format:%B)"'" \'
    echo ' -F "notes_type=1" \'
    echo ' -F "mandatory=0" \'
    echo ' -F "ipa=@'"$APP_ZIP_FILE"'" \'
    echo ' -F "dsym=@'"$DSYM_ZIP_FILE"'" \'
    echo ' -H "X-HockeyAppToken: REDACTED" \'
    echo ' https://rink.hockeyapp.net/api/2/apps/'"${HOCKEYAPP_APP_ID}"'/app_versions/upload'

    curl \
      -F "status=2" \
      -F "notify=1" \
      -F "commit_sha=${SHA1}" \
      -F "build_server_url=https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}" \
      -F "repository_url=http://github.com/${TRAVIS_REPO_SLUG}" \
      -F "release_type=2" \
      -F "notes=$(git log -1 --pretty=format:%B)" \
      -F "notes_type=1" \
      -F "mandatory=0" \
      -F "ipa=@$APP_ZIP_FILE" \
      -F "dsym=@$DSYM_ZIP_FILE" \
      -H "X-HockeyAppToken: ${HOCKEYAPP_TOKEN}" \
      https://rink.hockeyapp.net/api/2/apps/${HOCKEYAPP_APP_ID}/app_versions/upload || true

    #if [ -x /usr/local/bin/puck ]; then
    #
    #  /usr/local/bin/puck \
    #    -dsym_path=$DSYM_ZIP_FILE \
    #    -submit=auto \
    #    -download=true \
    #    -notes="$(git log -1 --pretty=format:%B)" \
    #    -commit_sha=${SHA1} \
    #    -build_server_url="https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}" \
    #    -repository_url="http://github.com/${TRAVIS_REPO_SLUG}" \
    #    -source_path=$PWD \
    #    -api_token=$HOCKEYAPP_TOKEN \
    #    -app_id=${HOCKEYAPP_APP_ID} \
    #    -notify=true \
    #    -upload=all \
    #    -release_type=alpha \
    #    $XCARCHIVE
    #fi

    #bundle exec ipa distribute:hockeyapp \
    #           --token $HOCKEYAPP_TOKEN \
    #           --file $PKG_FILE \
    #           --dsym $DSYM_ZIP_FILE \
    #           --notes LastCommit.txt \
    #           --notify \
    #           --repository-url "https://github.com/${TRAVIS_REPO_SLUG}"
  fi
fi

# Create a GitHub release if credentials are available

if [ -z "$GITHUB_TOKEN" ]; then
  echo GITHUB_TOKEN is not defined. Neither creating dmg packages, nor creating a GitHub release.
else
  curl -sL https://github.com/aktau/github-release/releases/download/v0.6.2/darwin-amd64-github-release.tar.bz2 | bunzip2 -cd | tar xf - --strip=3 -C /tmp/

  chmod 755 /tmp/github-release

  /tmp/github-release release \
      --user ${GITHUB_REPO[0]:-VTCSecureLLC} \
      --repo ${GITHUB_REPO[1]:-ace-mac} \
      --tag $tag \
      --name "Travis-CI Automated $tag" \
      --description "$(git log -1 --pretty=format:%B)" \
      --pre-release

  find . -name '*.app' -print | grep -v build/derived | while read app; do
    mkdir -p ACE/
    cp -a "$app" ACE/
    #[ -d "$app".dSYM ] && cp -a "$app".dSYM ACE/
    config=$(basename $(dirname "$app"))
    dmg=$(basename "$app" | sed -e 's/.app$//')
    hdiutil create $dmg-$config-$tag.dmg -srcfolder ACE/ -ov
    rm -fr ACE/
  done

  find . -name '*.dmg' -print | while read dmg; do
    echo "Uploading $dmg github release $tag : $(ls -la $dmg)"
    /tmp/github-release upload \
        --user ${GITHUB_REPO[0]:-VTCSecureLLC} \
        --repo ${GITHUB_REPO[1]:-ace-mac} \
        --tag $tag \
        --name $(basename "$dmg") \
        --file "$dmg"
  done

  if [ -f $PKG_FILE ]; then
    echo "Uploading $PKG_FILE github release $tag : $(ls -la $PKG_FILE)"
    /tmp/github-release upload \
        --user ${GITHUB_REPO[0]:-VTCSecureLLC} \
        --repo ${GITHUB_REPO[1]:-ace-mac} \
        --tag $tag \
        --name $(basename "$PKG_FILE") \
        --file "$PKG_FILE"
  fi

  if [ -f $APP_ZIP_FILE ]; then
    TARGET=ACE-HockeyApp-$tag.zip
    echo "Uploading $APP_ZIP_FILE as $TARGET to github release $tag : $(ls -la $APP_ZIP_FILE)"
    /tmp/github-release upload \
        --user ${GITHUB_REPO[0]:-VTCSecureLLC} \
        --repo ${GITHUB_REPO[1]:-ace-mac} \
        --tag $tag \
        --name $TARGET \
        --file "$APP_ZIP_FILE"
  fi

  if [ -f $DSYM_ZIP_FILE ]; then
    TARGET=ACE-HockeyApp-$tag.dsym.zip
    echo "Uploading $DSYM_ZIP_FILE as $TARGET to github release $tag : $(ls -la $DSYM_ZIP_FILE)"
    /tmp/github-release upload \
        --user ${GITHUB_REPO[0]:-VTCSecureLLC} \
        --repo ${GITHUB_REPO[1]:-ace-mac} \
        --tag $tag \
        --name $TARGET \
        --file "$DSYM_ZIP_FILE"
  fi
fi

if [ -f "sync/cleanup.sh" ]; then
  . ./sync/cleanup.sh
fi


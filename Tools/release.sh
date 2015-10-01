#!/bin/bash

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

if [ -n "${BUCKET}" ]; then
  brew install awscli
  aws s3 sync --quiet s3://${BUCKET}/apple/ sync/
  cd sync
  pwd
  chmod 755 apply.sh
  . ./apply.sh mac
  cd ..
fi

set -e

for file in *.dmg; do
  rm -f "$file"
done

# Generate an archive for this project

XCARCHIVE_FILE=/tmp/ace-mac.xcarchive

if [ -e "${XCARCHIVE_FILE}" ]; then
  rm -fr "${XCARCHIVE_FILE}"
fi

xctool -project ACE.xcodeproj \
       -scheme VATRP \
       -sdk macosx \
       -configuration Debug \
       -derivedDataPath build/derived \
       archive \
       -archivePath $XCARCHIVE_FILE \
       CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
       PROVISIONING_PROFILE="$PROVISIONING_PROFILE"

# Prepare semantic versioning tag

SHA1=$(git rev-parse --short HEAD)

echo "$(bundle exec semver)-${TRAVIS_BUILD_NUMBER:-1}"-${SHA1} > LastCommit.txt
git log -1 --pretty=format:%B >> LastCommit.txt

tag="$(bundle exec semver)-${TRAVIS_BUILD_NUMBER:-1}"-${SHA1}

# Prepare other variables

IFS=/ GITHUB_REPO=($TRAVIS_REPO_SLUG); IFS=""

PKG_FILE=/tmp/ace-mac.pkg

if [ -e "${PKG_FILE}" ]; then
  rm -fr "${PKG_FILE}"
fi

# Release via HockeyApp if credentials are available

if [ -z "$HOCKEYAPP_TOKEN" ]; then
  echo HOCKEYAPP_TOKEN is not defined. Neither creating installer pkg, nor deploying it to HockeyApp.
else

  # Generate an installer pkg from the archive

  xcodebuild -exportArchive \
             -exportFormat app \
             -configuration Debug \
             -archivePath $XCARCHIVE_FILE \
             -exportPath $PKG_FILE \
             -exportProvisioningProfile 'com.vtcsecure.ace.mac development' || true

  ls -la "$XCARCHIVE_FILE" || true
  ls -la "$PKG_FILE".app || true

  if [ -d "$XCARCHIVE_FILE" ]; then
    # Create a dSYM zip file from the archive build

    DSYM_DIR=$(find build/derived -name '*.dSYM' | head -1)
    DSYM_ZIP_FILE=${PKG_FILE}.dsym.zip
    (cd $(dirname $DSYM_DIR) ; zip -r $DSYM_ZIP_FILE $(basename $DSYM_DIR) )

    # Distribute via HockeyApp

    if [ -x /usr/local/bin/puck ]; then

      /usr/local/bin/puck \
        -dsym_path=$DSYM_ZIP_FILE \
        -submit=auto \
        -download=true \
        -notes="$(git log -1 --pretty=format:%B)" \
        -commit_sha=${SHA1} \
        -build_server_url="https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}" \
        -repository_url="http://github.com/${TRAVIS_REPO_SLUG}" \
        -source_path=$PWD \
        -api_token=$HOCKEYAPP_TOKEN \
        -app_id=b7b28171bab92ce345aac7d54f435020 \
        -notify=true \
        -upload=all \
        -release_type=alpha \
        $XCARCHIVE_FILE
    fi

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
    mkdir -p diskimage/
    cp -a "$app" diskimage/
    [ -d "$app".dSYM ] && cp -a "$app".dSYM diskimage/
    config=$(basename $(dirname "$app"))
    dmg=$(basename "$app" | sed -e 's/.app$//')
    hdiutil create $dmg-$config-$tag.dmg -srcfolder diskimage/ -ov
    rm -fr diskimage/
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
fi

if [ -f "sync/cleanup.sh" ]; then
  . ./sync/cleanup.sh
fi

#!/bin/bash

if [ -z "$TRAVIS_BRANCH" ] ; then
  echo "TRAVIS_BRANCH not found. Deploy skipped"
  exit 0
fi

if [ "$TRAVIS_BRANCH" != "master" ] ; then
  echo "TRAVIS_BRANCH is not master. Deploy skipped"
  exit 0
fi

set -x

curl -sL https://github.com/aktau/github-release/releases/download/v0.6.2/darwin-amd64-github-release.tar.bz2 | bunzip2 -cd | tar xf - --strip=3 -C /tmp/

chmod 755 /tmp/github-release

tag="$(bundle exec semver)-${TRAVIS_BUILD_NUMBER:-1}"-$(git rev-parse --short HEAD)

/tmp/github-release release \
    --user VTCSecureLLC \
    --repo ace-mac \
    --tag $tag \
    --name "Travis-CI Automated $tag" \
    --description "$(git log -1 --pretty=format:%B)" \
    --pre-release

find . -name '*.app' -print | while read app; do
  set -x
  mkdir -p diskimage/
  cp -a "$app" diskimage/
  [ -d "$app".dSYM ] && cp -a "$app".dSYM diskimage/
  config=$(basename $(dirname "$app"))
  dmg=$(basename "$app" | sed -e 's/.app$//')
  hdiutil create $dmg-$config-$tag.dmg -srcfolder diskimage/ -ov
  rm -fr diskimage/
  set +x
done

find . -name '*.dmg' -print | while read app; do
  echo "Uploading $dmg github release $tag : $(ls -la $dmg)"
  /tmp/github-release upload \
      --user VTCSecureLLC \
      --repo ace-mac \
      --tag $tag \
      --name $(basename "$dmg") \
      --file "$dmg"
done


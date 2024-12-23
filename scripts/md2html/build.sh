#!/bin/bash

# Author: @ralfhandl (inspired by the work of @MikeRalphson)

# run this script from the root of the repo. It is designed to be run by a GitHub workflow.
# It contains bashisms

mkdir -p deploy/overlay
mkdir -p deploy/js

cd scripts/md2html
mkdir -p history
cp ../../EDITORS.md history/EDITORS_v1.0.0.md

# temporarily copy installed version of respec into build directory
cp -p ../../node_modules/respec/builds/respec-w3c.* ../../deploy/js/

# latest=`git describe --abbrev=0 --tags` -- introduce after release tags created
latest=1.0.0
latestCopied=none
lastMinor="-"
for filename in $(ls -1 ../../versions/[123456789].*.md | sort -r) ; do
  version=$(basename "$filename" .md)
  minorVersion=${version:0:3}
  tempfile=../../deploy/overlay/v$version-tmp.html
  echo -e "\n=== v$version ==="

  node md2html.js --maintainers ./history/EDITORS_v$version.md ${filename} > $tempfile
  npx respec --use-local --src $tempfile --out ../../deploy/overlay/v$version.html
  rm $tempfile

  if [ $version = $latest ]; then
    if [[ ${version} != *"rc"* ]];then
      # version is not a Release Candidate
      ( cd ../../deploy/overlay && ln -sf v$version.html latest.html )
      latestCopied=v$version
    fi
  fi

  if [ ${minorVersion} != ${lastMinor} ]; then
    ( cd ../../deploy/overlay && ln -sf v$version.html v$minorVersion.html )
    lastMinor=$minorVersion
  fi
done
echo Latest tag is $latest, copied $latestCopied to latest.html

# clean up build directory
rm ../../deploy/js/respec-w3c.*

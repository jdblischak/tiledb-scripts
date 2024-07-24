#!/bin/bash
set -eux

# Purpose: Update tiledb-feedstock-for-cloud with latest TileDB release
#
# Usage: bash scripts/tiledb-feedstock-for-cloud.sh X.X.X

VER="$1"
echo Version: $VER

cd ~/repos/TileDB
git fetch upstream --tags
# Can't use `git log --format=%h` because TileDB has so many commits, that it returns
# a 9 character abbreviation
COMMIT=$(git rev-parse --short=7 $VER)
echo Commit: $COMMIT

SHA=$(curl --fail -sL https://github.com/TileDB-Inc/TileDB/releases/download/$VER/tiledb-linux-x86_64-$VER-$COMMIT.tar.gz.sha256 | cut -f1 -d ' ')
echo SHA: $SHA

cd ~/repos/tiledb-feedstock-for-cloud
git checkout main
git pull upstream main
git push origin main
git checkout -b $VER

sed 1,6d recipe/meta.yaml > recipe/meta.yaml.tmp
cat <<EOL > recipe/meta.yaml.header
{% set name = "TileDB" %}
{% set version = "$VER" %}
# pkg_version should only be different when downloading a patched release tarball
{% set pkg_version = "$VER" %}
{% set commit = "$COMMIT" %}
{% set sha256 = "$SHA" %}
EOL
cat recipe/meta.yaml.header recipe/meta.yaml.tmp > recipe/meta.yaml
rm recipe/meta.yaml.header recipe/meta.yaml.tmp
sed -i -E "s/number: [0-9]+/number: 0/g" recipe/meta.yaml
git add recipe/meta.yaml
git commit -m "Bump to $VER"
conda smithy rerender --commit=auto
git push origin $VER

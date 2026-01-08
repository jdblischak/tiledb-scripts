#!/bin/bash
set -eux

# Purpose: Update the TileDB release binary downloaded when running the
#   centralized nightlies build in a branch (for quicker feedback when
#   troubleshooting)
#
# Usage: bash scripts/bump-centralized-tiledb-nightlies.sh X.X.X

VER="$1"
echo Version: $VER

cd ~/repos/TileDB
git fetch upstream --tags
# Can't use `git log --format=%h` because TileDB has so many commits, that it returns
# a 9 character abbreviation
COMMIT=$(git rev-parse --short=7 $VER)
echo Commit: $COMMIT

RELEASE="https://github.com/TileDB-Inc/TileDB/releases/tag/$VER"
echo Release: $RELEASE
TARBALL="https://github.com/TileDB-Inc/TileDB/releases/download/$VER/tiledb-linux-x86_64-$VER-$COMMIT.tar.gz"
echo Tarball: $TARBALL

cd ~/repos/centralized-tiledb-nightlies
git checkout main
git pull upstream main
git push origin main
git checkout -b $VER

sed -i \
  s/https:\\/\\/github.com\\/TileDB-Inc\\/TileDB\\/releases\\/download\\/.*\\/tiledb-linux-x86_64-.*.tar.gz/https:\\/\\/github.com\\/TileDB-Inc\\/TileDB\\/releases\\/download\\/$VER\\/tiledb-linux-x86_64-$VER-$COMMIT.tar.gz/g \
  .github/workflows/linux.yml

git diff
git add .github/workflows/linux.yml
git commit -m "Use $VER in branches" -m "$RELEASE"
git push upstream $VER

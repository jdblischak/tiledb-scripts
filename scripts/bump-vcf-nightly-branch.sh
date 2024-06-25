#!/bin/bash
set -eux

# Purpose: Update the TileDB release branch of the TileDB-VCF nightly build
#
# Usage: bash scripts/bump-vcf-nightly-branch.sh X.X

VER="$1"
echo Version: $VER
TILEDB="release-$VER"
echo TileDB release branch: $TILEDB

# Get latest TileDB-Py tag
cd ~/repos/TileDB-Py/
git fetch upstream
PY=$(git tag --sort=-committerdate | head -n 1)
echo TileDB-Py tag: $PY

# Update nightly build CI file
cd ~/repos/TileDB-VCF/
git checkout main
git pull upstream main
git push origin main
git checkout -b nightly-$TILEDB
sed -i .github/workflows/nightly.yml \
  -e "s/libtiledb: release-[0-9\.]\+/libtiledb: $TILEDB/" \
  -e "s/tiledb-py: [0-9\.]\+/tiledb-py: $PY/"
git diff
git commit -a -m "Bump nightly build release branch to $VER"
git push origin nightly-$TILEDB

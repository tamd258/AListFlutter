#!/bin/bash
set -e

GIT_REPO="https://github.com/tamd258/alistx.git"
TAG_NAME=$(git -c 'versionsort.suffix=-' ls-remote --refs --sort='version:refname' --tags $GIT_REPO | tail --lines=1 | cut --delimiter='/' --fields=3 || true)

echo "AList - ${TAG_NAME}"
rm -rf ./src
unset GIT_WORK_TREE
git clone https://github.com/tamd258/alistx.git ./src
rm -rf ./src/.git

mv -f ./src/* ../
rm -rf ./src

PATCH_ROOT="$(cd "$(dirname "$0")/.." && pwd)/patches/guangyapan"
TARGET_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ -d "$PATCH_ROOT" ]; then
  echo "Applying GuangYaPan overlay from $PATCH_ROOT"
  mkdir -p "$TARGET_ROOT/drivers/guangyapan"
  cp -f "$PATCH_ROOT"/*.go "$TARGET_ROOT/drivers/guangyapan/"

  if ! grep -q 'drivers/guangyapan' "$TARGET_ROOT/drivers/all.go"; then
    awk '1;/drivers\/google_photo/{print "\t_ \"github.com/alist-org/alist/v3/drivers/guangyapan\""}' "$TARGET_ROOT/drivers/all.go" > "$TARGET_ROOT/drivers/all.go.tmp"
    mv "$TARGET_ROOT/drivers/all.go.tmp" "$TARGET_ROOT/drivers/all.go"
  fi
fi
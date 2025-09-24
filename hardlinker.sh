#!/bin/sh
set -e

MYDIR="$(pwd)"

if [ -z "$1" ]; then
  printf "Link computer id: "
  read LINKTO
else
  LINKTO="$1"
fi

TARGET_DIR="$MYDIR/../computer/$LINKTO"
mkdir -p "$TARGET_DIR"

cd "$MYDIR"

find . -type d -name ".git" -prune -o -type d -exec mkdir -p "$TARGET_DIR"/{} \;
find . -type f -path './.git/*' -prune -o -type f -exec ln -f {} "$TARGET_DIR"/{} \;

cd "$MYDIR"

if [ -x "$MYDIR/linker.sh" ]; then
  "$MYDIR/linker.sh"
fi

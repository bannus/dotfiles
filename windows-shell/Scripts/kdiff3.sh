#!/bin/sh
if [ -f "/c/Users/bavander/AppData/Local/Programs/KDiff3/bin/kdiff3.exe" ]; then
    exec "/c/Users/bavander/AppData/Local/Programs/KDiff3/bin/kdiff3.exe" "$@"
else
    exec "/c/Users/bavander/AppData/Local/KDiff3/bin/kdiff3.exe" "$@"
fi

#!/bin/bash

git fetch --all

# backup https://stackoverflow.com/questions/1125968/how-do-i-force-git-pull-to-overwrite-local-files
#git branch backup-master

git reset --hard origin/main

git pull
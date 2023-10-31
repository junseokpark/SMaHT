#!/bin/bash

git fetch

git rebase origin/main
git rebase origin/HEAD

#git merge origin/main

git push

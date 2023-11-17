#!/bin/bash

git fetch

git rebase origin/main
git rebase origin/HEAD

#git merge origin/main

git push

git pull origin <your-branch-name>

git add .
git commit -m "Your commit message"
git push origin <your-branch-name>
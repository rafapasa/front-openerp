#!/bin/bash
set -e
if grep -R -n '<<<<<<<' --include='*.go' --include='Makefile' --include='makefile' --include='*.dart' . ; then
  echo 'ainda tem conflito'
  exit 1
fi
git add -A
git commit -m 'merge ciclo into dev'
git stash drop || true
rm -f .git-juntar.sh
git push origin dev
git status -sb
git log -1 --oneline

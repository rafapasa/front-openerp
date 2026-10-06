#!/bin/bash
set -e
git add -A
git commit -m 'chore: remove alvo temporario de merge'
git push origin dev
git status -sb

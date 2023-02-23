#!/bin/zsh

pushd "${1}" || exit

# Go back to default branch and be up to date, switch to new branch
git stash
DEFAULT_BRANCH=$(git remote show origin | awk '/HEAD branch/ {print $NF}')
git switch "$DEFAULT_BRANCH"
git pull
git reset --hard "origin/$DEFAULT_BRANCH"
git switch -c mica-has-a-new-name

PR_NEEDED=false

# Replace my name in CODEOWNERS files
if test -f "CODEOWNERS"; then
  cat CODEOWNERS | sed -e "s/bemica //g" > /tmp/CODEOWNERS
  cp /tmp/CODEOWNERS CODEOWNERS
  rm /tmp/CODEOWNERS
  if git status | grep -q "Changes not staged for commit"; then
      git add CODEOWNERS
      PR_NEEDED=true
    fi
fi

if test -f ".github/CODEOWNERS"; then
  cat .github/CODEOWNERS | sed -e "s/bemica //g" > /tmp/CODEOWNERS
  cp /tmp/CODEOWNERS .github/CODEOWNERS
  rm /tmp/CODEOWNERS
  if git status | grep -q "Changes not staged for commit"; then
    git add .github/CODEOWNERS
    PR_NEEDED=true
  fi
fi

# Commit and open PR
if $PR_NEEDED; then
  git commit -m "Offboard @bemica"
  git push --set-upstream origin "offboard-mica"
  gh pr create --title "Offboard @bemica" --body "Remove Mica from CODEOWNERS" \
    --base "$DEFAULT_BRANCH" --head "offboard-mica"
fi

git switch "$DEFAULT_BRANCH"
git branch -D "mica-has-a-new-name"

popd || exit

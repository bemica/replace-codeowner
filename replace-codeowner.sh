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
  cat CODEOWNERS | sed -e "s/nathan-beneke/bemica/g" > /tmp/CODEOWNERS
  cp /tmp/CODEOWNERS CODEOWNERS
  rm /tmp/CODEOWNERS
  if grep -q "@bemica" "CODEOWNERS"; then
      git add CODEOWNERS
      PR_NEEDED=true
    fi
fi

if test -f ".github/CODEOWNERS"; then
  cat .github/CODEOWNERS | sed -e "s/nathan-beneke/bemica/g" > /tmp/CODEOWNERS
  cp /tmp/CODEOWNERS .github/CODEOWNERS
  rm /tmp/CODEOWNERS
  if grep -q "@bemica" ".github/CODEOWNERS"; then
    git add .github/CODEOWNERS
    PR_NEEDED=true
  fi
fi

# Commit and open PR
if $PR_NEEDED; then
  git commit -m "Replace Mica's old github handle in codeowners file"
  git push --set-upstream origin "mica-has-a-new-name"
  gh pr create --title "Mica has a new github handle" --body "replace old github handle in CODEOWNERS with new one" \
    --base "$DEFAULT_BRANCH" --head "mica-has-a-new-name"
fi

git switch "$DEFAULT_BRANCH"
git branch -D "mica-has-a-new-name"

popd || exit

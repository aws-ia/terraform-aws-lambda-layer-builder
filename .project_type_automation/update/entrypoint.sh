#!/bin/bash -ex
# Do not remove
PROJECT_PATH="${BASE_PATH}/project"
PROJECT_TYPE_PATH="${BASE_PATH}/projecttype"

cd ${PROJECT_PATH}
UPDATE_BRANCH="ephemeral_project-updates" 

export GH_DEBUG=1
REMOTE=$(git remote -v | awk '{print $2}' | head -n 1)
git remote remove origin
git remote add origin ${REMOTE}
git fetch --all

git push origin -d $UPDATE_BRANCH || true
git checkout -b "$UPDATE_BRANCH"
/bin/update.py -s ${PROJECT_TYPE_PATH} -d ${PROJECT_PATH}

if [ -n "${BASE_PATH}" ]
then
  git add . --all
  git commit -m "(automated) Updates from project type"
  git push -f --set-upstream origin $UPDATE_BRANCH
  gh pr create --title "Updates from project type " --body "_This is an automated PR incorporating changes from this project's upstream project type. Please review and either approve/merge or reject as appropriate_"
else
  echo "Local build mode (skipping git commit)"
fi

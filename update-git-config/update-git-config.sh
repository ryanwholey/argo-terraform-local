#!/bin/bash

set -ex

GIT_ORG=$1
GIT_REPO=$2
IMAGE_TAG=$3

git config --global user.email "image-tag-updater@example.com"
git config --global user.name "Image Tag Updater"

git config --global credential.https://github.com.username $GIT_USER

echo 'echo $GIT_TOKEN' > /tmp/git-token.sh && chmod +x /tmp/git-token.sh
export GIT_ASKPASS=/tmp/git-token.sh

git clone https://github.com/$GIT_ORG/$GIT_REPO
cd $GIT_REPO

yq write --inplace values.yaml image.tag $IMAGE_TAG
git add values.yaml
git commit -m "Update image tag to $IMAGE_TAG"
git push origin master

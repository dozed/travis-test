#!/bin/bash

set -ev

# Check dependencies
# rsync -v


echo "Config"

# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
# https://gist.github.com/domenic/ec8b0fc8ab45f39403dd
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploy_key.enc -out deploy_key -d
chmod 600 deploy_key
eval `ssh-agent -s`
ssh-add deploy_key

git config user.name "Travis CI"
git config user.email "ci@scalatra.org"


ls -al
# total 5420
# drwxrwxr-x  5 travis travis    4096 Mar 25 23:44 .
# drwxrwxr-x  3 travis travis    4096 Mar 25 23:44 ..
# -rw-------  1 travis travis    1675 Mar 25 23:44 deploy_key
# -rw-rw-r--  1 travis travis    1680 Mar 25 23:44 deploy_key.enc
# drwxrwxr-x  8 travis travis    4096 Mar 25 23:44 .git
# -rwxrwxr-x  1 travis travis     889 Mar 25 23:44 hello.sh
# -rw-rw-r--  1 travis travis 5511722 Feb 27 12:53 hugo_0.19-64bit.deb
# drwxrwxr-x 25 travis travis    4096 Mar 25 23:44 scalatra
# drwxrwxr-x 11 travis travis    4096 Mar 25 23:44 scalatra-website
# -rw-rw-r--  1 travis travis     380 Mar 25 23:44 .travis.yml



echo "Build"

pwd

# Final site is in travis-test/gh-pages
cd ~/travis-test
git checkout gh-pages



# Build scalatra site
cd ~/scalatra-website
git checkout origin/feature/hugo

ls -al

hugo -b https://takezoe.github.io/scalatra-website/ -d gh-pages

ls -al
ls -al gh-pages

rsync -av gh-pages ~/travis-test/gh-pages

ls -al ~/travis-test/gh-pages


# Commit and push changes
cd ~/travis-test
git add .
git commit -m "Built gh-pages"
git push origin gh-pages

# Build scalatra apidocs
# cd ~/scalatra
#
# git checkout origin/2.5.x
# sbt unidoc
#
# ls -al target
# ls -al target/scala-2.12
# ls -al target/scala-2.12/unidoc

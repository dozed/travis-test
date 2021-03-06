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

git config --global user.name "Travis CI"
git config --global user.email "ci@scalatra.org"

git clone git@github.com:dozed/travis-test.git


ls -al
# total 5424
# drwxrwxr-x  6 travis travis    4096 Mar 26 11:57 .
# drwxrwxr-x  3 travis travis    4096 Mar 26 11:57 ..
# -rw-------  1 travis travis    1675 Mar 26 11:57 deploy_key
# -rw-rw-r--  1 travis travis    1680 Mar 26 11:57 deploy_key.enc
# drwxrwxr-x  8 travis travis    4096 Mar 26 11:57 .git
# -rwxrwxr-x  1 travis travis    1899 Mar 26 11:57 hello.sh
# -rw-rw-r--  1 travis travis 5511722 Feb 27 12:53 hugo_0.19-64bit.deb
# drwxrwxr-x 25 travis travis    4096 Mar 26 11:57 scalatra
# drwxrwxr-x 11 travis travis    4096 Mar 26 11:57 scalatra-website
# drwxrwxr-x  3 travis travis    4096 Mar 26 11:57 travis-test
# -rw-rw-r--  1 travis travis     435 Mar 26 11:57 .travis.yml

# pwd
# /home/travis/build/dozed/travis-test


echo "Build"


# Final site is in travis-test/gh-pages
cd travis-test
git checkout gh-pages

# always build full site
rm -rf *

cd ..


# Build scalatra site
cd scalatra-website
git checkout origin/feature/hugo

ls -al

# TODO remove
hugo -b https://takezoe.github.io/scalatra-website/ -d gh-pages || true

ls -al
ls -al gh-pages

rsync -av gh-pages/* ../travis-test

cd ..


# Build scalatra apidocs v2.5.x
cd scalatra

git checkout origin/2.5.x
sbt unidoc

mkdir -p ../travis-test/apidocs/2.5
rsync -av target/scala-2.12/unidoc/* ../travis-test/apidocs/2.5

cd ..


# Build scalatra apidocs v2.4.x
cd scalatra

git checkout origin/2.4.x
sbt unidoc

mkdir -p ../travis-test/apidocs/2.4
rsync -av target/scala-2.12/unidoc/* ../travis-test/apidocs/2.4

cd ..


# Commit and push changes
cd travis-test
ls -al
ls -al apidocs
git rm --cached -r .
git add --all .
git commit -m "Built gh-pages"
git push origin gh-pages


echo "Done"

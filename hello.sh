#!/bin/bash

set -ev

echo "hello.."


# Install hugo
wget https://github.com/spf13/hugo/releases/download/v0.19/hugo_0.19-64bit.deb
sudo dpkg -i hugo_0.19-64bit.deb



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

# Build scalatra site
cd scalatra-website
git checkout -b feature/hugo
hugo -b https://takezoe.github.io/scalatra-website/ -d gh-pages

ls -al
ls -al gh-pages


# Build scalatra apidocs
cd scalatra

sbt unidoc

ls -al target
ls -al target/scala-2.12
ls -al target/scala-2.12/unidoc

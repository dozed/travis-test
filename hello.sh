#!/bin/bash

set -ev

echo "hello.."

ls -al

sbt unidoc

ls -al target
ls -al target/scala-2.12
ls -al target/scala-2.12/unidoc

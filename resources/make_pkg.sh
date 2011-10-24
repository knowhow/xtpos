#!/bin/bash

PKG_NAME=xtpos
PKG_DIR=resources

mkdir ../packages
rm ../packages/$PK_NAME.gz
gnutar cvfz ../packages/$PKG_NAME.gz ../$PKG_DIR --exclude=.gitignore --exclude=package --exclude=*.gz --exclude=.git


#!/usr/bin/env bash
set -e

pushd ../bosh-simple
echo "This script builds a tile that packages broker and Spacebears' BOSH release"

go_pkg_remote=https://storage.googleapis.com/golang/go1.9.linux-amd64.tar.gz
go_pkg_path=./tmp/go-linux-amd64.tar.gz

if [ -a "${go_pkg_path}" ]; then
  echo "Go package already exist, skipping download"
else
  echo "Go package doesn't exist, downloading"
  wget "${go_pkg_remote}" -O "${go_pkg_path}"
fi
echo "${go_pkg_remote}" > ./tmp/go-version.txt

echo "Packaging local source"

tar -cvzf ./tmp/spacebears_src.tgz -C ../src/ spacebears/

echo "Adding blobs"

bosh add-blob ./tmp/go-linux-amd64.tar.gz go-linux-amd64.tar.gz
bosh add-blob ./tmp/go-version.txt go-version.txt
bosh add-blob ./tmp/spacebears_src.tgz spacebears_src.tgz

echo "Creating release"
bosh create-release --force --tarball ./tmp/bosh-simple.tgz

mv ./tmp/bosh-simple.tgz ../tile-for-bosh-with-syslog/tmp/bosh-simple.tgz

popd

echo "Zipping up the broker app"

zip -j -r ./tmp/broker.zip ../src/broker/* --exclude \*.pyc

wget \
    https://github.com/pivotal-cf/syslog-migration-release/releases/download/v10.0.1/syslog-migration-10.0.1.tgz \
    -O ./tmp/syslog-migration.tgz

tile build

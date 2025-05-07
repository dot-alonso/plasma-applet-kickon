#!/bin/sh
if [ -e tmp ]; then
  rm -r tmp
fi
mkdir tmp
cp -r src/package tmp/io.github.jinliu.kickon
pushd tmp
tar -c -f ../io.github.jinliu.kickon.tar.xz --xz io.github.jinliu.kickon
popd
rm -r tmp

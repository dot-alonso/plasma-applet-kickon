#!/bin/sh
$XGETTEXT `find . -name \*.js -o -name \*.qml -o -name \*.cpp` -o $podir/template.pot

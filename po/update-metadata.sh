#!/bin/sh

BASEDIR=".." # root of translatable sources
PROJECT="plasma_applet_org.kde.store.nowdock.plasmoid" # project name
PROJECTPATH="../nowdockplasmoid" # project path
BUGADDR="https://github.com/psifidotos/nowdock-plasmoid" # MSGID-Bugs
WDIR="`pwd`" # working dir

intltool-merge --quiet --desktop-style . ../metadata.desktop.template "${PROJECTPATH}"/metadata.desktop

echo "metadata.desktop file was updated..."

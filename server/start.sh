#!/bin/sh
cd "$(dirname "$0")"
java -jar packwiz-installer-bootstrap.jar -g -s server https://raw.githubusercontent.com/hippgroot/forever-craft/main/pack.toml
exec java @jvm-args.txt -jar fabric.jar --nogui

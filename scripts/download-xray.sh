#!/bin/bash

set -e

if [[ $# != 1 ]]; then
    echo "Usage: $(basename $0) <xray version>"
    exit 1
fi

xray_version=$1

cd "$( dirname "${BASH_SOURCE[0]}" )"

mkdir -p ../files/release
cd ../files/release

download_xray() {
    xray_zipfile=Xray-linux-64-$xray_version.zip

    echo "download xray $xray_version"
    wget https://github.com/XTLS/Xray-core/releases/download/$xray_version/Xray-linux-64.zip -O $xray_zipfile
    echo "unzip xray $xray_version"
    unzip -o $xray_zipfile xray
}

download_xray

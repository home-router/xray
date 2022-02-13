#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

mkdir -p ../files/release
cd ../files/release

bakfile() {
    local fname=$1
    if [[ -r $fname ]]; then
        mv -f $fname $fname.bak
    fi
}

download_geoip() {
    echo "download geiop.dat from Loyalsoldier"
    bakfile geoip.dat
    wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
    #wget https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat
}

download_geosite() {
    echo "download geosite.dat from Loyalsoldier"
    [[ -r geosite.dat ]] && mv -f geosite.dat geosite.dat.bak
    bakfile geosite.dat
    wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
    #wget https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat
}

download_h2y() {
    echo "download h2y.dat from ToutyRater"
    bakfile h2y.dat
    wget https://github.com/ToutyRater/V2Ray-SiteDAT/raw/master/geofiles/h2y.dat 
}

download_china_ip_list() {
    echo "download china ip list from ToutyRater"
    bakfile china_ip_list.txt
    wget https://github.com/17mon/china_ip_list/raw/master/china_ip_list.txt
}

download_geoip
download_geosite
download_china_ip_list

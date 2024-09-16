#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

mkdir -p ../files/release
cd ../files/release

function is_modified_within_last_week() {
    file="$1";
    if [[ $(find "$file" -mtime -7 -print) ]]; then
        return 0 # this is true.
    else
        return 1
    fi
}

download_datfile() {
    local url=$1

    local datfile=$(basename $url)

    if is_modified_within_last_week "${datfile}"; then
        echo "skip downloading ${datfile} because modified within last week"
        return
    fi

    echo "download ${datfile} from ${url}"
    curl -L "${url}" -o "${datefile}.new"

    # Make backup before mv.
    if [[ -r "${datfile}" ]]; then
        mv -f "${datfile}" "${datfile}.bak"
    fi
    mv "${datefile}.new" "${datfile}"
}

# geoip
#download_datfile https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
download_datfile https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat

# geosite
#download_datfile https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
download_datfile https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat

# china_ip_list from ipip.net
download_datfile https://github.com/17mon/china_ip_list/raw/master/china_ip_list.txt


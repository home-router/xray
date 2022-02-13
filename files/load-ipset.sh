#!/bin/bash

if [[ $# != 2 ]]; then
    echo "Usage: $(basename $0) <ip set name> <ip list file>"
    exit 1
fi

ipset_name=$1
list_file=$2

# Ensure named set is created.
nft add set inet mangle "${ipset_name}" \{ type ipv4_addr\; flags interval\; \}

# Read whole file into an array.
readarray -t ip_list <"$list_file"

step=50
for (( i=0; i < ${#ip_list[@]}; i+=step )); do
    # From https://stackoverflow.com/a/11360591/306935
    batch="${ip_list[@]:i:$step}" # create space delimited string from array
    # Replace all spaces with comma, refer to https://wiki.bash-hackers.org/syntax/pe#search_and_replace
    batch=${batch// /,}
    nft add element inet mangle "${ipset_name}" \{ $batch \}
done


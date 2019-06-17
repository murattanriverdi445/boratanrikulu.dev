#!/bin/bash

filename='/opt/scripts/aydintd.net-access_log'

ip_list=()
while read -r line; do
        ip=$( echo $line | cut -d '-' -f1)
        echo "$ip" >> ip.txt
done < $filename

sort -n ip.txt | uniq -c | sort -nr
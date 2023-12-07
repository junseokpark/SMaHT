#!/bin/bash

for file in NIHMS1648953-supplement-1648953_*.xlsx; do
    echo $file
    output_filename=$(echo "$file" | sed 's/NIHMS1648953-supplement-1648953_//')
    ln -s "$file" "$output_filename"
    #echo $output_filename
done

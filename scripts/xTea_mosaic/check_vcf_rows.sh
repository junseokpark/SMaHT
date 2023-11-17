#!/bin/bash

# Define the directories
directories=("TITR_1" "TITR_2" "TITR_3" "TITR_4" "TITR_5" "TITR_6")

# Loop through each directory
for dir in "${directories[@]}"; do
    echo "Checking files in $dir directory:"
    
    # Check if the directory exists
    if [ -d "$dir" ]; then
        # Loop through VCF files in the directory
        for file in "$dir"/Alu/*.vcf; do
            if [ -e "$file" ]; then
                # Use 'grep' to count the number of rows in the VCF file
                num_rows=$(grep -vc '^#' "$file")
                echo "File: $file, Number of Rows: $num_rows"
            fi
        done
    else
        echo "Directory $dir does not exist."
    fi
    
    echo
done


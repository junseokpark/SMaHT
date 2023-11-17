#!/bin/bash

TARGET_DIR="/n/data1/bch/genetics/lee/projects/SMaHT/results/xTea/mosaic"

# Check if the target directory exists
if [ -d "$TARGET_DIR" ]; then
    # Get subdirectories and store them in an array
    SUBDIRS=("$TARGET_DIR"/*)

    # Filter out non-directory entries
    SUBDIRS=("${SUBDIRS[@]%/}")

    # Display the list of subdirectories
    echo "Subdirectories of $TARGET_DIR:"
    
    # Loop through the array and print each subdirectory
    for SUBDIR in "${SUBDIRS[@]}"; do
        if [ -d "$SUBDIR" ]; then
            echo "$SUBDIR"
            
            # Get Sample directories and store them in an array
            SAMPLEDIRS=("$SUBDIR"/*)
            SAMPLEDIRS=("${SAMPLEDIRS[@]%/}")
            echo "Sample directories of $SUBDIR:"

            # Loop
            for SAMPLEDIR in "${SAMPLEDIRS[@]}"; do
                if [ -d "$SAMPLEDIR" ]; then
                echo "$SAMPLEDIR"
                # Check if VCF files exist in Alu and L1 subdirectories
                    #if [ -e "$SAMPLEDIR/Alu/*.vcf" ] && [ -e "$SAMPLEDIR/L1/*.vcf" ]; then
                    if [ -n "$(find "$SAMPLEDIR/Alu" -maxdepth 1 -type f -name '*.vcf' -print -quit)" ] && \
                   [ -n "$(find "$SAMPLEDIR/L1" -maxdepth 1 -type f -name '*.vcf' -print -quit)" ]; then
                        echo "VCF files found for $SAMPLEDIR in Alu and L1 subdirectories."
                    else
                        echo "No VCF files found for $SAMPLEDIR in Alu or L1 subdirectories."
                    fi
                   
                fi
            done
        fi
        echo " "
    done
else
    echo "Error: Target directory does not exist."
fi


#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 -t TARGET_DIR [-p PREFIX]"
    echo
    echo "  -t, --target-dir   Specify the target directory"
    echo "  -p, --prefix       Specify the directory prefix (optional)"
}

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--target-dir) TARGET_DIR="$2"; shift ;;
        -p|--prefix) PREFIX="$2"; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; show_help; exit 1 ;;
    esac
    shift
done

# Check if TARGET_DIR is specified
if [ -z "$TARGET_DIR" ]; then
    echo "Error: Target directory not specified."
    show_help
    exit 1
fi


# Check if TARGET_DIR exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Target directory '$TARGET_DIR' does not exist."
    exit 1
fi

# Change to the target directory
cd "$TARGET_DIR" || exit
pwd

# Add options
SUB_DIRS=($(find . -maxdepth 1 -mindepth 1 -type d))


remove_files() {
    local dir="$1"

    echo "remove $dir/script/exonerate*"
    ls $dir/script/exonerate*
    rm $dir/*/script/exonerate*

    echo "remove $dir/retro_v1_*/seg*"
    ls $dir/retro_v1_*/seg*
    rm $dir/*/retro_v1_*/seg*

    echo "remove $dir/align/*.final.bam"
    ls $dir/align/*.final.bam
    rm $dir/align/*.final.bam

}

# Loop through the array of subdirectories
for dir in "${SUB_DIRS[@]}"; do
    dir_name=$(basename "$dir")
    # If PREFIX is set, check if the directory name starts with the specified prefix
    if [[ -n $PREFIX ]]; then
        if [[ $dir_name == $PREFIX* &&  ! $dir_name == *_NoModel*  ]]; then
            echo "Processing directory: $dir_name"
            remove_files $dir_name
        fi
    else
        echo "Processing directory: $dir_name"
        remove_files $dir_name
    fi

done;


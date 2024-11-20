#!/bin/bash

# Print the current directory
echo "Executing in the current directory: $(pwd)"

resultFile="listOfLargeFiles.txt"

# Function to filter files <= 2MiB and extract filenames
function extract_large_files {
    local input="$1"
    awk '{
        size = $3
        if (size ~ /MiB$/) {
            # Remove "MiB" suffix and convert to numeric value
            size_value = substr(size, 1, length(size) - 3) + 0
            if (size_value >= 3) {
                print $4
            }
        }
    }' "$input"
}

function main {
	local tempFile=$(mktemp)

	# work over each commit and append all files in tree to $tempFile
	local IFS=$'\n'
	local commitSHA1
	for commitSHA1 in $(git rev-list --all); do
		git ls-tree -r --long "$commitSHA1" >>"$tempFile"
	done
ls -al
	# sort files by SHA-1, de-dupe list and finally re-sort by filesize
	sort --key 3 "$tempFile" | \
		uniq | \
		sort --key 4 --numeric-sort --reverse | \
        cut -c 1-12,53- | \
        $(command -v gnumfmt || echo numfmt) --field=3 --to=iec-i --suffix=B --padding=7 --round=nearest | \
        tee "$resultFile"

	# remove temp file
	rm "$tempFile"
}

# Execute the main function and filter large files
main
echo "Filtered file names (>= 2MiB):"
extract_large_files "$resultFile"
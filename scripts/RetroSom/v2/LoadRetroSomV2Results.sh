#!/bin/bash

# Function to determine TE family from TE subfamily
getTEFamilyFromTESubFamily() {
    local te_sub="$1"
    local te_types=("ALU" "LINE" "L1" "SVA" "HERV")
    
    # Loop through te_types and check if te_sub contains any
    for element in "${te_types[@]}"; do
        if [[ "$te_sub" == *"${element^^}"* ]]; then  # Convert to uppercase and check
            if [[ "$element" == "L1" ]]; then
                element="LINE"
            fi
            echo "$element"
            return 0
        fi
    done
    echo "$te_sub"  # Return original string if no match is found
}

# Function to load RetroSom results from a directory
LoadRetroSomResults() {
    local directory="$1"
    local te_type="$2"

    # List all SVG files in the directory
    svg_files=($(find "$directory" -type f -name '*.svg'))

    # Define column names (in Bash, just for clarity)
    column_names=("strand" "family" "chrom" "position" "position_e" "counts")
    
    # Initialize the result file (replace this with a method to store your rows)
    result_file="results.tsv"
    echo -e "strand\tfamily\tchrom\tposition\tposition_e\tcounts" > "$result_file"

    # Iterate over each SVG file
    for svg_file in "${svg_files[@]}"; do
        filename=$(basename "$svg_file")

        # Extract the part of the filename after 'strand'
        filename="${filename#*strand}"
        IFS='_' read -r -a parts <<< "$filename"  # Split filename by "_"

        # Check TE type from file and skip if not matching
        te_type_from_file=$(getTEFamilyFromTESubFamily "${parts[1]^^}")
        if [[ "$(getTEFamilyFromTESubFamily "${te_type^^}")" != "$te_type_from_file" ]]; then
            continue
        fi

        # Check strand type
        supportingReadDirectory="retro_v1_"
        if [[ "${parts[0]}" == "strand1" ]]; then
            strand="-"
            supportingReadDirectory+="1"
        else
            strand="+"
            supportingReadDirectory+="0"
        fi

        # Remove '.svg' from the last part of the filename
        parts[${#parts[@]}-1]="${parts[${#parts[@]}-1]%.svg}"

        # Construct supporting file name
        supportFileName=$(dirname "$directory")
        sampleName=$(basename "$supportFileName")
        supportFileName="$supportFileName/$supportingReadDirectory/$te_type_from_file/${sampleName}.${te_type_from_file}.SR.PE.calls"

        # Simulate calling a function to get frequency info (adjust this for actual data retrieval)
        # For now, we'll just use placeholder values
        pos_e="placeholder_pos_e"
        counts="placeholder_counts"

        # Append to the result file
        echo -e "$strand\t${parts[1]}\t${parts[2]}\t${parts[3]}\t$pos_e\t$counts" >> "$result_file"
    done

    # Output result file (or any further processing)
    cat "$result_file"
}

# Example usage
LoadRetroSomResults "/path/to/your/directory" "ALU"

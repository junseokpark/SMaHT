def getTEFamilyFromTESubFamily(te_sub) -> str:
    te_types = ['ALU', 'LINE', 'L1', 'SVA', 'HERV']
    for element in te_types:
        if element in te_sub.upper():
            if element == 'L1':
                element = 'LINE'            
            return element
    return te_sub  # Return original string if no match is found

def LoadRetroSomResults(directory, te_type):
    
    # List all files in the directory
    files = os.listdir(directory)
        
    # Filter files with '.svg' extension
    svg_files = [file for file in files if file.endswith('.svg')]
    
    column_names = ["strand","family","chrom","position", "position_e", "counts"]
    result_df = pd.DataFrame(columns=column_names)
    
    # Divide filenames by "_" and check if they start with "strand*"
    relevant_files = []
    for filename in svg_files:
        filename = filename[filename.find('strand'):]
        
        parts = filename.split('_')
        
        # check only the matched te_type
        te_type_from_file = getTEFamilyFromTESubFamily(parts[1].upper())        
        if getTEFamilyFromTESubFamily(te_type.upper()) != te_type_from_file:
            continue
        
        supportingReadDirectory = "retro_v1_"
        if parts[0] == "strand1":
            parts[0] = "-"
            supportingReadDirectory += "1"
        else:
            parts[0] = "+"
            supportingReadDirectory += "0"
        
        parts[len(parts)-1] = parts[len(parts)-1].replace('.svg','')
        
        supportFileName = Path(directory).parent
        sampleName = os.path.basename(Path(supportFileName))
        
        supportFileName = os.path.join(supportFileName, supportingReadDirectory, 
                                       te_type_from_file, sampleName + "." + te_type_from_file + ".SR.PE.calls")
        
        
        freqInfo = getFrequencyForRetroSom(supportFileName, parts[1], parts[2], int(parts[3]) )
        
        
        parts.append(freqInfo.pos_e)
        parts.append(freqInfo.cnt)
        
        row_df = pd.DataFrame([parts], columns=column_names)      
        result_df = pd.concat([result_df,row_df], ignore_index=True)
        
        return result_df 
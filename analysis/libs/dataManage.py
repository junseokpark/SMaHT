def LoadRetroSomResults(directory, te_type):
    

    # List all files in the directory
    files = os.listdir(directory)
        
    # Filter files with '.svg' extension
    svg_files = [file for file in files if file.endswith('.svg')]
    
    column_names = ["strand","family","chrom","position"]
    result_df = pd.DataFrame(columns=column_names)
    
    # Divide filenames by "_" and check if they start with "strand*"
    relevant_files = []
    for filename in svg_files:
        filename = filename[filename.find('strand'):]
        
        parts = filename.split('_')
        
        
        if parts[0] == "strand1":
            parts[0] = "-"
        else:
            parts[0] = "+"
        
        parts[len(parts)-1] = parts[len(parts)-1].replace('.svg','')
        row_df = pd.DataFrame([parts], columns=column_names)      
        result_df = pd.concat([result_df,row_df], ignore_index=True)
        relevant_files.append(filename)

    
    def extract_te_type(family):
        if family.startswith('Alu'):
            return 'Alu'
        elif family.startswith('L1'):
            return 'L1'
        else:
            return None
    
    result_df['class'] = result_df['family'].apply(extract_te_type)    

    result_df = result_df.reindex(columns = [column_names[2],column_names[3],column_names[0],'class',column_names[1]])
    
    result_df = result_df[result_df['class'].str.upper().str.contains(te_type.upper())]

    return result_df 
# # Specify the directory containing the files
# directory = '../results/RetroSom/shortread/mosaic/mixedDataRetroSom/200x/v2/TITR_1/visual'

# # Retrieve relevant SVG files
# df = filter_svg_files(directory, "l1")

# df


def convertResultToBedFile(df, saveFileNameWithDir):
    temp = df
    temp['position'] = temp['position'].astype(int)
    temp['position2'] = temp['position'] +1 
    temp['name'] = '.'
    temp['score'] = None

    temp = temp
    temp = temp[['chrom','position','position2','class','score','strand','family']]

    temp.to_csv(saveFileNameWithDir, sep='\t', index=False, header=False)
    
#    return temp

def count_directories_with_string(directory, search_string):
    count = 0
    
    if not checkFileExist(directory): return count
    
    for filename in os.listdir(directory):
        if os.path.isdir(os.path.join(directory, filename)) and search_string in filename and "NoModel" not in filename:
            count += 1
    return count


def loadVCF(file_path):
    vcf = pysam.VariantFile(file_path)
    print(file_path,countVCF(vcf))
    return vcf

def countVCF(vcf):
    return sum(1 for _ in vcf)

def filterVCF(vcf, filter_condition=None):
    filtered_variants = []
    for record in vcf.fetch():
        if record.filter.keys() == [filter_condition]:
            filtered_variants.append(record)
    return filtered_variants

def VCFtoBED(variants):
    column_names = ['chrom','position','position2','class','score','strand','family']
    bed_records = []
    for variant in variants:
        chrom = variant.chrom
        start = variant.pos - 1  # BED format uses 0-based start
        end = variant.pos + len(variant.ref) - 1
        name =  variant.alts[0].replace("<INS:ME:", "").replace(">", "").capitalize() if variant.alts else "."
        if name == "Line1":
            name = "L1"
        
        score = "0"  # BED score is optional, here we set it to 0
        strand = "."  # Strand information is optional and not present in VCF, so set to '.'
        bed_records.append([chrom, start, end, name, score, strand, "."])

    return pd.DataFrame(bed_records, columns=column_names)

def convertTEClassString(inputClass):
    if inputClass == "L1":
        return "LINE1"
    else:
        return inputClass.upper()

def checkFileExist(fileNameWithPath):    
    if os.path.exists(fileNameWithPath):
        return True
    else: 
        print(fileNameWithPath, " is not existing")
        return False
    
    
def getResultFunctionForTool(toolName,resultParentDirectory,caseSampleName,teClass):
    if toolName.strip().lower() in ["xtea-mosaic", "xtea"] :
        fileNameWithPath = os.path.join(resultParentDirectory,caseSampleName,teClass,caseSampleName+"_"+convertTEClassString(teClass)+".vcf")
        if not checkFileExist(fileNameWithPath): return None
        vcf = loadVCF(fileNameWithPath)
        filtered_vcf = filterVCF(vcf,"PASS")
        tempResultDF = VCFtoBED(filtered_vcf)
    elif toolName.strip().lower() == "melt":
        fileNameWithPath = os.path.join(resultParentDirectory,caseSampleName,convertTEClassString(teClass)+".final_comp.vcf")
        if not checkFileExist(fileNameWithPath): return None
        vcf = loadVCF(fileNameWithPath)
        filtered_vcf = filterVCF(vcf,"PASS")
        tempResultDF = VCFtoBED(filtered_vcf)
    elif toolName.strip().lower() == "retrosom":
        resultDirectory = caseSampleName + "_NoModel"
        visualDirectory = "visual"
        count = count_directories_with_string(resultParentDirectory,caseSampleName)
        if count <= 1:
            resultDirectory = os.path.join(resultParentDirectory, caseSampleName)
        else:
            resultDirectory = os.path.join(resultParentDirectory, resultDirectory)
        
        tempResultDF = LoadRetroSomResults(os.path.join(resultDirectory,visualDirectory) , teClass)
    else:
        print(toolName + "is not available for the function")
        return None
    
    return tempResultDF

def saveResultDFtoBedFileforTool(toolName, resultParentDirectory, resultFileName, resultDF):
    if toolName.strip().lower() in ["xtea-mosaic", "xtea", "melt"] :
        resultDF.to_csv(os.path.join(resultParentDirectory, resultFileName), sep='\t', index=False, header=False)
    elif toolName.strip().lower() == "retrosom":
        convertResultToBedFile(resultDF, os.path.join(resultParentDirectory, resultFileName))

    else: 
        print(toolName + "is not available for the function")
        return None
    
    
def natural_key(string):
    """Convert string to a list of integers and strings for natural sorting."""
    return [int(text) if text.isdigit() else text for text in re.split(r'(\d+)', string)]

def sort_BedTool(bedtool):
    """Sort a BedTool object in natural chromosome order and return a sorted BedTool object."""
    # Convert BedTool to DataFrame
    df = bedtool.to_dataframe()
    
    # Check if the DataFrame is empty
    if df.empty:
        return pybedtools.BedTool([])  # Return an empty BedTool object
    
    # Sort the DataFrame by the first column (chrom), and then by start and end positions
    df['chrom'] = df.iloc[:, 0]
    df['start'] = df.iloc[:, 1].astype(int)
    df['end'] = df.iloc[:, 2].astype(int)
    
    # Apply natural sorting to the chrom column
    df['chrom'] = df['chrom'].astype('category')
    df['chrom'] = df['chrom'].cat.set_categories(sorted(df['chrom'].unique(), key=natural_key), ordered=True)
    df.sort_values(by=['chrom', 'start', 'end'], inplace=True)
    
    # Convert the sorted DataFrame back to a BedTool object
    sorted_bedtool = BedTool.from_dataframe(df)
    
    return sorted_bedtool
    
    
def getUniqueWithWindowFromBeds (bed, other_beds, l=100, r=100):
    unique = sort_BedTool(bed)
    for other_bed in other_beds:
        unique = unique.window(b=sort_BedTool(other_bed), l=l, r=r, v=True)
    unique = sort_BedTool(unique)
    
    return unique

def getUnionBed(beds):
    union = sort_BedTool(beds[0])
    #print(len(union))
    for bed in beds[1:]:
        union = union.cat(sort_BedTool(bed), postmerge=False)
        #print(len(union))
    union = sort_BedTool(union).merge()
    
    return union

def getIntersectBed(beds, l=100, r=100):
    intersection = sort_BedTool(beds[0])
    for bed in beds[1:]:
        intersection = intersection.window(u=True, b=sort_BedTool(bed), l=l, r=r)
            
    if len(intersection) == 0:
        return intersection
    
    return sort_BedTool(intersection).merge()

# def getIntersectBed(beds, l=100, r=100):
#     # Start with the sorted records of beds[0]
#     intersection = sort_BedTool(beds[0])
        
#     # Iterate through the rest of the beds
#     for bed in beds[1:]:
#         # Perform the intersection with the window function
#         intersection = intersection.window(b=sort_BedTool(bed), l=l, r=r)
    
#     # Filter the intersection to keep only the records from beds[0]
#     beds0_records = set((rec.chrom, rec.start, rec.end, rec.name) for rec in beds[0])
#     final_records = []
#     for rec in intersection:
        
#         if (rec.chrom, rec.start, rec.end, rec.name) in beds0_records:
#             final_records.append((rec.chrom, rec.start, rec.end, rec.name))
    
#     # Remove duplicates by converting to a set and back to a list    
#     unique_final_records = list(set(final_records))
        
#     # Convert the list of tuples to a BedTool object
#     final_bedtool = BedTool(unique_final_records)
    
    
#     return sort_BedTool(final_bedtool).merge()

def getResultDF(toolName, teClass, depth, vaf, windowSize, resultBedDF, goldStandardDF, detailedBedFileOutputDir = "results/resultComparisons"):
    resultColumns = ['toolName','teClass','depth', 'vaf', 'windowSize','caseEvents', 'controlEvents',
                     'TP','FP', 'FN','precision','recall']
    resultdDF = pd.DataFrame(columns= resultColumns)


    # Load Bed Files : This would be loop for all the results
    caseBedFile = resultBedDF[(resultBedDF['toolName'] == toolName) &
                        (resultBedDF['depth'] == depth) &
                        (resultBedDF['class'] == teClass)]['filePath'].tolist()[0]
    caseBed = BedTool(caseBedFile)

    controlBedFile = goldStandardDF[(goldStandardDF['class'] == teClass) &
                                (goldStandardDF['backBone'] == True)]['filePath'].tolist()[0]
    controlBed = BedTool(controlBedFile)

    answerBedFiles = goldStandardDF[(goldStandardDF['class'] == teClass) &
                                (goldStandardDF['backBone'] == False)]['filePath'].tolist()
    answerBeds = [BedTool(bed_file) for bed_file in answerBedFiles]
    unionAnswerBed = getUnionBed(answerBeds)


    # False Positive
    # (case) - (control) - Union (GoldStandard)
    #FP_bed = getUniqueWithWindowFromBeds(caseBed, [controlBed, getUnionBed(answerBeds)],windowSize,windowSize)
    caseUniqueFromContolBed = getUniqueWithWindowFromBeds(caseBed,[controlBed],windowSize,windowSize)
    FP_bed = getUniqueWithWindowFromBeds(caseUniqueFromContolBed,[unionAnswerBed],windowSize,windowSize)

    # True Positive
    # (1) Unique MEI
    targetAnswerBedFiles = goldStandardDF[(goldStandardDF['class'] == teClass) & 
                                    (goldStandardDF['backBone'] == False) &
                                    (goldStandardDF['mixedRatio'] == vaf)]['filePath'].tolist()
    

    targetControlBedFiles = [item for item in answerBedFiles if item not in targetAnswerBedFiles]
    targetControlBedFiles.append(controlBedFile)

    if len(targetAnswerBedFiles) > 1 :
        targetAnswerBed = getUnionBed([BedTool(bed_file) for bed_file in targetAnswerBedFiles])
    else:
        targetAnswerBed = BedTool(targetAnswerBedFiles[0])

    targetControlBed = [BedTool(bed_file) for bed_file in targetControlBedFiles]
    uniqueBed = getUniqueWithWindowFromBeds(targetAnswerBed,[getUnionBed(targetControlBed)], windowSize, windowSize)

    # (2) Get True Positive
    TP_bed = getIntersectBed([caseUniqueFromContolBed, uniqueBed], windowSize, windowSize)

    # (3) False Positive
    if len(TP_bed) == 0:
        FP_bed = caseBed
    else:
        FP_bed = getUniqueWithWindowFromBeds(caseBed, [TP_bed])


    # False Negative    
    #FN_bed = getUniqueWithWindowFromBeds(caseBed, [TP_bed], windowSize, windowSize)
    if len(TP_bed) == 0:
        FN_bed = uniqueBed
    else:
        FN_bed = getUniqueWithWindowFromBeds(uniqueBed, [TP_bed], windowSize, windowSize)
    
    
    # Recalcuations (ingore the previous codes for FN and FP), 6/12/2024
    #FP = len(caseBed) - len(TP_bed)
    
    # Change FP, 7/11/2024 
    #FN = len(uniqueBed) - len(TP_bed)
    
    ## Save Bed files
    savefileName = toolName+"-"+teClass+"-"+depth+"-"+str(vaf)+"-"+str(windowSize)
    os.makedirs(detailedBedFileOutputDir, exist_ok=True)
    
    
    
    caseBed.saveas(os.path.join(detailedBedFileOutputDir,savefileName+"-case.bed"))
    uniqueBed.saveas(os.path.join(detailedBedFileOutputDir,savefileName+"-unique.bed"))
    
    
    if len(TP_bed) > 0 : TP_bed.saveas(os.path.join(detailedBedFileOutputDir,savefileName+"-TP.bed"))
    
    #FP_bed = getUniqueWithWindowFromBeds(caseBed, [TP_bed], windowSize, windowSize)
    if len(FP_bed) > 0 : FP_bed.saveas(os.path.join(detailedBedFileOutputDir,savefileName+"-FP.bed"))
    
    #FN_bed = getUniqueWithWindowFromBeds(uniqueBed, [TP_bed], windowSize, windowSize)
    if len(FN_bed) > 0 : FN_bed.saveas(os.path.join(detailedBedFileOutputDir,savefileName+"-FN.bed"))
    
    

    # Precision and Recall
    #precision = len(TP_bed) / (len(TP_bed) + len(FP_bed))
    if (len(TP_bed) + len(FP_bed)) == 0 :
        precision = 0
    else:
        precision = len(TP_bed) / (len(TP_bed) + len(FP_bed))
        
    #recall = len(TP_bed) / (len(TP_bed) + len(FN_bed))
    if (len(TP_bed) + len(FN_bed)) == 0:
        recall = 0
    else:
        recall = len(TP_bed) / (len(TP_bed) + len(FN_bed))
    
    # total results
    resultdDF.loc[len(resultdDF)] = [toolName, teClass, depth, vaf, windowSize, len(caseBed), len(uniqueBed), len(TP_bed), len(FP_bed), len(FN_bed), precision, recall]
    #resultdDF.loc[len(resultdDF)] = [toolName, teClass, depth, vaf, windowSize, len(caseBed), len(TP_bed), FP, FN, precision, recall]
    
    # need to save each results
    
    return resultdDF
    
def checkRowCount(df, toolName, depth, TEclass):
    return len(df[(df['toolName'] == toolName) & (df['depth'] == depth) & (df['class'] == TEclass)])

def runCommand(command, outputFileWithPath = None):
    
    if isinstance(command, list):
        command = ' '.join(command) 
    
    try:
        if (outputFileWithPath is not None):
            with open(outputFileWithPath, 'w') as output_file:
                logging.info(f"Running command: {command}")
                subprocess.run(command, shell=True, check=True, stdout=output_file)
                logging.info(f"Successfully created: {outputFileWithPath}")
        else:
            logging.info(f"Running command: {command}")
            subprocess.run(command, shell=True, check=True)
            logging.info(f"Successfully executed: {outputFileWithPath}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Error running command: {command}")
        logging.error(f"Return code: {e.returncode}")
        logging.error(f"Output: {e.output}")
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}")
    

def runBedToolsSlop(bedFileWithPath, chromSizeFileWithPath, resultBedFileWithPath, windowSize):
    command = (
        f"bedtools slop -i {bedFileWithPath} -g {chromSizeFileWithPath} -b {windowSize} "
        "| sort -k1,1V -k1,1 -k2,2n"
    )
    
    try:
        runCommand(command,resultBedFileWithPath)
        return True
    except Exception as e:
        return False    


def runInterveneVenn(bedFiles, title, outputDirectory, bedtools_options='f=0.5,r'): # ,r -l 1000 -r 1000'):
    command = (
        f"intervene venn -i {bedFiles} --bedtools-options {bedtools_options} --filenames --title {title} "
        f"--output {outputDirectory} --save-overlaps"
    )
    
    try:
        runCommand(command)
        return True
    except Exception as e:
        return False    
    
def runInterveneUpset(bedFiles, outputDirectory, bedtools_options='f=0.5,r'): # ,r -l 1000 -r 1000'):
    
    command = (
        f"intervene upset -i {bedFiles} --bedtools-options {bedtools_options} --filenames "
        f"--output {outputDirectory}  --showzero --save-overlaps --showshiny"
    ) 
    # 
    
    try:
        runCommand(command, "shiny.fig.code")
        return True
    except Exception as e:
        return False    


def removeRLibDir(removalLibPath = "/home/jp394/R-3.5.1/library"):
    command = (
        f"Rscript -e '.libPaths(.libPaths()[.libPaths() != \"{removalLibPath}\"]); print(.libPaths())'"
    )
    
    try:
        runCommand(command)
        return True
    except Exception as e:
        return False        

def generateComparisonFigures(resultBedDF,toolNames,depths,windows,outputDirectory,teClass,resultTitle,
                              goldStandardDF = None,
                              chromSizeFile = "/n/data1/bch/genetics/lee/reference/hg38/hg38.chrom.sizes",
                              vennOutputDir="venn",
                              upsetOutputDir="upset",
                              prefix="E",
                              removalLibPath = None):
    
    ## WindowFileGeneration
    selectedResults = resultBedDF[(resultBedDF['toolName'].isin(toolNames)) & ((resultBedDF['class'] == teClass)) & ((resultBedDF['depth'].isin(depths)))]
    
    selectedGoldStandards = None
    if goldStandardDF is not None:
        selectedGoldStandards = goldStandardDF[goldStandardDF['class'] == teClass]

    selectedResults['windowSize'] = windows

    if os.path.exists(outputDirectory):
        
        logging.info(f"Directory exists: {outputDirectory}, removing it.")
        shutil.rmtree(outputDirectory, ignore_errors=True)

    os.makedirs(outputDirectory, exist_ok=True)
            

    resultComparisonColumns = ["toolName", "depth", "class", "windowSize", "extendedFileName", "extendedFileWithPath"]
    resultComparisonDF = pd.DataFrame(columns = resultComparisonColumns)

    # 1. Generate extended bed files
    for index, row in selectedResults.iterrows():
        #directory_path = os.path.dirname(row['filePath'])
        resultFileName = row['toolName']+"_"+row['depth']+"_"+row['class']+"_"+prefix+str(row['windowSize'])+".bed"
        
        resultBedFileWithPath = os.path.join(outputDirectory, resultFileName)
        
        
        runBedToolsSlop(row['filePath'], chromSizeFile, resultBedFileWithPath, windows)
        resultComparisonDF.loc[len(resultComparisonDF)] = [row['toolName'], row['depth'], teClass, str(row['windowSize']), resultFileName, resultBedFileWithPath]

    
    if selectedGoldStandards is not None:
        for index, row in selectedGoldStandards.iterrows():
            resultFileName = row['cellLineName']+"_"+str(row['mixedRatio'])+"_"+row['class']+"_"+prefix+str(windows)+".bed"
            resultBedFileWithPath = os.path.join(outputDirectory, resultFileName)
            runBedToolsSlop(row['filePath'], chromSizeFile, resultBedFileWithPath, windows)
            resultComparisonDF.loc[len(resultComparisonDF)] = [row['cellLineName'], str(row['mixedRatio']), teClass, str(windows), resultFileName, resultBedFileWithPath]
            
            
    resultBedFileList = resultComparisonDF['extendedFileName'].tolist()    
    inputBedFiles = ' '.join(resultBedFileList)
    currentDir = os.getcwd()
    os.chdir(outputDirectory)

    # 2. Generate Venn Diagram
    if len(resultBedFileList) <= 6:    
        runInterveneVenn(inputBedFiles, resultTitle, vennOutputDir, bedtools_options='f=0.5,r')
    else:
        logging.error(f"Cannot create venn diagram because total number of bed files is {len(resultBedFileList)}")

    # 3. Generate Upset figure
    #runCommand("Rscript -e 'system(\"defaults write org.R-project.R force.LANG en_US.UTF-8\")'")
    if removalLibPath is not None:
        removeRLibDir(removalLibPath)

    runInterveneUpset(inputBedFiles, upsetOutputDir, bedtools_options='f=0.5,r')

    os.chdir(currentDir)

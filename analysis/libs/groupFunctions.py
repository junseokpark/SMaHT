# Function to find and count intersection with a window
def find_intersection(bed_files, window=1000):
    bedtools_objs = [BedTool(bed_file) for bed_file in bed_files]
    intersection = bedtools_objs[0]
    for bedtool in bedtools_objs[1:]:
        intersection = intersection.intersect(bedtool, wa=True, wb=True, e=True, f=0.9, F=0.1)
    #intersection.saveas('intersection.bed')
    return intersection

# Function to find and count union with a window
def find_union(bed_files):
    bedtools_objs = [BedTool(bed_file) for bed_file in bed_files]
    union = bedtools_objs[0]
    for bedtool in bedtools_objs[1:]:
        union = union.cat(bedtool, postmerge=False)
    union = union.sort().merge()
    #union.saveas('union.bed')
    return union

# Function to find and count unique sets with a window
def find_unique(bed_file, other_bed_files, index, window=1000):
    bedtool = BedTool(bed_file)
    other_bedtools = [BedTool(bed_file) for bed_file in other_bed_files]
    unique = bedtool
    for other_bedtool in other_bedtools:
        unique = unique.subtract(other_bedtool, A=True, s=True, r=True, f=window/1000)
    #unique.saveas(f'unique_{index}.bed')
    return unique


# Function to find intersections with a window
def find_intersection_with_window(bed_files, l=300, r=20000):
    bedtools_objs = [BedTool(bed_file) for bed_file in bed_files]
    intersection = bedtools_objs[0]
    for bedtool in bedtools_objs[1:]:
        intersection = intersection.window(b=bedtool, l=l, r=r)
    intersection.saveas('intersection_with_window.bed')
    return len(intersection)

# Function to find union
def find_union(bed_files):
    bedtools_objs = [BedTool(bed_file) for bed_file in bed_files]
    union = bedtools_objs[0]
    for bedtool in bedtools_objs[1:]:
        union = union.cat(bedtool, postmerge=False)
    union = union.sort().merge()
    
    #union.saveas('union.bed')
    return union

# Function to find unique sets with a window
def find_unique_with_window(bed_file, other_bed_files, index, l=300, r=20000):
    bedtool = BedTool(bed_file)
    other_bedtools = [BedTool(bed_file) for bed_file in other_bed_files]
    unique = bedtool
    for other_bedtool in other_bedtools:
        unique = unique.window(b=other_bedtool, l=l, r=r, v=True)
    unique.saveas(f'unique_with_window_{index}.bed')
    return len(unique)

# # Paths to your BED files
# bed_files = ['file1.bed', 'file2.bed', 'file3.bed']

# # Finding the intersection of all BED files and counting intervals with a window
# intersection_count = find_intersection_with_window(bed_files, l=300, r=20000)
# print(f'Number of intervals in intersection with window: {intersection_count}')

# # Finding the union of all BED files and counting intervals
# union_count = find_union(bed_files)
# print(f'Number of intervals in union: {union_count}')

# # Finding unique sets for each file and counting intervals with a window
# for i, bed_file in enumerate(bed_files):
#     other_bed_files = [f for j, f in enumerate(bed_files) if j != i]
#     unique_count = find_unique_with_window(bed_file, other_bed_files, i + 1, l=300, r=20000)
#     print(f'Number of unique intervals in file {i+1} with window: {unique_count}')
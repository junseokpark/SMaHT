#!/bin/bash
# ref: https://github.com/tjiangHIT/cuteSV 


cuteSV <sorted.bam> <reference.fa> <output.vcf> <work_dir>

# > For PacBio CLR data:
# 	--max_cluster_bias_INS		100
# 	--diff_ratio_merging_INS	0.3
# 	--max_cluster_bias_DEL	200
# 	--diff_ratio_merging_DEL	0.5

# > For PacBio CCS(HIFI) data:
# 	--max_cluster_bias_INS		1000
# 	--diff_ratio_merging_INS	0.9
# 	--max_cluster_bias_DEL	1000
# 	--diff_ratio_merging_DEL	0.5

# > For ONT data:
# 	--max_cluster_bias_INS		100
# 	--diff_ratio_merging_INS	0.3
# 	--max_cluster_bias_DEL	100
# 	--diff_ratio_merging_DEL	0.3
# > For force calling:
# 	--min_mapq 			10
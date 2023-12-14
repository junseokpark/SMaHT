#!/bin/bash

# (3) Load Gold Standard VCF Files (6 Files)
# bcftools view -Oz -i 'ALT="<INS:ME:ALU>"' NA19240_lcl_SRR832874.wgs.COMPLETE_GENOMICS.20130401.snps_indels_svs_meis.high_coverage.genotypes.vcf.gz > NA19240_lcl_SRR832874.wgs.COMPLETE_GENOMICS.20130401.snps_indels_svs_meis.high_coverage.genotypes.ALU.vcf

# (4) Control VCF File (NA12878)
# bcftools view -s NA12878 -i 'ALT="<INS:ME:ALU>"' ALL.wgs.mergedSV.v8.20130502.svs.genotypes.GRCh38.vcf.gz -Oz | zcat | awk '$1 ~ /^#/ {print $0;next} {if ($10 == "0|1" ) print }' | bgzip > NA12878.vcf.gz
bcftools view -s NA12878 -i 'ALT="<INS:ME:LINE1>"' ALL.wgs.mergedSV.v8.20130502.svs.genotypes.GRCh38.vcf.gz -Oz | zcat | awk '$1 ~ /^#/ {print $0;next} {if ($10 == "0|1" ) print }' | bgzip > NA12878.LINE.vcf.gz

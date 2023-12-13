#!/bin/bash

# if bcftools is not install
# mamba install bcftools

# if bgzip is not?, install it
# pip install bgzip

SAMPLE_ID=NA12878

bcftools view -s $SAMPLE_ID -i 'ALT="<INS:ME:ALU>"' \
    ALL.wgs.mergedSV.v8.20130502.svs.genotypes.GRCh38.vcf.gz -Oz \
     | zcat | awk '$1 ~ /^#/ {print $0;next} {if ($10 == "0|1" ) print }' \
     | bgzip > $SAMPLE_ID.vcf.gz
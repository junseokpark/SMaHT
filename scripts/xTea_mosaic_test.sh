#!/bin/bash


BASE_DIRECTORY=/n/data1/bch/genetics/lee
REF_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/refs
WORK_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/results/xTea_mosaic

## omitted --fakeroot
singularity shell \
    -B /n/data1/bch/genetics/lee/:/n/data1/bch/genetics/lee/ \
    -B /n/scratch3/users/j/jp394/:/n/scratch3/users/j/jp394/ \
    -B /n/no_backup2/bch/lee/data/:/n/no_backup2/bch/lee/data/ \
    /n/app/singularity/containers/jp394/xtea-mosaic.sif

python /n/data1/bch/genetics/lee/tools/xTea-mosaic/gnrt_pipeline_local_v38.py \
         -M -U -i ../config/xtea_sample_id.txt \
         -b ../config/xtea_bam_list.txt \
         -x null \
         -p ${WORK_DIRECTORY}/ \
         -o submit_jobs.sh \
         -l ${REF_DIRECTORY}/rep_lib_annotation/ \
         -r ${REF_DIRECTORY}/hg38/Homo_sapiens_assembly38.fasta \
         -g ${REF_DIRECTORY}/pangenomics/chm13.draft_v2.0.gene_annotation.gff3 \
         --xtea ${BASE_DIRECTORY}/tools/xTea-mosaic/xtea/ \
         -f 5907 \
         -y 3 \
         --slurm -t 10-12:00 -q short -n 8 -m 96 \
         --nclip 2 --cr 0 --nd 1 --nfclip 1 --nfdisc 1 
        #  \
        #  --blacklist /home/germline_insertions.bed 

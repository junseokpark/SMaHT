#!/bin/bash


BASE_DIRECTORY=/n/data1/bch/genetics/lee
REF_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/refs
WORK_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/results/xTea_mosaic
CONFIG_DIRECTORY=${BASE_DIRECTORY}/projects/SMaHT/benchmark/toolTest_pipeline/config

## omitted --fakeroot
singularity shell \
    -B /n/data1/bch/genetics/lee/:/n/data1/bch/genetics/lee/ \
    -B /n/scratch3/users/j/jp394/:/n/scratch3/users/j/jp394/ \
    -B /n/no_backup2/bch/lee/data/:/n/no_backup2/bch/lee/data/ \
    /n/app/singularity/containers/jp394/xtea-mosaic.sif


## xTEA-germline


## xTEA-mosaic
python /n/data1/bch/genetics/lee/tools/xTea-mosaic/xtea/gnrt_pipeline_local_v38.py \
         -M -U -i ${CONFIG_DIRECTORY}/xtea_sample_id.txt \
         -b ${CONFIG_DIRECTORY}/xtea_bam_list.txt \
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
         --nclip 2 --cr 0 --nd 1 --nfclip 1 --nfdisc 1 \
         --blacklist ${REF_DIRECTORY}/gnomAD/2.1/gnomad_v2.1_sv.sites.bed
        #  \
        #  --blacklist /home/germline_insertions.bed 

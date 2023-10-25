#!/bin/bash

# junseok.park@childrens.harvard.edu
# ref: https://snakemake.readthedocs.io/en/stable/executing/cluster.html 

# load modules
module load snakemake/6.5.2

# set varialbles 
SLURM_account=jp394
SLURM_Partition=

# Run Snakemake 
snakemake --slurm --default-resources slurm_account=<your SLURM account> slurm_partition=<your SLURM partition> --set-resources <somerule>:slurm_partition=<some other partition>



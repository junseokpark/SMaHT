#!/bin/bash

# junseok.park@childrens.harvard.edu

# csubmitter is only for docker
module load csubmitter/latest

export PYTHONIOENCODING="utf-8"

# RetroSomV2 Test
#csubmitter --name RetroSomV2 --image-path /n/data1/bch/genetics/lee/jun/RetroSomV2/pipeline/RetroSomV2.5.sif

# xTEA-mosaic Test
csubmitter --name xTEA-mosaic --image-path /n/data1/bch/genetics/lee/tools/xTea-mosaic/xtea-mosaic.sif

#csubmitter --status
# singularity shell /n/data1/bch/genetics/lee/jun/RetroSomV2/pipeline/RetroSomV2.5.sif

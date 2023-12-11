#!/bin/bash

# Updating conda and conda-build
conda update conda
conda update conda-build

# Remove all unncessacery channels from .condarc
conda update -n base -c defaults conda


# https://github.com/conda-forge/miniforge
# mamba https://mamba.readthedocs.io/en/latest/installation/mamba-installation.html 
# https://github.com/mamba-org/mamba 

# Install miniforge

# Installing libmamba 
conda install -n base conda-libmamba-solver

mamba create --name cutesv python=3.10
conda activate cutesv
conda install -c conda-forge mamba
mamba install -c bioconda cutesv
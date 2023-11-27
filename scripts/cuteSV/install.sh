#!/bin/bash
# ref: https://github.com/tjiangHIT/cuteSV 

## prioritize 'conda-forge' channel
conda config --add channels conda-forge

## update existing packages to use 'conda-forge' channel
conda update -n base --all

## install 'mamba'
conda install -n base mamba

mamba create --name cuteSV python=3.8

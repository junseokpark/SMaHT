#!/bin/bash
# ref: https://github.com/tjiangHIT/cuteSV 

## prioritize 'conda-forge' channel
conda config --add channels conda-forge

## update existing packages to use 'conda-forge' channel
conda update -n base --all

## install 'mamba'
conda install -n base mamba


# # >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/username/--PATH--/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/username/--PATH--/etc/profile.d/conda.sh" ]; then
        . "/Users/username/--PATH--/etc/profile.d/conda.sh"
    else
        export PATH="/Users/username/--PATH--/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

mamba create --name cuteSV python=3.10
conda install -c conda-forge mamba




mamba install  -c bioconda sniffles==2.0.7 cuteSV==2.1.0 svjedi==1.1.6 truvari==3.5.0 samtools tabix
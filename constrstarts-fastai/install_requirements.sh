#!/usr/bin/env bash

# Python packages.
apt-get update
apt-get install -y software-properties-common --no-install-recommends
apt-get clean
rm -rf /var/lib/apt/lists/* 

# Updating conda.
conda update -n base -c defaults -y conda

# Activating fastai conda env and installing the required packages.
. activate fastai
conda update -y --all
pip install -r requirements.txt
conda install -c conda-forge rtree==0.9.4 gdal==3.1.0
pip install solaris==0.2.0 --ignore-installed PyYAML torchvision==0.5.0

# Removing unnecessary packages.
apt autoremove

# Removal due to security risk.
apt-get remove -y libxml2
rm -rf /notebooks

# Cloning a reference Git repo.
git clone --depth=1 https://github.com/daveluo/zanzibar-aerial-mapping.git

# python package installation script


conda update -n base -c defaults conda
. activate fastai && conda update -y fastai
. activate fastai && pip install -r requirements.txt
. activate fastai && conda install -c conda-forge rtree==0.9.4 gdal==3.1.0
. activate fastai && pip install solaris==0.2.0 --ignore-installed PyYAML torchvision==0.5.0

# due to ignore-installed, install packages separately
#. activate fastai && pip install solaris==0.2.0 --ignore-installed PyYAML torchvision==0.5.0
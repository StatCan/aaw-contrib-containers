

# python package installation script


# conda init bash && bash
#pip install fastai
#conda update -n base -c defaults conda
#. activate base && conda update -y fastai


. activate base && pip install -r requirements.txt
#. activate base && conda install -c conda-forge rtree==0.9.4 gdal==3.1.0
# !! install then: pip install solaris==0.2.0 --ignore-installed PyYAML torchvision==0.5.0

# due to ignore-installed, install packages separately
#. activate fastai && pip install solaris==0.2.0 --ignore-installed PyYAML torchvision==0.5.0
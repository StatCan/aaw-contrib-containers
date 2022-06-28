This folder contains all the necessary scripts, as well as any necessary input text files for this to run.


## Required Input .txt files
### Note that a `newline` is _required_ at the end of each text file.
They must also be `LF` files as `CRLF` has ruined me in the past

### 0-list-of-tags.txt
A file containing the tags we want to check for 
They must be newline separated and there _must be a newline at the end of the file_
The co-ordinate will use this and loop through this.
Example, if the file contents are
```
v1
v2

```
Then the scripts will be ran for both `v1` and `v2` tags, meaning that both `v1` and `v2` tags will be checked for and if nececssary restarted.

### 1-aaw-images.txt
This is a file containing images we want to grep for and keep.
They must be newline separated and there _must be a newline at the end of the file_
This is used in combination with `0-list-of-tags.txt` to generate the full name of the registry + repository + tag.
Example File
```
k8scc01covidacr.azurecr.io/rstudio
k8scc01covidacr.azurecr.io/jupyterlab-cpu
k8scc01covidacr.azurecr.io/jupyterlab-tensorflow
k8scc01covidacr.azurecr.io/jupyterlab-pytorch
k8scc01covidacr.azurecr.io/remote-desktop

```

## Generated Output .txt files

### Note
Some of these .txt files (notably the ones that are `>>`'d ) are `rm`'d at the beginning of each script.
This is to prevent when we have multiple tags in `0-list-of-tags.txt` from whacky funky overlap.
Naturally the `>` files are overwritten so those do not need to be `rm`'d

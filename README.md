# PAO1
PAO1 ML

## First step
Create a conda environment for unitig-caller
```
conda create -n uniting_caller
conda activate uniting_caller
```

For getting the unitig list run
```
unitig-caller --call --refs refs.txt --out out_prefix
```

So running into ARC
```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=32gb
#SBATCH --time=4:0:0
 
# Setting up the SCRATCH directory 
WORKDIR=`pwd`
SCRATCH=/scratch/$SLURM_JOBID
 
cd $SCRATCH
 
# Running unitig-caller inside the scratch
conda activate uniting_caller
unitig-caller --call --refs $WORKDIR/input.txt --out out_prefix
```

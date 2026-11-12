## Repository for Staph Biotyper data analysis

### *spafinder*
For *spa* identification of the *S.aureaus* genomes, [spaTyper](https://github.com/HCGB-IGTP/spaTyper) was installed using:

```
module load python3
pip install spaTyper
```

To download the repeats and spa-types, the Ridom spa Server was used:

```
# Download spa-types
wget https://spa.ridom.de/dynamic/spatypes.txt

# Download repeats
wget https://spa.ridom.de/dynamic/sparepeats.fasta
```

Running spa_typer

```
spaTyper [-r sparepeats.fasta] [-o spatypes.txt] [-f GENOMES.fasta] [--output OUTPUT]
```

### Bakta annotation
For genome annotation, we used `bakta` with apptainer and download the db-light database version 6
```
# Build the container from Docker
apptainer build bakta.sif docker://oschwengers/bakta

# Download bakta db-light DB
wget https://zenodo.org/records/14916843/files/db-light.tar.xz?download=1

# AMRFinder DB should be updated before running bakta
apptainer run bakta.sif amrfinder_update \
--force_update --database /home/franciscodaniel.davi/staph/db-light/amrfinderplus-db

# Running bakta
apptainer run bakta.sif bakta --db db-light/ --output annotation.test \
--genus Staphylococcus --species aureus --gram ? --threads 10 \
A516SA1531_30092020.fasta
```
### CAZyme annotation
For CAZyme annotation, `run_dbCAN` version 3 was used

```
# Download the environment.yml file from run_dbCAN Github and use it for creating the conda environment
conda create -f environment.yml

# Download the dbCAN DB
run_dbcan database --db_dir db --aws_s3

# Run CAZyme annotation using run_dbCAN
conda activate run_dbcan_env
run_dbcan CAZyme_annotation --mode protein --output_dir CAZ_annotation.out \
--input_raw_data A516SA1531_30092020.faa --db_dir ../db/ -v
```

### Distance matrix and visualization
The next step is to create a count matrix of all the CAZymes annotated in all genomes, then create a distance matrix using `vegan` in R (`Bray-Curtis`) and then perform hierarchical clustering using `Average linkage (UPGMA)`. The R script can be found in `Scripts/`

```
# Rename all the overview.tsv files output from dbCAN that contain the genome name and the same suffix 
mv overview.tsv A516SA1531_30092020.dbCAN.overview.tsv

# In R, create the Count matrix, distance matrix, and hierarchical clustering 
# Go to Scripts/DissMatrix_CAZyme.R

```














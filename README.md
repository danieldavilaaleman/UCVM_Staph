## Repository for Staph Biotyper data analysis

#### spafinder

#### bakta annotation
For genome annotation, we used `bakta` with apptainer and download the db-light database version 6

```
# Build the container from Docker
apptainer build bakta.sif docker://oschwengers/bakta

# Download bakta db-light DB
wget https://zenodo.org/records/14916843/files/db-light.tar.xz?download=1

# AMRFinder DB should be updated before running bakta
apptainer run bakta.sif amrfinder_update --force_update --database /home/franciscodaniel.davi/staph/db-light/amrfinderplus-db

# Running bakta
apptainer run bakta.sif bakta --db db-light/ --output annotation.test --genus Staphylococcus --species aureus --gram ? --threads 10 A516SA1531_30092020.fasta
```
#### CAZyme annotation

#### Distance matrix and visualization






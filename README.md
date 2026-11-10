## Repository for Staph Biotyper data analysis

#### spafinder

### bakta annotation
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
The next step is to create a count matrix of all the CAZymes annotated in all genomes, then create a distance matrix using `vegan` in R (`Bray-Curtis`) and then perform hierarchical clustering using `Average linkage (UPGMA)`

```
# Rename all the overview.tsv files output from dbCAN that contain the genome name and the same suffix 
mv overview.tsv A516SA1531_30092020.dbCAN.overview.tsv

# In R, read all the *.dbCAN.overview.tsv
# Set working directory
setwd("~/staph/annotation.test")

# Loading libraries
library(tidyverse)
library(vegan)

# Read the CAZyme count table concatenated from overview.tsv outputs from dbCAN
dbCAN_files <- list.files(path = ".", pattern = "*.dbCAN.overview.tsv", full.names = TRUE)

raw_data <- map_df(dbCAN_files, function(file) {
  sample_name <- basename(file) %>% str_remove(".dbCAN.overview.tsv") # Clean file name to get Sample ID
  read_tsv(file, col_names = TRUE) %>%   # Read text file
    mutate(Sample = sample_name)
})

# Format DF to keep only Genomes and CAZymes
raw_data <- raw_data[,c(1,7,9)] 
colnames(raw_data) <- c("Gene_ID", "CAZyme", "Genome")

# Create the wide matrix with row as genome species and columns as CAZymes
CAZy_matrix <- raw_data %>%
  filter(CAZyme != "-") %>%
  count(Genome, CAZyme) %>%
    pivot_wider(
    id_cols     = Genome,
    names_from  = CAZyme,
    values_from = n,
    values_fill = 0
  )

# Format rownames and remove GEnome column
CAZy_matrix <- as.data.frame(CAZy_matrix)
rownames(CAZy_matrix) <- CAZy_matrix$Genome
CAZy_matrix <- CAZy_matrix[,-1]

# Create distant matrix
dist <- vegdist(CAZy_matrix, method = "bray")


```














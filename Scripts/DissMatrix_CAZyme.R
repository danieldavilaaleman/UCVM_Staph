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

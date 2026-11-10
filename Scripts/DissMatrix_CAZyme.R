# ==========================================
# SET WORKING DIRECTORY
# ==========================================
setwd("~/staph/annotation.test")

# ==========================================
# LOADING LIBRARIES
# ==========================================
library(tidyverse)
library(vegan)
library(pheatmap)

# ==========================================
# READ DBCAN OUTPUT FILES
# ==========================================
dbCAN_files <- list.files(path = ".", pattern = "*.dbCAN.overview.tsv", full.names = TRUE)

raw_data <- map_df(dbCAN_files, function(file) {
  sample_name <- basename(file) %>% str_remove(".dbCAN.overview.tsv") # Clean file name to get Sample ID
  read_tsv(file, col_names = TRUE) %>%   # Read text file
    mutate(Sample = sample_name)
})

# ==========================================
# FORMAT DF FRO DISSIMILARITY CALCULATION
# ==========================================
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

# ==========================================
# CREATE DISTANCE MATRIX
# ==========================================
dist <- vegdist(CAZy_matrix, method = "bray")

# ==========================================
# NMDS FROM DISTANCE MATRIX
# ==========================================
nmds <- metaMDS(dist)

scores(nmds) %>%
  as_tibble(rownames = "Genomes") %>%
  ggplot(aes(x = NMDS1, y = NMDS2, color = Genomes)) +
  geom_point()

# ==========================================
# PLOT DENDROGRAM
# ==========================================
clustering <- hclust(dist, method = "average")
plot(clustering)


# ==========================================
# DISTANCE MATRIX METRICS FOR PHEATMAP
# ==========================================

# Calculate Bray-Curtis distance matrix for samples
sample_dist <- vegdist(CAZy_matrix, method = "bray")

# Calculate Bray-Curtis distance matrix for CAZymes (transpose the matrix)
cazyme_dist <- vegdist(t(CAZy_matrix), method = "bray")


# ==========================================
# PLOT CLUSTER HEATMAP & DENDROGRAM
# ==========================================

pheatmap(
  CAZy_matrix,
  clustering_distance_rows = sample_dist,  # Attaches dendrogram for your samples
  clustering_distance_cols = cazyme_dist,  # Attaches dendrogram for your CAZyme families
  clustering_method = "average",           # UPGMA linkage (standard for Bray-Curtis)
  scale = "column",                        # Z-score normalize columns so dominant families don't mask rare ones
  color = colorRampPalette(c("navy", "white", "firebrick3"))(100),
  main = "Hierarchical Clustering of dbCAN CAZyme Profiles",
  fontsize_row = 10,
  fontsize_col = 8
)



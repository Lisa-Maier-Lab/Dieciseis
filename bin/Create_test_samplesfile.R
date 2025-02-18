# Create samples file for test
library(tidyverse)

# Files directory
Files_dir = "/mnt/volume_1/dm_main/projects/Dieciseis/test/novaseqs/"

# List fastq files
Files = Files_dir %>% 
  list.files(full.names = TRUE, pattern = "fastq")

# Separate F and R
F_files = Files %>% 
  str_subset("R1")

R_files = Files %>% 
  str_subset("R2")

# Create df
Example_df = data.frame(forward = F_files, reverse = R_files) %>% 
  mutate(samplename = basename(forward),
         samplename = str_remove(samplename, "_R1.*")) %>% 
  relocate(samplename)

# Write
Example_df %>% 
  write_tsv("/mnt/volume_main_2/dm_main/projects/Dieciseis/test/novaseq_samplesfile.tsv")
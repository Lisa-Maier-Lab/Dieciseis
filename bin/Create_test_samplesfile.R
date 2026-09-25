# Create samples file for test
library(tidyverse)

# Files directory
Files_dir = "/PATH/TO/Dieciseis/test/seqs/"

# List fastq files
Files = Files_dir |> 
  list.files(full.names = FALSE, pattern = "fastq")

# Separate F and R
F_files = Files |> 
  str_subset("R1_001")

R_files = Files |> 
  str_subset("R2_001")

# Create df
Example_df = data.frame(forward = F_files, reverse = R_files) |> 
  mutate(samplename = basename(forward),
         samplename = str_remove(samplename, "_R1.*")) |> 
  relocate(samplename)

# Write
Example_df |> 
  write_tsv("/PATH/TO/Dieciseis/test/test_samplesfile.tsv")

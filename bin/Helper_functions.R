# Prompt
# This function prompts the user to fill fields that have to be specified
Check_point = function(Message){
  Variables_set = askYesNo(msg = Message)
  stopifnot("Make sure the fields are filled!" = isTRUE(Variables_set))
}

# Determine whether sequences have binned error values
# Adapted from https://github.com/benjjneb/dada2/issues/2081#issue-2851091740
QualityBinValue = function(fnFs, fnRs) {
  
  # Initialize lists to store unique quality scores
  unique_qF_list = list()
  unique_qR_list = list()
  
  # Loop through all FASTQ files
  for (i in seq_along(fnFs)) {
    # Read forward and reverse FASTQ files
    fqF = ShortRead::readFastq(fnFs[i])
    fqR = ShortRead::readFastq(fnRs[i])
    
    # Extract quality scores
    qF = sort(as.vector(as(quality(fqF), "matrix")))
    qR = sort(as.vector(as(quality(fqR), "matrix")))
    
    # Get unique quality scores
    unique_qF = unique(qF)
    unique_qR = unique(qR)
    
    # Store in lists
    unique_qF_list[[basename(fnFs[i])]] = unique_qF
    unique_qR_list[[basename(fnRs[i])]] = unique_qR
    
    message("Processed: ", basename(fnFs[i]), " and ", basename(fnRs[i]))
  }
  
  # Return unique quality scores as a list
  return(list(forward = unique_qF_list, reverse = unique_qR_list))
}
# Dieciseis

Jacobo de la Cuesta-Zuluaga. December 2023.

`Dieciseis` is the workflow for the analysis of 16S rRNA gene amplicons of
the Maier lab. It implements the standard `DADA2` workflow described 
[here](https://benjjneb.github.io/dada2/tutorial_1_8.html)

## Usage

You can find the code in the `notebooks` folder. The workflow is divided in
two sections: `01_Execute_dada2` covers the cleaning of raw sequences, the 
identification of amplicon sequence variants (ASVs) and their general taxonomic
classification. The second notebook, `02_synth_Com_taxonomy` is only required
if you are processing samples from synthetic communities with defined members; 
it uses the full-length 16S rRNA gene sequences from reference genomes references
to classify ASVs belonging to each member of the community and collapse the
abundances according to the taxonomic classification by species.

## Taxonomic classification files

The present workflow uses the _SBDI Sativa curated 16S GTDB database_ available
[here](https://doi.org/10.17044/scilifelab.14869077). This database is published
under the [CC by 4.0 license](https://creativecommons.org/licenses/by/4.0/), 
which allows to copy, redistribute and transform the material. The complete database
and custom databases derived from are found in the `reference_files` folder.


## Dependencies

`Dieciseis` depends on the following libraries:

### Cran libraries

    tidyverse
    ape
    phangorn
    digest
    conflicted

### Bioconductor libraries

    dada2
    DECIPHER
    Biostrings

## Why `Dieciseis`?

Just because it means sixteen in Spanish and I wasn't feeling particularly 
creative that day. I would call it `hexadecagon` but I can't be bothered to
change the name now.

## Changes and updates

### Februrary 2025

In this updated version of the notebook, I have made changes to reflect our change
of sequencing provider. The lab is now using the services of a sequencing facility
that uses the V3-V4 region of the 16S rRNA gene, and a newer sequencing platform
that changes the way the error profiles are stored in the `fastq` files. This
so-called "binned" error profiles alter the way `DADA2` deals with the sequences
and thus require some adjustments on the code.

I have added a few steps where you, the user, need to specify what kind of 
sequences are using, that is, the new binned errors or the older linear errors. 
This way, the notebook will be usable regardless of the sequencing you have. 
*Note* that if you have reads using two different profiles, you will need to
process them separately!

Other changes: 

* I added a filtering step to remove ASVs that have no classification at the 
phylum level, you can find an explanation below.

* I moved the generation of the ASV phylogeny to an optional section at the end
of the notebook.

* Changed the function used to calculate the distances between ASV and ref sequences.
Old notebook used the `ape` package, currently using `DECIPHER`.

# Changelog
## Notes and updates

### September 2026

We have been using multiple sequencing providers, which have now migrated to the
new binned error profiles and which use different regions of the hypervariable
region. Therefore, I separated the error profile selection from the hypervariable
region selection, and made it provider agnostic, so that the user specifies the 
type of error profile (i.e. linear, binned), not from which facility the sequencing
was obtained. I also fixed a small bug in the execution of the learning errors section.

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
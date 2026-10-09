#!/bin/sh
#conda activate ncbi_datasets_v_18_33_1
## datasets version: 18.33.1
cd /nfs/turbo/umms-esnitkin/Project_MERLIN/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/data/public_genomes/species

datasets download genome taxon "full_name" --assembly-source genbank --assembly-level complete,chromosome --dehydrated --filename species_dehydrated.zip --no-progressbar
dataformat tsv genome   --package species_dehydrated.zip --fields accession,assminfo-level,assminfo-biosample-accession,assminfo-biosample-bioproject-accession,assminfo-biosample-collection-date,assminfo-biosample-geo-loc-name,assminfo-biosample-isolation-source,assminfo-biosample-host,assminfo-sequencing-tech,assminfo-assembly-method,assmstats-number-of-contigs,assmstats-contig-n50,assmstats-total-sequence-len > NCBI_Genbank_species_metadata_072126.tsv


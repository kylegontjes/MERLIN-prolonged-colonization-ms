
# Cognac Run
# Start Date: 07/02/25
# Population: klebsiella isolates
# Activate
library(tidyverse)
library(cognac)
Sys.info()
sessionInfo()
set.seed(45)

setwd('/nfs/turbo/umms-esnitkin/Project_MERLIN/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/')

outDir = '/nfs/turbo/umms-esnitkin/Project_MERLIN/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/data/cognac/klebsiella/'

genomic_id = readRDS('./scripts/cognac/scripts/klebsiella/klebsiella_isolate_list.RDS')  
fasta_files = readRDS('./scripts/cognac/scripts/klebsiella/klebsiella_genomes_path.RDS')
gff_files =  readRDS('./scripts/cognac/scripts/klebsiella/klebsiella_annotations_path.RDS')

# Run Conac requiring at least 500 genes are included in the alignment 
cognac(
  fastaFiles = fasta_files ,
  featureFiles = gff_files,
  outDir        = outDir,
  minGeneNum    = 500,
  maxMissGenes  = 0.05, 
  njTree     = FALSE,
  mapNtToAa = TRUE,
  keepTempFiles = TRUE
)
 

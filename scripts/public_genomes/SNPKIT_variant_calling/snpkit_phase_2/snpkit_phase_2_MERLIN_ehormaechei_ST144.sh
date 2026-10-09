# Run snpkit phase 2 using the parse steps
python /nfs/turbo/umms-esnitkin/Project_MERLIN/Sequence_data/variant_calling/snpkit/snpkit.py \
-type PE \
-readsdir /scratch/kgontjes_root/kgontjes0/kgontjes/Project_MERLIN/Sequence_data/variant_calling/fastq \
-outdir  /scratch/kgontjes_root/kgontjes0/kgontjes/Project_MERLIN/Sequence_data/variant_calling/2026-08-26_snpkit_MERLIN_ehormaechei_ST144/output_files \
-analysis 2026-08-26_snpkit_MERLIN_ehormaechei_ST144_2 \
-index CM136160 \
-steps parse \
-cluster cluster \
-scheduler SLURM \
-gubbins yes \
-mask \
-filenames /nfs/turbo/umms-esnitkin/Project_MERLIN/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/scripts/public_genomes/SNPKIT_variant_calling/isolate_lists/MERLIN_ehormaechei_ST144_files.txt

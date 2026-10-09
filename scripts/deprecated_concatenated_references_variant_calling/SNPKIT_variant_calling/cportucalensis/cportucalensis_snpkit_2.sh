conda activate /nfs/turbo/umms-esnitkin/conda/snpkit/

# run this in a interactive node
python /nfs/turbo/umms-esnitkin/Project_MERLIN/Sequence_data/variant_calling/snpkit/snpkit.py  \
-type PE \
-readsdir /scratch/esnitkin_root/esnitkin1/kgontjes/Project_MERLIN/Sequence_data/variant_calling/fastq \
-outdir  /scratch/esnitkin_root/esnitkin1/kgontjes/Project_MERLIN/Sequence_data/variant_calling/2025-04-15_SNPKIT/cportucalensis/output_files \
-analysis 2025-04-15_cportucalensis_2  \
-index MERLIN_34_reference \
-steps parse \
-cluster cluster \
-scheduler SLURM \
-gubbins yes \
-mask \
-filenames /nfs/turbo/umms-esnitkin/Project_MERLIN/Sequence_data/variant_calling/2025-04-15_SNPKIT/cportucalensis/cportucalensis_samples.txt  \
-dryrun
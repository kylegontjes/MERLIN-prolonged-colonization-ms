conda activate /nfs/turbo/umms-esnitkin/conda/snpkit/

python /nfs/turbo/umms-esnitkin/Project_MERLIN/Sequence_data/variant_calling/snpkit/snpkit.py \
-type PE \
-readsdir /scratch/esnitkin_root/esnitkin1/kgontjes/Project_MERLIN/Sequence_data/variant_calling/fastq \
-outdir /scratch/esnitkin_root/esnitkin1/kgontjes/Project_MERLIN/Sequence_data/variant_calling/2025-04-15_SNPKIT/cfreundii/output_files \
-analysis 2025-04-15_cfreundii_1 \
-index MERLIN_280_reference \
-steps call \
-cluster cluster \
-scheduler SLURM \
-clean \
-filenames /nfs/turbo/umms-esnitkin/Project_MERLIN/Sequence_data/variant_calling/2025-04-15_SNPKIT/cfreundii/cfreundii_samples.txt \
-dryrun
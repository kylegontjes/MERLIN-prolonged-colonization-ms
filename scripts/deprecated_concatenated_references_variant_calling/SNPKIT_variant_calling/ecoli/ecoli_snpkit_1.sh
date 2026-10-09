conda activate /nfs/turbo/umms-esnitkin/conda/snpkit/

python /nfs/turbo/umms-esnitkin/Project_MERLIN/Sequence_data/variant_calling/snpkit/snpkit.py \
-type PE \
-readsdir /scratch/esnitkin_root/esnitkin1/kgontjes/Project_MERLIN/Sequence_data/variant_calling/fastq \
-outdir /scratch/esnitkin_root/esnitkin1/kgontjes/Project_MERLIN/Sequence_data/variant_calling/2025-04-15_SNPKIT/ecoli/output_files \
-analysis 2025-04-15_ecoli_1 \
-index Ecoli_NCTC13441_chromosome \
-steps call \
-cluster cluster \
-scheduler SLURM \
-clean \
-filenames /nfs/turbo/umms-esnitkin/Project_MERLIN/Sequence_data/variant_calling/2025-04-15_SNPKIT/ecoli/ecoli_samples.txt \
-dryrun
#!/bin/sh
# Job name
#SBATCH --job-name=submit_MERLIN_SNPKIT_species_ST_phase_2
# User info
#SBATCH --mail-user=kgontjes@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --export=ALL
#SBATCH --partition=standard
#SBATCH --account=esnitkin1
#SBATCH --output=/nfs/turbo/umms-esnitkin/Project_MERLIN/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/slurm_out/public_genomes/SNPKIT/phase_2_submission/submit_SNPKIT_phase_2_jobs.out
#SBATCH --nodes=1  --ntasks=1 --cpus-per-task=1 --mem=20g --time=2:00:00

# Get log directory
logs_dir="/nfs/turbo/umms-esnitkin/Project_MERLIN/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/slurm_out/public_genomes/SNPKIT/phase_2_submission"
mkdir -p "$logs_dir"

# Move into slurm output directory (to direct slurm jobs to it!)
cd /nfs/turbo/umms-esnitkin/Project_MERLIN/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/slurm_out/public_genomes/SNPKIT/phase_2_jobs

# Set encoding environment variables
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PYTHONIOENCODING=utf-8
export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"

# Run script
for script in /nfs/turbo/umms-esnitkin/Project_MERLIN/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/scripts/public_genomes/SNPKIT_variant_calling/snpkit_phase_2/*.sh; do
  analysis=$(basename "$script" .sh)
  echo "Submitting: $analysis"
  bash "$script" > "${logs_dir}/${analysis}_submission.log" 2>&1
  sleep 15
done

echo "All jobs submitted"

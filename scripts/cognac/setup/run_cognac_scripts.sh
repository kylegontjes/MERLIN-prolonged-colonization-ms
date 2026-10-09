#!/bin/sh

for dir in /nfs/turbo/umms-esnitkin/Project_MERLIN/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/scripts/cognac/scripts/*; do
  group=$(basename "$dir")
  echo "$group"

  script="${dir}/cognac_${group}_index_cases.sbat"
  sbatch "$script"
done


#!/bin/sh

for dir in /nfs/turbo/umms-esnitkin/Project_MERLIN/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/scripts/cognac/scripts/*; do
  group=$(basename "$dir")
  echo "$group"

  script="${dir}/MERLIN_${group}_index_cases_IQTREE2.sbat" 
  
  if [ -f "$script" ]; then
    echo "Submitting $script"
    sbatch "$script"
  else
    echo "No script exists (likely due to no need to run the command)"
  fi
  
done


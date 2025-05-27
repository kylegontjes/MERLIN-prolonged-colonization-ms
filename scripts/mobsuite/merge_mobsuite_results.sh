#!/bin/sh
cd /nfs/turbo/umms-esnitkin/Project_MERLIN/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/data/mobsuite

awk '(NR==1)' ./MERLIN_12/mobtyper_results.txt > MERLIN_mobtyper_results.txt

for isolate in $(ls -d */ | cut -d/ -f1)
do 
        echo $isolate
        awk '(NR>1)' ./$isolate/mobtyper_results.txt  >> MERLIN_mobtyper_results.txt

done

awk '(NR==1)' ./MERLIN_12/contig_report.txt > MERLIN_contig_report.txt

for isolate in $(ls -d */ | cut -d/ -f1)
do
        echo $isolate
        awk '(NR>1)' ./$isolate/contig_report.txt >> MERLIN_contig_report.txt
done
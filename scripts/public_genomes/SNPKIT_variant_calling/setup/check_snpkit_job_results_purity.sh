#!/bin/bash

for run_dir in *snpkit*/; do
    run_name="${run_dir%/}"
    mapfile -t merlin_dirs < <(find "${run_dir}output_files" -maxdepth 1 -type d -name "MERLIN_*" 2>/dev/null -printf "%f\n")
    merlin_count=${#merlin_dirs[@]}
    fa_file=$(find "${run_dir}output_files" -path "*/gubbins/*_genome_aln_w_alt_allele_unmapped.fa" 2>/dev/null | head -1)
    if [[ -n "$fa_file" ]]; then
        assembly_count=$(grep -c "^>" "$fa_file")
        missing=()
        for dir in "${merlin_dirs[@]}"; do
            if ! grep -qF "$dir" "$fa_file"; then
                missing+=("$dir")
            fi
        done
        ref_present=$(grep "^>" "$fa_file" | grep -v "MERLIN" | wc -l)
    else
        assembly_count="FA_NOT_FOUND"
        missing=("FA_NOT_FOUND")
        ref_present=0
    fi
    echo "${run_name}: MERLIN_dirs=${merlin_count}, assemblies=${assembly_count}"
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "  Missing MERLIN isolates: ${missing[*]}"
    fi
    if [[ "$ref_present" -eq 0 ]]; then
        echo "  WARNING: Reference genome missing from assembly"
    fi

    # File count: look inside MERLIN_X/MERLIN_X_vcf_results/
    declare -A vcf_counts
    for dir in "${merlin_dirs[@]}"; do
        vcf_counts["$dir"]=$(find "${run_dir}output_files/${dir}/${dir}_vcf_results" -maxdepth 1 -type f 2>/dev/null | wc -l)
    done
    modal_count=$(for v in "${vcf_counts[@]}"; do echo "$v"; done \
        | sort | uniq -c | sort -rn | awk 'NR==1{print $2}')

    if [[ -n "$modal_count" ]]; then
        vcf_outliers=()
        for dir in "${merlin_dirs[@]}"; do
            count="${vcf_counts[$dir]:-0}"
            if [[ "$count" -ne "$modal_count" ]]; then
                vcf_outliers+=("${dir}=${count}")
            fi
        done
        if [[ ${#vcf_outliers[@]} -gt 0 ]]; then
            echo "  File counts: outliers found (expected=${modal_count}): ${vcf_outliers[*]}"
        else
            echo "  File counts: all isolates have ${modal_count} files"
        fi
    else
        echo "  File counts: no files found in MERLIN dirs"
    fi

    unset vcf_counts
    declare -A vcf_counts
done

2026-08-26_snpkit_MERLIN_cfreundii_all: MERLIN_dirs=6, assemblies=7
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_cfreundii_ST185: MERLIN_dirs=2, assemblies=3
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_cfreundii_ST251: MERLIN_dirs=2, assemblies=3
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_cportucalensis_all: MERLIN_dirs=3, assemblies=4
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_cportucalensis_ST_Unknown: MERLIN_dirs=2, assemblies=3
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ecoli_all: MERLIN_dirs=101, assemblies=102
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ecoli_ST1193: MERLIN_dirs=9, assemblies=10
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ecoli_ST131: MERLIN_dirs=57, assemblies=58
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ecoli_ST372: MERLIN_dirs=2, assemblies=3
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ecoli_ST38: MERLIN_dirs=7, assemblies=8
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ecoli_ST4118: MERLIN_dirs=4, assemblies=5
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ecoli_ST607: MERLIN_dirs=4, assemblies=5
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ecoli_ST6321: MERLIN_dirs=2, assemblies=3
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ecoli_ST648: MERLIN_dirs=2, assemblies=3
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ecoli_ST69: MERLIN_dirs=2, assemblies=3
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ecoli_ST744: MERLIN_dirs=3, assemblies=4
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ehormaechei_all: MERLIN_dirs=24, assemblies=25
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ehormaechei_ST114: MERLIN_dirs=4, assemblies=5
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ehormaechei_ST144: MERLIN_dirs=4, assemblies=5
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ehormaechei_ST45: MERLIN_dirs=7, assemblies=8
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_ehormaechei_ST78: MERLIN_dirs=4, assemblies=5
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_eludwigii_all: MERLIN_dirs=3, assemblies=4
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_eludwigii_ST1287: MERLIN_dirs=2, assemblies=3
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_kpneumoniae_all: MERLIN_dirs=24, assemblies=25
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_kpneumoniae_ST15: MERLIN_dirs=7, assemblies=8
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_kpneumoniae_ST29: MERLIN_dirs=4, assemblies=5
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_kpneumoniae_ST323: MERLIN_dirs=3, assemblies=4
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_kpneumoniae_ST45: MERLIN_dirs=4, assemblies=5
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_sliquefaciens_all: MERLIN_dirs=3, assemblies=4
  File counts: all isolates have 62 files
2026-08-26_snpkit_MERLIN_sliquefaciens_ST_Unknown: MERLIN_dirs=3, assemblies=4
  File counts: all isolates have 62 files

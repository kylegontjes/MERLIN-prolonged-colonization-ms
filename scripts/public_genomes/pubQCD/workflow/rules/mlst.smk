rule mlst:
    input:
        spades_l1000_assembly = "results/{prefix}/spades/{sample}/{sample}_contigs_l1000.fasta",
    output:
        mlst_report = "results/{prefix}/mlst/{sample}/report.tsv",
    params: 
        outdir = "results/{prefix}/mlst/{sample}/",
        prefix = "{sample}",
    threads: 1
    resources:
        mem_mb=4000,
        runtime=30
    #conda:
    #    "envs/mlst.yaml"
    singularity:
        "docker://staphb/mlst:2.23.0-2024-03"
    benchmark: 
        "benchmarks/{prefix}/mlst/{sample}.benchmark.tsv"
    #envmodules:
    #    "Bioinformatics",
    #    "mlst"
    shell:
        "mlst {input.spades_l1000_assembly} > {output.mlst_report}"
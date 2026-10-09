rule prokka:
    input:
        spades_l1000_assembly ="results/{prefix}/spades/{sample}/{sample}_contigs_l1000.fasta",
    output:
        prokka_gff = "results/{prefix}/prokka/{sample}/{sample}.gff",
    params: 
        prokka_params = config["prokka"],
        outdir = "results/{prefix}/prokka/{sample}",
        prefix = "{sample}",
    threads: 8
    resources:
        mem_mb=8000,
        runtime=45
    #conda:
    #    "envs/prokka.yaml"
    singularity:
        "docker://staphb/prokka:1.14.6"    
    benchmark: 
        "benchmarks/{prefix}/prokka/{sample}.benchmark.tsv"
    #envmodules:
    #    "Bioinformatics",
    #    "prokka"
    shell:
        "prokka -outdir {params.outdir} --strain {params.prefix} --prefix {params.prefix} {params.prokka_params} {input.spades_l1000_assembly}"

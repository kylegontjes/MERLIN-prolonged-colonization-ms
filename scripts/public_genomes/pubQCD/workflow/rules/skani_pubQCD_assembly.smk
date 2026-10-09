rule skani:
    input:
        spades_contigs_file = lambda wildcards: f"{config['assembly']}/{wildcards.sample}.{config['read_extension']}"
    output:
        skani_output = "results/{prefix}/skani/{sample}/{sample}_skani_output.txt"
    params:
        skani_ani_db = config["skani_db"],
        threads = 4
    threads: 4
    resources:
        mem_mb=8000,
        runtime=60
    benchmark: 
        "benchmarks/{prefix}/skani/{sample}.benchmark.tsv"
    #conda:
    #    "envs/skani.yaml"
    singularity:
        "docker://staphb/skani:0.2.1"
    shell:
        "skani search {input.spades_contigs_file} -d {params.skani_ani_db} -o {output.skani_output} -t {params.threads}"

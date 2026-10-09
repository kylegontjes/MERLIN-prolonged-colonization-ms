rule busco:
    input:
        spades_l1000_assembly = "results/{prefix}/spades/{sample}/{sample}_contigs_l1000.fasta",
    output:
        busco_out = "results/{prefix}/busco/{sample}/{sample}_busco_out.txt",
    params: 
        outdir = "results/{prefix}/busco/{sample}/",
        prefix = "{sample}",
        assembly_busco_out = "short_summary.specific.bacteria_odb12.{sample}.txt"
    threads: 8
    resources:
        mem_mb=16000,
        runtime=120
    #conda:
    #    "envs/busco.yaml"
    singularity:
        "docker://staphb/busco:6.0.0-prok-bacteria_odb12_2024-11-14"
    benchmark: 
        "benchmarks/{prefix}/busco/{sample}.benchmark.tsv"
    #envmodules:
    #    "Bioinformatics",
    #    "busco"
    shell:
        """
        busco -f -i {input.spades_l1000_assembly} -m genome -l bacteria_odb12 -o {params.outdir}
        cp {params.outdir}/{params.assembly_busco_out} {params.outdir}/{params.prefix}_busco_out.txt
        """

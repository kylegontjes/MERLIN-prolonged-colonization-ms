rule quast:
    input:
        spades_l1000_assembly = "results/{prefix}/spades/{sample}/{sample}_contigs_l1000.fasta",
    output:
        quast_report = "results/{prefix}/quast/{sample}/report.tsv",
    params: 
        outdir = "results/{prefix}/quast/{sample}/",
        prefix = "{sample}",
    #conda:
    #    "envs/quast.yaml"
    singularity:
        "docker://staphb/quast:5.0.2"
    threads: 4
    resources:
        mem_mb=8000,
        runtime=60
    #envmodules:
    #    "Bioinformatics",
    #    "quast"
    benchmark: 
        "benchmarks/{prefix}/quast/{sample}.benchmark.tsv"
    shell:
        """
        workflow/scripts/quast.sh {input.spades_l1000_assembly} {params.outdir} 
        """
        #"quast.py {input.spades_l1000_assembly} -o {params.outdir} --contig-thresholds 0,1000,5000,10000,25000,50000"

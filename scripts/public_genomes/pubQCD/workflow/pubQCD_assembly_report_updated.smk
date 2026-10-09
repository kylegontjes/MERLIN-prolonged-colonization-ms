# Author: Ali Pirani and Dhatri Badri  
#configfile: "config/config_assembly.yaml"

import pandas as pd
import os
import json
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import re

PREFIX = config["prefix"]

samples_df = pd.read_csv(config["samples"])
SAMPLE = list(samples_df['sample_id'])

# if not os.path.exists("results/" + PREFIX):
    # os.system("mkdir %s" % "results/" + PREFIX)

# Organize reports directory
prefix = PREFIX
outdir = "results/%s" % prefix
report_dir = outdir + "/%s_Report" % prefix
report_script_dir = report_dir + "/scripts"
report_data_dir = report_dir + "/data"
report_multiqc_dir = report_dir + "/multiqc"
report_fig_dir = report_dir + "/fig"

isExist = os.path.exists(report_dir)
if not isExist:
    os.makedirs(report_dir)

isExist = os.path.exists(report_script_dir)
if not isExist:
    os.makedirs(report_script_dir)

isExist = os.path.exists(report_data_dir)
if not isExist:
    os.makedirs(report_data_dir)

isExist = os.path.exists(report_multiqc_dir)
if not isExist:
    os.makedirs(report_multiqc_dir)

isExist = os.path.exists(report_fig_dir)
if not isExist:
    os.makedirs(report_fig_dir)

def skani_report(outdir, prefix):
    prefix = prefix.pop()
    outdir = "results/%s" % prefix
    report_dir = str(outdir) + "/%s_Report" % prefix
    report_data_dir = report_dir + "/data"
    result_df = pd.DataFrame(columns=['Sample', 'ANI', 'Align_fraction_ref', 'Align_fraction_query', 'Ref_name', 'Species'])  # Add 'Species' column

    skani_dir = os.path.join(outdir, 'skani')  # Navigate to skani directory

    for sample_name in os.listdir(skani_dir):  # Iterate over samples in the results/prefix/skani directory
        sample_dir = os.path.join(skani_dir, sample_name)

        if os.path.isdir(sample_dir):  # Check if it's a directory
            skani_file_path = os.path.join(sample_dir, f'{sample_name}_skani_output.txt')  # Look for the skani output file

            if os.path.exists(skani_file_path):  # Check if the skani file exists
                skani_file = pd.read_csv(skani_file_path, sep='\t| ,', skipinitialspace=True, header=0)  # Read the skani file
                first_row_df = skani_file[['ANI', 'Align_fraction_ref', 'Align_fraction_query', 'Ref_name']].iloc[:1]  # Extract the first row

                if first_row_df.empty:  # Check if the first row is empty
                    first_row_df = pd.DataFrame({
                        'Sample': [sample_name],  # Add sample name
                        'ANI': ["NA"],
                        'Align_fraction_ref': ["NA"],
                        'Align_fraction_query': ["NA"],
                        'Ref_name': ["NA"],
                        'Species': ["NA"]  # Add NAs for Species
                    })
                else:
                    first_row_df.loc[:, 'Sample'] = sample_name  # Add sample name
                    # Extract species using regex from Ref_name
                    first_row_df.loc[:, 'Species'] = first_row_df['Ref_name'].apply(
                        lambda x: re.search(r"[A-Za-z]+\s[A-Za-z]+", x).group(0) if pd.notnull(x) and re.search(r"[A-Za-z]+\s[A-Za-z]+", x) else "NAs"
                    )

                first_row_df = first_row_df[['Sample', 'ANI', 'Align_fraction_ref', 'Align_fraction_query', 'Ref_name', 'Species']]  # Reorder columns
                result_df = pd.concat([result_df, first_row_df], ignore_index=True)  # Concatenate to the result dataframe

    result_file_path = os.path.join(report_data_dir, f'{prefix}_Skani_report_final.csv')  # Save final result to CSV
    result_df.to_csv(result_file_path, index=False)

def summary(prefix, outdir, skani_genome_size, input, params):
    prefix = prefix
    outdir = outdir[0]
    
    #Organize reports directory
    report_dir = str(outdir) + "/%s_Report" % prefix
    report_script_dir = str(outdir) + "/%s_Report/scripts" % prefix

    # Step 1. Load the MLST results  
    mlst = pd.read_csv("results/%s/%s_Report/data/%s_MLST_results.csv" % (prefix, prefix, prefix), sep='\t', header=0)
    mlst['Sample'] = mlst['Sample'].replace(r'.*/spades/(.*?)/.*', r'\1', regex=True)

    # Step 2. Load the Quast results
    quast_rows = []
    for quast_path in input.quast_reports:
        sample = quast_path.split("/")[-2]
        df = pd.read_csv(quast_path, sep="\t", header=0, index_col=0) # metric names become index
        quast_rows.append({
            "Sample":               sample,
            "Total length":         df.loc["Total length", df.columns[0]]         if "Total length"         in df.index else None,
            "Total # of contigs":  df.loc["# contigs (>= 0 bp)", df.columns[0]] if "# contigs (>= 0 bp)"  in df.index else None,
            "N50":                  df.loc["N50", df.columns[0]]                  if "N50"                  in df.index else None,
            })

    quast_summary = pd.DataFrame(quast_rows)

    ## Step 3. Load the skani results
    skani_summary = pd.read_csv("results/%s/%s_Report/data/%s_Skani_report_final.csv" % (prefix, prefix, prefix), sep=',', skipinitialspace=True, header=0, engine='python')
    ### Read in skani species genome size table and merge
    skani_genome_table = pd.read_csv(skani_genome_size)
    skani_summary = skani_summary.merge(skani_genome_table, on="Species", how="left") 

    ## Step 4. Merge the files
    QC_summary_temp1 = pd.merge(mlst, quast_summary, on=["Sample", "Sample"], how='left')
    qc = pd.merge(QC_summary_temp1, skani_summary, on=["Sample", "Sample"], how='left') 

    ### Check assembly length
    def check_assembly_length(total_length, assembly_length):
        if pd.isnull(total_length):
            return 'FAIL'
        if pd.isnull(assembly_length):
            if config["genome_size"] <= total_length <= config["assembly_length"]:
                return 'PASS'
            else:
                return 'FAIL'
        lower_bound = assembly_length * 0.85
        upper_bound = assembly_length * 1.15
        if lower_bound <= total_length <= upper_bound:
            return 'PASS'
        else:
            return 'FAIL'
    

    ## Step 7. QC check  
    ### Contigs
    ## Check contig count
    def check_contigs(n_contigs, min_contigs, max_contigs):
        if pd.isnull(n_contigs):
            return "FAIL"
        n = int(n_contigs)
        if n < min_contigs or n > max_contigs:
            return "FAIL"
        return "PASS"

    qc["Contig Check"] = qc.apply(
        lambda r: check_contigs(
            r["Total # of contigs"],
            params.min_contigs,
            params.max_contigs,
            ),
        axis=1,
        )

    ### Length check
    qc["Length Check"] = qc.apply(
        lambda r: check_assembly_length(
            r["Total length"],
            r["Assembly_Length"],
            ),
        axis=1,
        )

    ### QC pass:
    qc["QC Check"] = (
        (qc["Contig Check"] == "PASS") &
        (qc["Length Check"] == "PASS")
        ).map({True: "PASS", False: "FAIL"})
    
    ### Step 8. Get final data structure
    #### 1. Drop assembly length, contig, and length check variables 
    qc = qc.drop(columns=['Assembly_Length', 'Contig Check', 'Length Check'])

    #### 2. Get the current list of columns
    columns = list(qc.columns)
    
    #### 3. Insert QC Check between Total # of contigs and ANIs
    ##### Need to know the index positions of these columns to make the rearrangement correctly
    contigs_index = columns.index('Total # of contigs')
    ani_index = columns.index('ANI')
    qc_check_index = columns.index('QC Check')

    ##### Create the new column order
    ###### Put all columns before Total # of contigs then Total # of contigs, QC Check, ANI and the rest
    new_columns = [
    "Sample",
    "Total length",
    "Total # of contigs",
    "N50",
    "ANI",
    "Align_fraction_ref",
    "Align_fraction_query",
    "Ref_name",
    "Species",
    "Scheme",
    "ST",
    "QC Check",
    ]

    ###### Rearrange the columns
    qc = qc[new_columns]

    ### Print just to remember
    print("quast cols:", quast_summary.columns.tolist())
    print("mlst cols:", mlst.columns.tolist())
    print("skani cols:", skani_summary.columns.tolist())
    print("temp1 cols:", QC_summary_temp1.columns.tolist())
    print("qc cols:", qc.columns.tolist())
    
    ### Step 9. Save the file
    qc.to_csv('results/%s/%s_Report/data/%s_QC_summary.csv' % (prefix, prefix, prefix), index=False)

def plot(prefix, outdir):
    prefix = prefix.pop()
    outdir = outdir.pop()
    
    # Organize reports directory
    report_dir = str(outdir) + "/%s_Report" % prefix
    report_script_dir = str(outdir) + "/%s_Report/scripts" % prefix
    
    QC_summary = pd.read_csv('results/%s/%s_Report/data/%s_QC_summary.csv' % (prefix, prefix, prefix), sep=',', header=0)    

    Coverage = pd.read_csv("results/%s/%s_Report/data/%s_Final_Coverage.txt" % (prefix, prefix, prefix), sep=',', header=0)    
    Coverage_dist = QC_summary.sort_values(by='Coverage',ascending=False).plot(x='Sample', y='Coverage', kind="barh", title="Estimated Genome Coverage", figsize=(20, 20), fontsize=40).get_figure()
    Coverage_dist.savefig('%s/fig/%s_Coverage_distribution.png' % (report_dir, prefix), dpi=600)


    ax1 = QC_summary.plot.scatter(x = 'After_trim_total_deduplicated_percentage', y = 'After_trim_Total Sequences', c = 'DarkBlue')
    fig = ax1.get_figure()
    fig.savefig('%s/fig/%s_raw_dedup_vs_totalsequence.png' % (report_dir, prefix), dpi=600)

    ax1 = QC_summary.plot.scatter(x = 'After_trim_total_deduplicated_percentage', y = 'After_trim_Total Sequences', c = 'DarkBlue')
    fig = ax1.get_figure()
    fig.savefig('%s/fig/%s_aftertrim_dedup_vs_totalsequence.png' % (report_dir, prefix), dpi=600)
    ax1.cla()

    #ax = sns.scatterplot(x=QC_summary['Total # of contigs'], y=QC_summary['After_trim_%GC'], hue=QC_summary['Species'], s=100, style=QC_summary['Species'])
    #g.legend(loc='right', bbox_to_anchor=(1.30, 0.5), ncol=1)
    #fig2 = g.get_figure()
    #fig2.savefig('%s/fig/%s_Assembly_contig_vs_Aftertrim_GC.png' % (report_dir, prefix), dpi=600)
    #plt.savefig('%s/fig/%s_Assembly_contig_vs_Aftertrim_GC.png' % (report_dir, prefix), dpi=200)
    #ax.cla()

    #ax = sns.scatterplot(x=QC_summary['Total length'], y=QC_summary['After_trim_%GC'], hue=QC_summary['Species'], s=100, style=QC_summary['Species'])
    #g.legend(loc='right', bbox_to_anchor=(1.30, 0.5), ncol=1)
    #fig2 = g.get_figure()
    #fig2.savefig('%s/fig/%s_Assembly_contig_vs_Aftertrim_GC.png' % (report_dir, prefix), dpi=600)
    #plt.savefig('%s/fig/%s_Assembly_length_vs_Aftertrim_GC.png' % (report_dir, prefix), dpi=200)
    #ax.cla()

    #ax = sns.scatterplot(x=QC_summary['Total # of contigs'], y=QC_summary['N50'], hue=QC_summary['Species'], s=100, style=QC_summary['Species'])
    #g.legend(loc='right', bbox_to_anchor=(1.30, 0.5), ncol=1)
    #fig2 = g.get_figure()
    #fig2.savefig('%s/fig/%s_Assembly_contig_vs_N50.png' % (report_dir, prefix), dpi=600)
    #plt.savefig('%s/fig/%s_Assembly_contig_vs_N50.png' % (report_dir, prefix), dpi=200)
    #ax.cla()

    #ax = sns.scatterplot(x=QC_summary['Total # of contigs'], y=QC_summary['Coverage'], hue=QC_summary['Species'], s=100, style=QC_summary['Species'])
    #g.legend(loc='right', bbox_to_anchor=(1.30, 0.5), ncol=1)
    #fig2 = g.get_figure()
    #fig2.savefig('%s/fig/%s_Assembly_contig_vs_N50.png' % (report_dir, prefix), dpi=600)
    #plt.savefig('%s/fig/%s_Assembly_contig_vs_Coverage.png' % (report_dir, prefix), dpi=200)
    #ax.cla()

    #ax = sns.scatterplot(x=QC_summary['Total # of contigs'], y=QC_summary['Total length'], hue=QC_summary['Species'], s=100, style=QC_summary['Species'])
    #g.legend(loc='right', bbox_to_anchor=(1.30, 0.5), ncol=1)
    #fig2 = g.get_figure()
    #fig2.savefig('%s/fig/%s_Assembly_contig_vs_N50.png' % (report_dir, prefix), dpi=600)
    #plt.savefig('%s/fig/%s_Assembly_contig_vs_length.png' % (report_dir, prefix), dpi=200)
    #ax.cla()

rule skani_report:
    input:
        outdir = lambda wildcards: expand(f"results/{wildcards.prefix}/"),
        skani_out = expand("results/{prefix}/skani/{sample}/{sample}_skani_output.txt", prefix=PREFIX, sample=SAMPLE)
    output:
        skani_report = f"results/{{prefix}}/{{prefix}}_Report/data/{{prefix}}_Skani_report_final.csv",
    params:
        prefix = "{prefix}", 
    threads: 1
    resources:
        mem_mb  = 4000,   
        runtime = 15,
    run:
        skani_report({input.outdir}, {params.prefix})

rule multiqc:
    input:
        inputdir = lambda wildcards: expand(f"results/{wildcards.prefix}"), 
        mlst = lambda wildcards: expand(f"results/{wildcards.prefix}/{wildcards.prefix}_Report/data/{wildcards.prefix}_MLST_results.csv"),
        prokka   = lambda wildcards: expand(
            "results/{prefix}/prokka/{sample}/{sample}.gff",
            prefix=wildcards.prefix,
            sample=samples_that_passed_assembly(wildcards, return_samples_only=True)
        ),
        quast    = expand(
            "results/{prefix}/quast/{sample}/report.tsv",
            prefix=PREFIX,
            sample=SAMPLE,
        ),
    output:
        multiqc_fastqc_report = f"results/{{prefix}}/{{prefix}}_Report/multiqc/{{prefix}}_QC_report.html", 
        multiqc_general_stats = f"results/{{prefix}}/{{prefix}}_Report/multiqc/{{prefix}}_QC_report_data/multiqc_general_stats.txt", 
    params:
        outdir = "results/{prefix}/{prefix}_Report",
        prefix = "{prefix}",
        prokka_dirs = lambda wildcards, input: " ".join(
            set(os.path.dirname(f) for f in input.prokka)
        ),
        quast_dirs  = lambda wildcards, input: " ".join(
            set(os.path.dirname(f) for f in input.quast)
        )
    threads: 1
    resources:
        mem_mb  = 10000,   
        runtime = 600,
    #conda:
    #    "envs/multiqc.yaml"
    singularity:
        "docker://staphb/multiqc:1.19"
    shell:
        "multiqc -f --export --outdir {params.outdir}/multiqc -n {params.prefix}_QC_report -i {params.prefix}_QC_report {params.prokka_dirs} {params.quast_dirs} --module prokka --module quast"

rule mlst_report:
    input:
        outdir = lambda wildcards: expand(f"results/{wildcards.prefix}/"),
        mlst_out = expand("results/{prefix}/mlst/{sample}/report.tsv", prefix=PREFIX, sample=SAMPLE)
    output:
        mlst_report = f"results/{{prefix}}/{{prefix}}_Report/data/{{prefix}}_MLST_results.csv",
    params:
        prefix = "{prefix}",
    threads: 1
    resources:
        mem_mb  = 4000,   
        runtime = 15,
    shell:
        "echo \"Sample\tScheme\tST\" > {output.mlst_report} && cut -f1-3 {input.outdir}/mlst/*/report.tsv >> {output.mlst_report}"

rule Summary:
    input:
        outdir = lambda wildcards: expand(f"results/{wildcards.prefix}/"), 
        mlst = lambda wildcards: expand(f"results/{wildcards.prefix}/{wildcards.prefix}_Report/data/{wildcards.prefix}_MLST_results.csv"),
        skani_report = lambda wildcards: expand(f"results/{wildcards.prefix}/{wildcards.prefix}_Report/data/{wildcards.prefix}_Skani_report_final.csv"),
        quast_reports = expand(
            "results/{prefix}/quast/{sample}/report.tsv",
            prefix = PREFIX,
            sample = SAMPLE,
        ),
    output:
        QC_summary_report = f"results/{{prefix}}/{{prefix}}_Report/data/{{prefix}}_QC_summary.csv",
    params:
        prefix = "{prefix}",
        skani_genome_size_table = config["skani_genome_size"],
        min_contigs = config["min_contigs"],
        max_contigs = config["max_contigs"], 
        assembly_length = config["assembly_length"], 
    threads: 1
    resources:
        mem_mb  = 4000,   
        runtime = 15,
    run:
        summary(params.prefix, input.outdir, params.skani_genome_size_table,input, params)

rule plot:
    input:
        outdir = lambda wildcards: expand(f"results/{wildcards.prefix}/"),
        QC_summary_report = lambda wildcards: expand(f"results/{wildcards.prefix}/{wildcards.prefix}_Report/data/{wildcards.prefix}_QC_summary.csv"),
    output:
        QC_summary_report = f"results/{{prefix}}/{{prefix}}_Report/fig/{{prefix}}_Coverage_distribution.png",
    params:
        prefix = "{prefix}",
    threads: 1
    resources:
        mem_mb  = 4000,   
        runtime = 15,
    run:
        plot({params.prefix}, {input.outdir})

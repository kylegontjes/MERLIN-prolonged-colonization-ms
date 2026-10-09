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
slurm_outdir = "slurm_out/"
report_dir = outdir + "/%s_Report" % prefix
report_script_dir = report_dir + "/scripts"
report_data_dir = report_dir + "/data"
report_multiqc_dir = report_dir + "/multiqc"
report_fig_dir = report_dir + "/fig"

for d in [report_dir, report_script_dir, report_data_dir, report_multiqc_dir, report_fig_dir, slurm_outdir]:
    os.makedirs(d, exist_ok=True)

####### rules #################
include: "rules/bioawk_pubQCD_assembly.smk" 
include: "rules/prokka.smk"
include: "rules/quast.smk"
include: "rules/mlst.smk" 
include: "rules/busco.smk" 
include: "rules/skani_pubQCD_assembly.smk" 
include: "rules/pre_assembled_checkpoint.smk"

def samples_that_passed_assembly(wildcards=None, return_samples_only=False):
    # Get the output file from the checkpoint
    summary_csv = checkpoints.summarize_assembly.get(prefix=PREFIX).output.qc_summary
    # Read the coverage summary
    df = pd.read_csv(summary_csv)
    # Filter samples where QC_Pass is True
    passed_samples_assembly = df[df['QC_Pass'] == True]['Sample'].tolist()
    if return_samples_only:
        return passed_samples_assembly
    return (
        expand("results/{prefix}/prokka/{sample}/{sample}.gff",          prefix=PREFIX, sample=passed_samples_assembly) + 
        expand("results/{prefix}/busco/{sample}/{sample}_busco_out.txt", prefix=PREFIX, sample=passed_samples_assembly)
    )

include: "pubQCD_assembly_report_updated.smk"

rule all:
    input:
        samples_that_passed_assembly,
        QC_summary = expand("results/{prefix}/{prefix}_Report/data/{prefix}_QC_summary.csv", prefix=PREFIX),
        multiqc    = expand("results/{prefix}/{prefix}_Report/multiqc/{prefix}_QC_report.html", prefix=PREFIX),

"""
END OF PIPELINE
"""

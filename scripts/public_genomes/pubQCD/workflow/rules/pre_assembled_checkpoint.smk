checkpoint summarize_assembly:
    input:
        quast_reports = expand(
            "results/{prefix}/quast/{sample}/report.tsv",
            prefix = PREFIX,
            sample = SAMPLE,
        ),
        skani_reports = expand(
            "results/{prefix}/skani/{sample}/{sample}_skani_output.txt",
            prefix = PREFIX,
            sample = SAMPLE,
        ),
        species_freq = config["skani_genome_size"],
    output:
        qc_summary = "results/{prefix}/qc_passed_list.csv" 
    params: 
        min_contigs        = config["min_contigs"],
        max_contigs        = config["max_contigs"],
        assembly_length = config["assembly_length"], 
        genome_size     = config["genome_size"],
    threads: 1
    resources:
        mem_mb          = 5000,
        runtime         = 20,
    benchmark: 
        "benchmarks/{prefix}/checkpoint/check_assembly.benchmark.tsv"
    run:
        import pandas as pd
        import os
        import re

        # Step 1: Load skani reports
        skani_rows = []
        for skani_path in input.skani_reports:
            sample_name = os.path.basename(skani_path).replace("_skani_output.txt", "")
            skani_df = pd.read_csv(skani_path, sep="\t", header=0)
            if skani_df.empty:
                skani_rows.append({
                    "Sample":               sample_name,
                    "ANI":                  "NA",
                    "Align_fraction_ref":   "NA",
                    "Align_fraction_query": "NA",
                    "Ref_name":             "NA",
                    "Species":              "NA",
                })
            else:            
                row = skani_df[["ANI", "Align_fraction_ref", "Align_fraction_query", "Ref_name"]].iloc[0].copy()
                row["Sample"] = sample_name
                row["Species"] = (
                        re.search(r"[A-Za-z]+\s[A-Za-z]+", row["Ref_name"]).group(0)
                        if pd.notnull(row["Ref_name"]) and re.search(r"[A-Za-z]+\s[A-Za-z]+", row["Ref_name"])
                        else "NA"
                    )
                skani_rows.append(row[["Sample", "ANI", "Align_fraction_ref", "Align_fraction_query", "Ref_name", "Species"]].to_dict())
       
        skani_summary = pd.DataFrame(skani_rows)

        # Merge the expected genome summarize_assembly
        species_freq = pd.read_csv(input.species_freq)   # Species, Assembly_Length
        skani_summary = skani_summary.merge(species_freq, on="Species", how="left")

        # Step 2. Merge the quast reports
        ## Assembly length
        def check_assembly_length(total_length, assembly_length):
            if pd.isnull(total_length):
                return "FAIL"
            if pd.isnull(assembly_length):
                if params.genome_size <= total_length <= params.assembly_length:
                    return "PASS"
                else:
                    return "FAIL"
            lower_bound = assembly_length * 0.85
            upper_bound = assembly_length * 1.15
            if lower_bound <= total_length <= upper_bound:
                return "PASS"
            else:
                return "FAIL"

        ## Check contig count
        def check_contigs(n_contigs, min_contigs, max_contigs):
            if pd.isnull(n_contigs):
                return "FAIL"
            n = int(n_contigs)
            if n < min_contigs or n > max_contigs:
                return "FAIL"
            return "PASS"
        
        ## Load quast
        quast_rows = []
        for quast_path in input.quast_reports:
            sample = quast_path.split("/")[-2]
            df = pd.read_csv(quast_path, sep="\t", header=0, index_col=0)  # metric names become index
            quast_rows.append({
                "Sample":               sample,
                "Total length":         df.loc["Total length", df.columns[0]]         if "Total length"         in df.index else None,
                "# contigs (>= 0 bp)":  df.loc["# contigs (>= 0 bp)", df.columns[0]] if "# contigs (>= 0 bp)"  in df.index else None,
                "N50":                  df.loc["N50", df.columns[0]]                  if "N50"                  in df.index else None,
            })
        quast_summary = pd.DataFrame(quast_rows)

        # Merge quast and skani         
        qc = quast_summary.merge(skani_summary, on="Sample", how="left")
        
        # Apply QC check
        ## Contigs
        qc["Contig Check"] = qc.apply(
            lambda r: check_contigs(
                r["# contigs (>= 0 bp)"],
                params.min_contigs,
                params.max_contigs,
            ),
            axis=1,
        )
        ## Length check
        qc["Length Check"] = qc.apply(
            lambda r: check_assembly_length(
                r["Total length"],
                r.get("Assembly_Length"),
            ),
            axis=1,
        )
        ## QC pass:
        qc["QC_Pass"] = (
            (qc["Contig Check"] == "PASS") &
            (qc["Length Check"] == "PASS")
        )

        # Drop assembly length column
        qc = qc.drop(columns=['Assembly_Length'])
        
        # Write
        qc.to_csv(output.qc_summary, index=False)
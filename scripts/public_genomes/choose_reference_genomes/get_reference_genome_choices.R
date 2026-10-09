get_reference_genome_choices <- function(species_abbreviation,species,path,ANI_threshold){
  
  # Load and curate datasets
  df <- readRDS(paste0(path,"/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/data/dataset/MERLIN_cohort_metadata_final.RDS"))  %>% subset(qc_pass ==TRUE & WGS_escre==TRUE)
  public_qc_data <- read_csv(paste0(path,"/Public_datasets/2026-07-27_",species_abbreviation,"_NCBI/illumina/master_qc_summary_assembly.csv"))
  public_qc_data$Species_ST <- ifelse(public_qc_data$ST=="-",
                                      paste0(public_qc_data$Species," ST Unknown"),
                                      paste0(public_qc_data$Species," ST ",public_qc_data$ST))
  # Load skani data
  skani_dist <- read_tsv(paste0(path,"/Analysis/Household_transmission/MERLIN-prolonged-colonization-ms/data/public_genomes/",species_abbreviation,"/skani_distance/",species_abbreviation,"_skani_dist.tsv")) 
  ## Clean file names 
  skani_dist$Ref_file_name <- basename(skani_dist$Ref_file) %>%
    gsub("_chromosome.fna|.fna", "", .)
  skani_dist$Query_file_name <- basename(skani_dist$Query_file) %>%
    gsub("_chromosome.fna|.fna", "", .)
  
  ## Merge with TST data
  skani_dist <- skani_dist   %>% left_join(.,public_qc_data %>% select(Sample,ST,Species_ST) %>% mutate(Ref_file_name = Sample))
  
  # Do assembly check
  has_assembly_gap <- function(fasta_path) {
    if (!file.exists(fasta_path)) return(NA)
    result <- system(
      paste0("grep -v '^>' ", shQuote(fasta_path), " | grep -ci 'N'"),
      intern = TRUE, ignore.stderr = TRUE
    )
    as.integer(result) > 0
  }
  
  assembly_info <- skani_dist  %>% select(Ref_name,Ref_file,Ref_file_name) %>% distinct
  cat("Number of reference genomes before filter:", nrow(assembly_info), "\n") 
  assembly_info$has_assembly_gap <- sapply(assembly_info$Ref_file, has_assembly_gap)
  cat("Number of reference genomes with gaps issue:", sum(assembly_info$has_assembly_gap), "\n")
   
  # Filter
  dist_filtered <- skani_dist %>%
    filter(ANI >= ANI_threshold &  Num_ref_contigs  == 1)
  
  cat("Before filter:", nrow(skani_dist), "\n")
  cat("After ANI & ref conigs filter: ", nrow(dist_filtered), "\n")
  
  # Build analysis dataset
  ST_counts <- df %>% filter(Species == species) %>% count(Species_ST) %>% filter(n>1)
  ## Analysis groups (species wide and ST > 1)
  analysis_groups <- c("species", ST_counts$Species_ST)
  
  # Select the reference
  results <- map_dfr(analysis_groups, function(group) {
    
    # Filter MERLIN isolates per group
    if (group == "species") {
      dist_subset <- dist_filtered
    } else {
      merlin_ids <- df %>%
        filter(Species_ST == group) %>%
        pull(genomic_id)
      dist_subset <- dist_filtered %>%
        filter(Query_file_name %in% merlin_ids)
    }
     
    # Skip if no data for this group
    if (nrow(dist_subset) == 0) {
      message("No data for group: ", group)
      return(NULL)
    }
    
    dist_subset %>%
      group_by(Ref_name) %>% # Group by public dataset
      summarise(
        Ref_file_name      = first(Ref_file_name), # Get reference name
        Ref_file           = first(Ref_file), # Get file name
        mean_ANI           = mean(ANI), # Mean ANI
        median_ANI = median(ANI), # Median ANI
        min_ANI            = min(ANI), # Min ANI
        mean_aln_fraction_ref = mean(Align_fraction_ref), # Mean fraction of alignment w/ reference
        median_aln_fraction_ref = median(Align_fraction_ref), # Mean fraction of alignment w/ reference
        mean_aln_fraction_query      = mean(Align_fraction_query), # Mean fraction of alignment w/ query
        median_aln_fraction_query = median(Align_fraction_query), # Mean fraction of alignment w/ reference
        mean_bases_covered = mean(Total_bases_covered), # Mean base covered  
        median_bases_covered = median(Total_bases_covered), # Median base covered  
        mean_ref_n50       = mean(Ref_50_ctg_len),  # Reference's N50   
        median_ref_n50       = median(Ref_50_ctg_len),  # Median's N50   
        mean_ci_width      = mean(ANI_95_percentile -  # ANI confidence interval width
                                    ANI_5_percentile),
        median_ci_width      = median(ANI_95_percentile -  # ANI confidence interval width
                                    ANI_5_percentile),
        n_considered_genomes            = n() # Number of genomes matching
      ) %>%
      filter(n_considered_genomes == max(n_considered_genomes)) %>%
      filter(min_ANI >= ANI_threshold) %>%
      arrange(
        desc(round(median_ANI, 1)),       # 100.0 and 99.9 both round to same tier
        desc(round(median_aln_fraction_ref,1)),   # 100.0 and 99.9 both round to same tier 
        median_ci_width
      ) %>%
      mutate(group = group)  
  }) 
  
  # Generate results
  results <- results %>% left_join(.,public_qc_data %>% select(Sample,ST,Species_ST) %>% mutate(Ref_file_name = Sample)) %>% relocate(group)
  results <- left_join(results, assembly_info)
  
  # Rank all candadates
  results <- results %>%
    group_by(group) %>%
    filter(min_ANI >= ANI_threshold) %>%
    arrange(
      desc(round(median_ANI, 1)),
      desc(round(median_aln_fraction_ref, 1)),
      median_ci_width,
      .by_group = TRUE  
    ) %>%
    mutate(
      metric_rank = row_number(),
      ST_match = case_when(
        group == "species" ~ "species",
        grepl("Unknown", group) ~ "unknown_ST",
        group == Species_ST ~ "matched",
        TRUE ~ "unmatched"
      )
    ) %>%
    filter(
      if (first(group) == "species" | grepl("Unknown", first(group))) {
        if (any(ST != "-")) ST != "-" else TRUE
      } else {
        if (any(Species_ST == first(group))) Species_ST == first(group)
        else if (any(ST != "-")) ST != "-"
        else TRUE
      }
    ) %>%
    arrange(has_assembly_gap, metric_rank,
            .by_group = TRUE  ) %>%  
    mutate(best_available = metric_rank == 1,
           is_best_choice    = row_number() == 1  )  %>%
    ungroup()
    
    # Get best available
   best_choice <- results %>% filter(is_best_choice) 
  
  return(
  list(overall_results = results,
       best_choice = best_choice)
  )
}
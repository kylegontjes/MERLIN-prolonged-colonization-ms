# Get prolonged colonization
## Species/strainwide
get_prolonged_colonization <- function(isolate,metadata,variable){
  isolate_df <- subset(metadata,household==isolate)
  isolate_index <- subset(isolate_df,visit==0) %>% .[[variable]]
  if(grepl("Singleton",isolate_index)){
    isolate_baseline_same <- 0
    isolate_one_month_same <- 0
    isolate_two_month_same <- 0
    index_at_1_and_or_2 <- 0 
  } else {  
  isolate_follow_up <- subset(isolate_df,visit>0)
  isolate_follow_up_same_any <- ifelse(sum(isolate_follow_up[[variable]] == isolate_index)>0,1,0)
  isolate_baseline <- subset(isolate_df,visit==1)
  isolate_baseline_same <- ifelse(sum(isolate_baseline[[variable]] == isolate_index)>0,1,0)
  isolate_one_month <- subset(isolate_df,visit==2)
  isolate_one_month_same <- ifelse(sum(isolate_one_month[[variable]] == isolate_index)>0,1,0)
  isolate_two_month <- subset(isolate_df,visit==3)
  isolate_two_month_same <- ifelse(sum(isolate_two_month[[variable]] == isolate_index)>0,1,0)
  index_at_1_and_or_2 = ifelse(isolate_one_month_same==1 | isolate_two_month_same==1,1,0)
  }
  
  results <- cbind.data.frame(household=isolate,index_strain = isolate_index,isolate_baseline_same,isolate_one_month_same,isolate_two_month_same,index_at_1_and_or_2)
  colnames(results) <- c("household",paste0(colnames(results)[-1],"_",variable))
  return(results)
}

## Generic genotype analysis
get_prolonged_colonization_genotype <- function(isolate,metadata,variable,split){
  isolate_df <- subset(metadata,household==isolate)
  isolate_index <- subset(isolate_df,visit==0) %>% .[[variable]] %>% str_split(.,split) %>% unlist %>% subset(is.na(.)==F & .!='')
  
  if(length(isolate_index)==0){
    isolate_follow_up_same_any=0
    isolate_baseline_same=0
    isolate_one_month_same=0
    isolate_two_month_same=0
    index_at_1_and_or_2=0 
  } else{ 
    isolate_one_month <- subset(isolate_df,visit==2) %>% .[[variable]]  %>% str_split(.,split) %>% unlist
    isolate_one_month_same <- ifelse(sum(isolate_one_month %in% isolate_index)>0,1,0)
    isolate_two_month <- subset(isolate_df,visit==3) %>% .[[variable]]  %>% str_split(.,split) %>% unlist 
    isolate_two_month_same <- ifelse(sum(isolate_two_month %in% isolate_index)>0,1,0)
    index_at_1_and_or_2 = ifelse(isolate_one_month_same==1 | isolate_two_month_same==1,1,0)
  }
  
  results <- cbind.data.frame(household=isolate,isolate_one_month_same,isolate_two_month_same,index_at_1_and_or_2)
  colnames(results) <- c("household",paste0(colnames(results)[-1],"_",variable))
  return(results)
}

# Plasmid aware analysis
get_prolonged_colonization_plasmid_aware <- function(isolate,metadata,chromosome_variable,plasmid_variable,split,require_shared_plasmid=NULL,plasmid_cluster_variable=NULL,name){
  isolate_df <- subset(metadata,household==isolate)
  isolate_index <- subset(isolate_df,visit==0) 
  isolate_index_plasmid <- isolate_index[[plasmid_variable]] %>% str_split(.,split) %>% unlist %>% subset(is.na(.)==F & .!='')
  isolate_index_chromosome <- isolate_index[[chromosome_variable]] %>% str_split(.,split) %>% unlist %>% subset(is.na(.)==F & .!='')
  
  if(length(c(isolate_index_plasmid,isolate_index_chromosome))==0){
    isolate_follow_up_same_any=0
    isolate_baseline_same=0
    isolate_one_month_same=0
    isolate_two_month_same=0
    index_at_1_and_or_2=0 
  }  else { 
    isolate_one_month_plasmid <- subset(isolate_df,visit==2) %>% .[[plasmid_variable]]  %>% str_split(.,split) %>% unlist
    isolate_one_month_chromosome <-  subset(isolate_df,visit==2) %>% .[[chromosome_variable]]  %>% str_split(.,split) %>% unlist
    isolate_one_month_same <- ifelse(sum(isolate_index_plasmid %in% isolate_one_month_chromosome) | sum(isolate_index_chromosome %in% isolate_one_month_plasmid) >0 | sum(isolate_index_plasmid %in% isolate_one_month_plasmid ) >0,1,0)
    
    isolate_two_month_plasmid <- subset(isolate_df,visit==3) %>% .[[plasmid_variable]]  %>% str_split(.,split) %>% unlist
    isolate_two_month_chromosome <-  subset(isolate_df,visit==3) %>% .[[chromosome_variable]]  %>% str_split(.,split) %>% unlist
    isolate_two_month_same <- ifelse(sum(isolate_index_plasmid %in% isolate_two_month_chromosome) | sum(isolate_index_chromosome %in% isolate_two_month_plasmid) >0 | sum(isolate_index_plasmid %in%isolate_two_month_plasmid ) >0,1,0) 
    
    index_at_1_and_or_2 <- ifelse(isolate_one_month_same==1 | isolate_two_month_same==1,1,0)
  }
  if(require_shared_plasmid==T){
    index_plasmids <- isolate_index[[plasmid_cluster_variable]] %>% str_split(.,split) %>% unlist %>% subset(is.na(.)==F & .!='')
    one_month_plasmids <-  subset(isolate_df,visit==2) %>% .[[plasmid_cluster_variable]] %>% str_split(.,split) %>% unlist %>% subset(is.na(.)==F & .!='')
    two_month_plasmids <-  subset(isolate_df,visit==3)   %>% .[[plasmid_cluster_variable]] %>% str_split(.,split) %>% unlist %>% subset(is.na(.)==F & .!='')
    isolate_one_month_same <- ifelse(sum(index_plasmids %in% one_month_plasmids)>0 & isolate_one_month_same==1,1,0)
    isolate_two_month_same <- ifelse(sum(index_plasmids %in% two_month_plasmids)>0 & isolate_two_month_same==1,1,0)
    index_at_1_and_or_2 <-  ifelse(sum(index_plasmids %in% c(one_month_plasmids,two_month_plasmids))>0 & index_at_1_and_or_2==1,1,0)
  }
  
  results <- cbind.data.frame(household=isolate,isolate_one_month_same,isolate_two_month_same,index_at_1_and_or_2)
  colnames(results) <- c("household",paste0(colnames(results)[-1],"_ESCrE_genes_plasmid_",name))
  
  return(results)
} 

###### SNP VARIANT ANALYSES #####
## Read matrix 
load_phylokit_snp_matrix <- function(path) {
  # Read matrix
  SNP_matrix <- read_csv(path, col_names = FALSE) %>%
    column_to_rownames(var = "X1") %>%
    `colnames<-`(rownames(.))  
  # Return dataset
  return(SNP_matrix)
}

## Pair type dataset
### Create pair type dataset
create_pair_types_matrix_phylokit <- function(path) { 
  load_phylokit_snp_matrix(path) %>%
    get_cell_info()
}

### Get cell info
get_cell_info <- function(mat) {
  idx <- which(!is.na(mat) & lower.tri(mat) , arr.ind = TRUE)
  data.frame(
    isolate1 = rownames(mat)[idx[, 1]],
    isolate2 = colnames(mat)[idx[, 2]],
    pairwise_dist = mat[idx]
  )
}

## Create linking variable:
create_pair_linking_variable <- function(df, col1 = "isolate1", col2 = "isolate2") {
  df %>%
    mutate(
      key = paste(pmin(.data[[col1]], .data[[col2]]),
                  pmax(.data[[col1]], .data[[col2]]),
                  sep = "_")
    )
}

### Update pair types with info
update_pair_types_w_info <- function(pair_types_df,df,voi){ 
  # Subset to variables of interest
  df_subset <- df[, c("genomic_id", voi), drop = FALSE]
  
  # Join on isolate1
  pair_types_df <- pair_types_df %>%
    dplyr::left_join(df_subset, by = c("isolate1" = "genomic_id")) %>%
    dplyr::rename_with(~ paste0(., "1"), .cols = voi)
  
  # Join on isolate2
  pair_types_df <- pair_types_df %>%
    dplyr::left_join(df_subset, by = c("isolate2" = "genomic_id")) %>%
    dplyr::rename_with(~ paste0(., "2"), .cols = voi)
  
  return(as.data.frame(pair_types_df))
} 

## Clustering
# Get clusters using a SNP distance threshold
SNP_threshold_based_single_linkage_clustering <- function(dataframe,pair_types,threshold,distance_variable){
  # Get pairs under a threshold
  pair_types_under_t <- subset(pair_types, get(distance_variable) <= threshold, select = c(isolate1, isolate2))
  ig <- graph_from_data_frame(pair_types_under_t, directed = FALSE)
  membership <- components(ig)$membership
  
  # Create cluster dataset
  cluster <- membership[dataframe$genomic_id]
  names(cluster) <- dataframe$genomic_id
  
  results <- cbind.data.frame(genomic_id = names(cluster),
                              cluster = unname(cluster),
                              clustering_distance_variable=distance_variable)
  return(results)  
} 

# Recode cluster calls using sequence type
recode_clustering_calls_using_ST_data <- function(ST,metadata){
  # Subset to sequence type
  ST_df <- metadata[metadata$Species_ST == ST,]  
  # Recode cluster call
  ST_df$cluster <- ifelse(is.na(ST_df$cluster),"singleton",as.character(ST_df$cluster))
  
  # Get cluster calls and rank based on count
  clusters <- table(ST_df$cluster %>% subset(.!= "singleton")) %>% sort(decreasing=T) %>% subset(. >0) %>% names
  
  # Recode clusters
  ## We're recoding clusters bsaed on their frequency in the sequence type, thus cluster 1 = largest cluster in its sequence type
  if(length(clusters)>0){
    new_name <- setNames(1:length(clusters) %>% as.character(),clusters)
    ST_df$clusters_recode <- recode(ST_df$cluster, !!!new_name)
  } else {
    ST_df$clusters_recode <- ST_df$cluster
  }
  
  # Create species ST cluster dataframe
  ST_df$Species_ST_cluster <- ifelse(ST_df$clusters_recode=="singleton",
                                     paste0(ST_df$Species_ST," Singleton"),
                                     paste0(ST_df$Species_ST," Cluster ",
                                            ST_df$clusters_recode)) 
  
  # Remove clusters recode variable, as unnecessary variable at this stage
  ST_df <- ST_df %>% select(-clusters_recode)
  
  return(ST_df)
}

# Get cluster dynamics data when using the clustering recode function
cluster_summary_statistics <- function(clustering){
  cluster_string <- ifelse(grepl("Singleton",clustering),NA,clustering)
  clusters <- cluster_string %>% unlist %>% subset(is.na(.)==F) %>% unlist
  clusters_ct <- unique(clusters) %>% length
  cluster_isolates <-length(clusters)
  singletons <- sum(is.na(cluster_string))
  percentage_in_cluster <- cluster_isolates / sum(cluster_isolates,singletons) * 100
  cluster_size_med <- table(clusters) %>% median
  cluster_size_mean <- table(clusters) %>% mean
  cluster_size_max <- table(clusters) %>% max
  cluster_size_range <- table(clusters) %>% range %>% paste0(collapse = "-")
  clustering_data <- cbind.data.frame(clusters = clusters_ct,cluster_isolates,singletons,percentage_in_cluster,cluster_size_med,cluster_size_mean,cluster_size_max,cluster_size_range)
  return(clustering_data)
}


# Convert tableone into a dataframe
convert_tableone_into_df <- function(dataset,vars,strata=NULL,argsNormal=NULL,factorVars=NULL,outcome_names=NULL,exact=NULL){
  if(is.null(strata)==T){
    overall <- tableone::CreateTableOne(vars = vars, data=dataset,argsNormal = argsNormal,factorVars=factorVars)
    bound_table <-  capture.output(x <- print(overall, quote = FALSE, noSpaces = TRUE ))
    names <- x %>% as.matrix()  %>% rownames
    values <- x %>% as.data.frame %>% `rownames<-`(NULL)
    table <- cbind.data.frame(names,x %>% as.data.frame()) %>% `rownames<-`(NULL)
    colnames(table) <- c("Variable",paste0("Overall (n=",table[1,2],")"))
    rownames(table) <- NULL
    table <- table[-1,]
    return(table)
  }
  if(is.null(strata)==F){
    overall <- tableone::CreateTableOne(vars = vars, data=dataset,strata=strata,addOverall=T,argsNormal = argsNormal,factorVars=factorVars)
    bound_table <-  capture.output(x <- print(overall, quote = FALSE, noSpaces = TRUE,exact=exact))
    table <- x[,-ncol(x)]  %>% as.data.frame()
    names <- x %>% as.matrix()  %>% rownames
    table <- cbind.data.frame(names,table %>% as.data.frame()) %>% `rownames<-`(NULL) 
    colnames(table) <- c("Variable",paste0(c("Overall",outcome_names)," (n=",table[1,2:c(ncol(table)-1)],")"),"p-value")
    rownames(table) <- NULL
    table <- table[-1,]
    return(table)
  }
}

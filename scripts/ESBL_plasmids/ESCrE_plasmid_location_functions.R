# ESCrE_plasmid_location_functions

## 1. Get ESCrE gene data (i.e., location)
get_ESCrE_genes_data <- function(isolate,mobsuite_gene_pres,bla_genes,ESCrE_genes){
  mobsuite_df <- subset(mobsuite_gene_pres,genomic_id == isolate)
  plasmids_str <- mobsuite_df$type %>% subset(. != 'chromosome')  %>% paste0(collapse=';')  %>% {ifelse(is_empty(.)==T,"",.)}  
  bla_genes_str <- mobsuite_df %>% select(bla_genes) %>% select_if(colSums(.)==1) %>% colnames() %>% paste0(collapse=';')
  ESCrE_genes_str <- mobsuite_df %>% select(ESCrE_genes) %>% select_if(colSums(.)==1) %>% colnames() %>% paste0(collapse=";") %>% {ifelse(length(.)==0,"",.)}
  bla_chromosome_genes <-  mobsuite_df %>% subset(type=='chromosome') %>% select(bla_genes) %>% select_if(colSums(.)==1)  %>% colnames() %>% paste0(collapse=";") %>% {ifelse(length(.)==0,"",.)}
  ESCrE_chromosome_genes <-  mobsuite_df %>% subset(type=='chromosome') %>% select(ESCrE_genes) %>% select_if(colSums(.)==1)  %>% colnames() %>% paste0(collapse=";") %>% {ifelse(length(.)==0,"",.)}
  ESCrE_plasmid_genes <- mobsuite_df %>% subset(type!='chromosome') %>% select(ESCrE_genes) %>% select_if(colSums(.)==1)  %>% colnames() %>% paste0(collapse=";") %>% {ifelse(length(.)==0,"",.)}
  bla_plasmids <- subset(mobsuite_df,BETA_LACTAM_contig ==1) %>% .$type %>% subset(. != 'chromosome') %>% paste0(collapse=";") %>% {ifelse(length(.)==0,"",.)}
  ESCrE_plasmids <- subset(mobsuite_df,ESCrE_contig ==1) %>% .$type %>% subset(. != 'chromosome') %>% paste0(collapse=";") %>% {ifelse(length(.)==0,"",.)}
  
  results <- cbind.data.frame(genomic_id = isolate,plasmids=plasmids_str,bla_genes=bla_genes_str,ESCrE_genes=ESCrE_genes_str,bla_chromosome_genes=bla_chromosome_genes,ESCrE_chromosome_genes=ESCrE_chromosome_genes,ESCrE_plasmid_genes=ESCrE_plasmid_genes,bla_plasmids=bla_plasmids,ESCrE_plasmids = ESCrE_plasmids)
  return(results)
}

## 2. Analyze frequency on plasmid
analyze_frequency_on_plasmid <- function(ESCrE,plasmid_data){
  chromosome_ESCrE <- str_split(string = plasmid_data$ESCrE_chromosome_genes,';') %>% unlist %>% subset(.==ESCrE)
  plasmid_ESCrE <- str_split(string = plasmid_data$ESCrE_plasmid_genes,';') %>% unlist %>% subset(.==ESCrE)
  n_chromosome <- length(chromosome_ESCrE)
  n_plasmid <- length(plasmid_ESCrE)
  prop_plasmid <-  round(n_plasmid / (n_chromosome + n_plasmid) * 100 , 2)
  results <- cbind.data.frame(ESCrE,n_chromosome,n_plasmid,prop_plasmid)
  return(results)
}

## 3. Get plasmid-associated ESCrE
get_plasmidic_ESCrE<-  function(isolate,mobsuite_gene_pres,ESCrE_plasmidic_genes){
  mobsuite_df <- subset(mobsuite_gene_pres,genomic_id == isolate)
  ESCrE_plasmidic_genes_str <- mobsuite_df %>% select(ESCrE_plasmidic_genes) %>% select_if(colSums(.)==1) %>% colnames() %>% paste0(collapse=";") %>% {ifelse(length(.)==0,"",.)} 
  
  results <- cbind.data.frame(genomic_id = isolate,ESCrE_plasmidic_genes=ESCrE_plasmidic_genes_str)
  return(results)
}
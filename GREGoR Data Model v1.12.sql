CREATE TABLE `participant` (
  `participant_id` string PRIMARY KEY COMMENT 'Subject/Participant Identifier (primary key)',
  `internal_project_id` string COMMENT 'An identifier used by GREGoR research centers to identify a set of participants for their internal tracking',
  `gregor_center` enumeration COMMENT 'GREGoR Center to which the participant is originally associated',
  `consent_code` enumeration COMMENT 'Consent group pertaining to this participant''s data',
  `recontactable` enumeration COMMENT 'Is the originating GREGoR Center likely able to recontact this participant',
  `prior_testing` string COMMENT 'Text description of any genetic testing for individual conducted prior to enrollment',
  `pmid_id` string COMMENT 'Case specific PubMed ID if applicable',
  `family_id` string COMMENT 'Identifier for family',
  `paternal_id` string COMMENT 'participant_id for father; 0 if not available',
  `maternal_id` string COMMENT 'participant_id for mother; 0 if not available',
  `twin_id` string COMMENT 'participant_id for twins, triplets, etc; 0 if not available',
  `proband_relationship` enumeration COMMENT 'Text description of individual relationship to proband in family, especially useful to capture relationships when connecting distant relatives and connecting relatives not studied',
  `proband_relationship_detail` string COMMENT 'Other proband relationship not captured in enumeration above',
  `sex` enumeration COMMENT 'Biological sex assigned at birth (aligned with All of Us). If individual has a known DSD / not expected sex chromosome karyotype, this can be noted in the sex_detail field.',
  `sex_detail` string COMMENT 'Optional free-text field to describe known discrepancies between ''sex'' value (female=>XX, male=>XY) and actual sex chromosome karyotype or other relevant details',
  `reported_race` enumeration COMMENT 'Self/submitter-reported race (OMB categories)',
  `reported_ethnicity` enumeration COMMENT 'Self/submitter-reported ethnicity (OMB categories)',
  `ancestry_detail` string COMMENT 'Additional specific ancestry description free text beyond what is captured by OMB race/ethnicity categories',
  `age_at_last_observation` float COMMENT 'Age at last observation, aka age in years at the last time the center can vouch for the accuracy phenotype data. For conditions with later age of onset, this field lets users know if individuals marked as unaffected were younger or older than the age when the phenotype is expected to appear.',
  `affected_status` enumeration COMMENT 'Indicate affected status of individual (overall with respect to primary phenotype in the family). Note: Affected participants must have entry in phenotype table.',
  `phenotype_description` string COMMENT 'human-readable ''Phenotypic one-line summary'' for why this individual is of interest. Could be the same as the term_details value in the Phenotype table. Strongly encourage/required for proband.',
  `age_at_enrollment` float COMMENT 'age in years at which consent was originally obtained',
  `solve_status` enumeration COMMENT 'Indication of whether the submitting RC considers this case ''solved''',
  `missing_variant_case` enumeration COMMENT 'Indication of whether this is known to be a missing variant case, see notes for a description of the Missing Variant Project and inclusion criteria.',
  `missing_variant_details` string COMMENT 'For missing variant cases, indicate gene(s) or region of interest and reason for inclusion in MVP.'
);

CREATE TABLE `family` (
  `family_id` string PRIMARY KEY COMMENT 'Identifier for family (primary key)',
  `consanguinity` enumeration COMMENT 'Indicate if consanguinity is present or suspected within a family',
  `consanguinity_detail` string COMMENT 'Free text description of any additional consanguinity details',
  `pedigree_file` string COMMENT 'name of file (renamed from pedigree_image because it can contain a PED file or image)',
  `pedigree_file_detail` string COMMENT 'Free text description of other family structure/pedigree file caption or legend.',
  `family_history_detail` string COMMENT 'Details about family history that do not fit into structured fields. Family relationship terms should be relative to the proband.'
);

CREATE TABLE `phenotype` (
  `phenotype_id` string PRIMARY KEY COMMENT 'Identifier for phenotype (primary key), automatically generated as part of data deposition',
  `participant_id` string COMMENT 'Subject/Participant Identifier',
  `term_id` string COMMENT 'The phenotype code, including prefix, from a defined ontology. The specific ontology used is named in the ontology field.',
  `presence` enumeration COMMENT 'Indicate whether the indicated phenotype is present in this participant.',
  `ontology` enumeration COMMENT 'Which ontology does the term_id field entry come from?',
  `additional_details` string COMMENT 'modifier of a term where the additional details are not supported/available as a term in HPO',
  `onset_age_range` enumeration COMMENT 'The onset age range for the phenotype. Allowable values are subterms of ''Onset'' HP:0003674.',
  `additional_modifiers` enumeration COMMENT 'Human Phenotype Ontology (HPO) modifiers used to detail phenotypic aspects of the phenotype named with the term_id field (like age of onset or severity).',
  `syndromic` enumeration COMMENT 'For participants with few HPO terms, this optional field is to provide context on whether it is likely the most notable phenotype or cohort level phenotype or whether the individual really only has one trait.'
);

CREATE TABLE `genetic_findings` (
  `genetic_findings_id` string PRIMARY KEY COMMENT 'Unique ID of this variant in this participant (primary key)',
  `participant_id` string COMMENT 'Subject/Participant Identifier within project',
  `experiment_id` string COMMENT 'The experiment table and experiment ID(s) in which discovery was identified: experiment_table.id_in_table. Should correspond to an experiment_id in the DCC-generated experiment table.',
  `variant_type` enumeration,
  `sv_type` enumeration,
  `variant_reference_assembly` enumeration COMMENT 'The genome build for identifying the variant position',
  `chrom` enumeration COMMENT 'Chromosome of the variant',
  `chrom_end` enumeration COMMENT 'End position chromosome of SV',
  `pos` integer COMMENT 'Start position of the variant',
  `pos_end` integer COMMENT 'End position of SV',
  `ref` string COMMENT 'Reference allele of the variant',
  `alt` string COMMENT 'Alternate position of the variant',
  `copy_number` integer COMMENT 'CNV copy number',
  `ClinGen_allele_ID` string COMMENT 'ClinGen Allele ID for cross table refrence',
  `gene_of_interest` string COMMENT 'HGNC approved symbol of the known or candidate gene(s) that are relevant for the observed phenotype.',
  `transcript` string COMMENT 'Text description of transcript overlapping the variant',
  `hgvsc` string COMMENT 'HGVS c. description of the variant (m. for mitochondrial, n. for noncoding)',
  `hgvsp` string COMMENT 'HGVS p. description of the variant',
  `hgvs` string COMMENT 'genomic HGVS description of the variant',
  `zygosity` enumeration COMMENT 'Zygosity of variant',
  `allele_balance_or_heteroplasmy_percentage` float COMMENT 'Reported allele balance (mosaic) or heteroplasmy percentage (mitochondrial)',
  `variant_inheritance` enumeration COMMENT 'Detection of variant in parents',
  `linked_variant` string COMMENT 'Second variant in recessive cases',
  `linked_variant_phase` enumeration,
  `gene_known_for_phenotype` enumeration COMMENT 'Indicate if the gene listed is a candidate or known disease gene. Known disease genes can be identified using OMIM or MONDO or MitoMap. Variant/phenotype in proband should be consistent with the described MOD/phenotype to be considered a known gene for condition.',
  `known_condition_name` string COMMENT 'Free text of condition name. Variant/phenotype/inheritance in proband should be consistent with the condition.',
  `condition_id` string COMMENT 'MONDO/OMIM number for condition used for variant interpretation.',
  `condition_inheritance` enumeration COMMENT 'Description of the expected inheritance of condition used for variant interpretation',
  `GREGoR_variant_classification` enumeration COMMENT 'Clinical significance of variant described to condition listed as determined by the RC''s variant curation.',
  `GREGoR_ClinVar_SCV` string COMMENT 'ClinVar accession number for the variant curation submitted by your center',
  `gene_disease_validity` enumeration COMMENT 'Validity assessment of the gene-disease relationship',
  `gene_disease_validity_notes` string COMMENT 'additional context or explanation about the gene_disease_validity assessment',
  `public_database_other` string COMMENT 'Public databases that this variant in this participant has been submitted by the RC.',
  `public_database_ID_other` string COMMENT 'Public database variant/case ID',
  `phenotype_contribution` enumeration COMMENT 'Contribution of variant-linked condition to participant''s phenotype.',
  `partial_contribution_explained` string COMMENT 'List of specific phenotypes (HPO IDs) explained by the condition associated with this variant/gene in cases of partial contribution',
  `additional_family_members_with_variant` string COMMENT 'List of related participant IDs carrying the same variant',
  `method_of_discovery` enumeration COMMENT 'The method/assay(s) used to identify the candidate',
  `notes` string COMMENT 'Free text field to explain edge cases or discovery updates or list parallel experiment IDs or list parental allele balance when mosaic... etc.',
  `VRS_ID` string COMMENT 'The Variation Representation Specification (VRS, pronounced “verse”) is a standard developed by the Global Alliance for Genomic Health to facilitate and improve sharing of genetic information.'
);

CREATE TABLE `analyte` (
  `analyte_id` string PRIMARY KEY COMMENT 'identifier for an analyte from a primary biosample source (primary key)',
  `participant_id` string,
  `analyte_type` enumeration COMMENT 'analyte derived from the primary_biosample. The actual thing you''re sticking into a machine to analyze/sequence',
  `analyte_processing_details` string COMMENT 'details about how the analyte or original biosample was extracted or processed',
  `primary_biosample` enumeration COMMENT 'Tissue type of biosample taken from the participant that the analyte was extracted or processed from (for unknown can use tissue - UBERON:0000479), e.g. skin, liver, brain',
  `primary_biosample_id` string COMMENT 'Optional ID for the biosample; allows for linking of multiple analytes extracted or processed from the same biosample',
  `primary_biosample_details` string COMMENT 'Free text to capture information not in structured fields',
  `tissue_affected_status` enumeration COMMENT 'If applicable to disease (suspected mosaic), is the tissue from an affected source or an unaffected source?',
  `age_at_collection` float COMMENT 'age or participant in years at biosample collection',
  `participant_drugs_intake` string COMMENT 'The list of drugs patient is on, at the time of sample collection. This information is helpful during analysis of metabolomics and immune asssays. Free Text',
  `participant_special_diet` string COMMENT 'If the patient was fasting, when the sample was collected. this is relevant when analyzing metabolomics data. Free Text',
  `hours_since_last_meal` float COMMENT 'his is relevant when analyzing metabolomics data',
  `passage_number` integer COMMENT 'passage_number is relevant for fibroblast cultures and possibly iPSC.',
  `time_to_freeze` float COMMENT 'time (in hours) from collection to freezing the sample. delayed freeze turns out to be useful / important info for PaxGene blood (for RNA isolation).',
  `sample_transformation_detail` string COMMENT 'details regarding sample transformation',
  `quality_issues` string COMMENT 'freetext (limited characters) to concisely describe if there are any QC issues that would be important to note'
);

CREATE TABLE `experiment` (
  `experiment_id` string PRIMARY KEY COMMENT 'table_name.experiment_id_in_table',
  `table_name` enumeration,
  `id_in_table` string,
  `participant_id` string
);

CREATE TABLE `aligned` (
  `aligned_id` string PRIMARY KEY COMMENT 'table_name.aligned_id_in_table',
  `table_name` enumeration,
  `id_in_table` string,
  `participant_id` string,
  `aligned_file` string,
  `aligned_index_file` string
);

CREATE TABLE `experiment_dna_short_read` (
  `experiment_dna_short_read_id` string PRIMARY KEY COMMENT 'identifier for experiment_dna_short_read (primary key)',
  `analyte_id` string,
  `experiment_sample_id` string COMMENT 'identifier used in the data file (e.g. the SM tag in a BAM header, column headers for genotype fields in a VCF file)',
  `seq_library_prep_kit_method` string COMMENT 'Library prep kit used',
  `read_length` integer COMMENT 'sequenced read length (bp); GREGoR RCs do paired end sequencing, so is the example of 100bp indicates 2x100bp.',
  `experiment_type` enumeration COMMENT 'targeted, whole-genome, or exome short read DNA?',
  `targeted_regions_method` string COMMENT 'Which capture kit is used. Can be missing if RC receives external data',
  `targeted_region_bed_file` string COMMENT 'name and path of bed file uploaded to workspace',
  `date_data_generation` date COMMENT 'Date of data generation (First sequencing date)',
  `target_insert_size` integer COMMENT 'insert size the protocol targets for DNA fragments',
  `sequencing_platform` string COMMENT 'sequencing platform used for the experiment',
  `sequencing_event_details` string COMMENT 'describe if there are any sequencing-specific issues that would be important to note'
);

CREATE TABLE `aligned_dna_short_read` (
  `aligned_dna_short_read_id` string PRIMARY KEY COMMENT 'identifier for aligned_short_read (primary key)',
  `experiment_dna_short_read_id` string COMMENT 'identifier for experiment',
  `aligned_dna_short_read_file` string COMMENT 'name and path of file with aligned reads',
  `aligned_dna_short_read_index_file` string COMMENT 'name and path of index file corresponding to aligned reads file',
  `md5sum` string COMMENT 'md5 checksum for file',
  `reference_assembly` enumeration COMMENT 'Which reference assembly was used for alignment?',
  `reference_assembly_uri` string COMMENT 'URI (link) to download the specific reference assembly used',
  `reference_assembly_details` string COMMENT 'Describe any details about the specific reference assembly used (e.g. primary, chrY-masked)',
  `alignment_software` string COMMENT 'Software including version number',
  `mean_coverage` float COMMENT 'For WGS, mean coverage is calculated as total aligned bases divided by length of the genome. For WES, mean coverage is calculated as total bases within capture regions divided by length of the capture regions. The capture regions are defined in the BED file for the sample (linked in the experiment_dna_short_read table targeted_region_bed_file field).',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the file; perhaps a DOI or link to something like a WDL file or github repository',
  `quality_issues` string COMMENT 'describe if there are any QC issues that would be important to note'
);

CREATE TABLE `aligned_dna_short_read_set` (
  `aligned_dna_short_read_set_id` string PRIMARY KEY COMMENT 'identifier for a set of experiments (primary key)',
  `aligned_dna_short_read_id` string COMMENT 'the aligned_dna_short_read_id of a short read file included in the variant callset. Should correspond to the id on the aligned_dna_short_read table.'
);

CREATE TABLE `called_variants_dna_short_read` (
  `called_variants_dna_short_read_id` string PRIMARY KEY COMMENT 'unique key for table (anvil requirement)',
  `aligned_dna_short_read_set_id` string COMMENT 'identifier for experiment set',
  `called_variants_dna_file` string COMMENT 'name and path of the file with variant calls',
  `md5sum` string COMMENT 'md5 checksum for file',
  `caller_software` string COMMENT 'variant calling software used including version number',
  `variant_types` enumeration COMMENT 'types of variants called',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the file; perhaps a link to something like a WDL file or github repository',
  `chrom` enumeration COMMENT 'chromosome of the variants in the VCF file'
);

CREATE TABLE `experiment_rna_short_read` (
  `experiment_rna_short_read_id` string PRIMARY KEY COMMENT 'identifier for experiment_rna_short_read (primary key)',
  `analyte_id` string,
  `experiment_sample_id` string COMMENT 'identifier used in the data file (e.g. the SM tag in a BAM header, column headers for genotype fields in a VCF file)',
  `rna_sample_type` enumeration COMMENT 'indicates whether experiment_rna_short_read_id corresponds to study sample with analyte_id or an isogenic cell line',
  `seq_library_prep_kit_method` string COMMENT 'Library prep kit used',
  `library_prep_type` enumeration COMMENT 'type of library prep',
  `prep_targets_detail` string COMMENT 'depletion kit or list of depletion targets used',
  `experiment_type` enumeration COMMENT 'single-end or paired-end? targeted or untargeted RNA-seq experiment?',
  `read_length` integer COMMENT 'sequenced read length (bp); GREGoR RCs do paired end sequencing, so is the example of 100bp indicates 2x100bp.',
  `single_or_paired_ends` enumeration COMMENT 'single or paired end',
  `date_data_generation` date COMMENT 'Date of data generation (First sequencing date)',
  `sequencing_platform` string COMMENT 'sequencing platform used for the experiment',
  `within_site_batch_name` string COMMENT 'batch number for the site, important for future batch correction',
  `RIN` float COMMENT 'RIN number for quality of sample',
  `estimated_library_size` float COMMENT 'Calculated size factors for the sample, which are relative scaling factors to account for library size differences. Such factors may be calculated with functions such as estimateSizeFactors() in the R bioconductor package.',
  `total_reads` float COMMENT 'total number of reads'
);

CREATE TABLE `aligned_rna_short_read` (
  `aligned_rna_short_read_id` string PRIMARY KEY COMMENT 'identifier for aligned_short_read (primary key)',
  `experiment_rna_short_read_id` string COMMENT 'identifier for experiment',
  `aligned_rna_short_read_file` string COMMENT 'name and path of file with aligned reads',
  `aligned_rna_short_read_index_file` string COMMENT 'name and path of index file corresponding to aligned reads file',
  `md5sum` string COMMENT 'md5 checksum for file',
  `reference_assembly` enumeration COMMENT 'Which reference assembly was used for alignment?',
  `reference_assembly_uri` string COMMENT 'URI (link) to download the specific reference assembly used',
  `reference_assembly_details` string COMMENT 'Describe any details about the specific reference assembly used (e.g. primary, chrY-masked)',
  `gene_annotation` string COMMENT 'annotation file used for alignment',
  `gene_annotation_details` enumeration COMMENT 'Details of specific GENCODE options used for annotation',
  `alignment_software` string COMMENT 'Software including version number',
  `alignment_log_file` string COMMENT 'path of (log) file with all parameters for alignment software',
  `alignment_postprocessing` string COMMENT 'If any post processing was applied',
  `mean_coverage` float COMMENT 'Mean coverage of either the genome or the targeted regions',
  `percent_uniquely_aligned` float COMMENT 'how many reads aligned to just one place',
  `percent_multimapped` float COMMENT 'how many reads aligned to multiple places',
  `percent_unaligned` float COMMENT 'how many reads didn''t align',
  `quality_issues` string COMMENT 'describe if there are any QC issues that would be important to note',
  `alignment_QC_output_file` string COMMENT 'path of (log) file with all parameters for alignment software',
  `percent_rRNA` float COMMENT 'The proportion of sequenced reads that map to ribosomal RNA. A high proportion reflects contamination, with goals typically under 10% for good depletion, though it can range from 1-50% depending on the method (e.g., poly(A) selection vs. depletion kits) .',
  `percent_mRNA` float COMMENT 'The proportion of sequenced reads that map to messenger RNA, typically 1-5% of total cellular RNA, but this varies; mRNA enrichment methods (like polyA selection) target this small fraction for ''cleaner,'' focused data on coding genes, while total RNA-seq captures more non-coding RNAs (ncRNAs), yielding a broader but noisier profile requiring deeper sequencing and often showing a low percentage of reads mapping to annotated mRNA due to rRNA contamination and vast ncRNA content.',
  `percent_mtRNA` float COMMENT 'The proportion of sequenced reads that map to mitochondrial RNA. A crucial quality control metric, especially for single-cell (scRNA-seq). A high mtDNA% (often >10% in human) typically signals poor-quality cells, damaged samples, or apoptosis, though thresholds vary by tissue (e.g., heart muscle is naturally high) and researchers adjust filters to avoid excluding valid cell types, with some studies suggesting mtDNA% as a stable internal normalization standard',
  `percent_Globin` float COMMENT 'The proportion of sequencing reads that map to globin genes (like HBA, HBB) due to their abundance in red blood cells, which can overwhelm other transcripts and skew results.',
  `percent_UMI` float COMMENT 'The percentage of UMIs mapping to mitochondrial genes, a key metric indicating cell health; high percentages (e.g., >10-15%) suggest dying or damaged cells, while low numbers of total UMIs can signal poor quality or low RNA content, with thresholds varying by tissue and experiment.',
  `5prime3prime_bias` float COMMENT 'The ratio of the 5’ bias and the 3’ bias (5'' bias is the ratio between mean coverage at the 5’ region (first 100bp) and the whole transcript, and 3'' bias is the ratio between mean coverage at the 3’ region (last 100bp) and the whole transcript.)',
  `percent_GC` float COMMENT 'The proportion of Guanine (G) and Cytosine (C) bases in the RNA sequences, calculated as (Count(G) + Count(C)) / Total Bases * 100% - a crucial quality control metric because varying GC content can cause biases in library preparation (like PCR amplification) and sequencing, leading to under- or over-representation of certain transcripts, which needs correction for accurate gene expression analysis',
  `percent_chrX_Y` float COMMENT 'The percentage of reads mapping to chromosomes X and Y in an RNA-seq experiment; highly variable and depends entirely on the biological sex and sex chromosome constitution of the sample, the specific cell type or tissue analyzed, and the library preparation method used. Useful QC metric to identify sample swaps or other technical errors.'
);

CREATE TABLE `aligned_rna_short_read_set` (
  `aligned_rna_short_read_set_id` string PRIMARY KEY COMMENT 'identifier for a set of experiments (primary key)',
  `aligned_rna_short_read_id` string
);

CREATE TABLE `readcounts_rna_short_read` (
  `readcounts_rna_short_read_id` string PRIMARY KEY COMMENT 'unique key for table (anvil requirement)',
  `aligned_rna_short_read_set_id` string COMMENT 'identifier for experiment set',
  `readcounts_rna_file` string COMMENT 'name and path of the file with readcounts/feature quantifications',
  `md5sum` string COMMENT 'md5 checksum for file',
  `quantification_software` string COMMENT 'Quantification software used including version number',
  `quantification_types` enumeration COMMENT 'features used for quantification',
  `quantification_unit` enumeration COMMENT 'TPM or raw counts',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the file; perhaps a link to something like a WDL file or github repository',
  `annotation_file_for_quantification` string COMMENT 'name and path of the file with quantification annotations',
  `single_source` boolean COMMENT 'indicate if counts are from a single RC (TRUE) or from a harmonized/merged dataset (FALSE)'
);

CREATE TABLE `experiment_nanopore` (
  `experiment_nanopore_id` string PRIMARY KEY COMMENT 'identifier for experiment_nanopore (primary key)',
  `analyte_id` string,
  `experiment_sample_id` string COMMENT 'identifier used in the data file (e.g. the SM tag in a BAM header, column headers for genotype fields in a VCF file)',
  `seq_library_prep_kit_method` enumeration COMMENT 'Library prep kit used',
  `fragmentation_method` string COMMENT 'method used for shearing/fragmentation',
  `experiment_type` enumeration,
  `targeted_regions_method` string COMMENT 'Capture method used.',
  `targeted_region_bed_file` string COMMENT 'name and path of bed file uploaded to workspace',
  `date_data_generation` date COMMENT 'Date of data generation (First sequencing date)',
  `sequencing_platform` enumeration COMMENT 'sequencing platform used for the experiment',
  `chemistry_type` enumeration COMMENT 'chemistry type used for the experiment',
  `was_barcoded` boolean COMMENT 'indicates whether samples were barcoded on this flowcell',
  `barcode_kit` string COMMENT 'name of the kit used for barcoding'
);

CREATE TABLE `aligned_nanopore` (
  `aligned_nanopore_id` string PRIMARY KEY COMMENT 'identifier for aligned_nanopore (primary key)',
  `experiment_nanopore_id` string COMMENT 'identifier for experiment',
  `aligned_nanopore_file` string COMMENT 'name and path of file with aligned reads',
  `aligned_nanopore_index_file` string COMMENT 'name and path of index file corresponding to aligned reads file',
  `md5sum` string COMMENT 'md5 checksum for file',
  `reference_assembly` enumeration,
  `alignment_software` string COMMENT 'Software including version number',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the file; perhaps a DOI or link to something like a WDL file or github repository',
  `mean_coverage` float COMMENT 'Mean coverage of either the genome or the targeted regions',
  `genome_coverage` integer COMMENT 'e.g. >=90% at 10x or 20x; per consortium decision',
  `contamination` float COMMENT 'Contamination level estimate., e.g. <1% (display raw fraction not percent)',
  `sex_concordance` boolean COMMENT 'Comparison between reported sex vs genotype sex; Other if ploidy NOT XX or XY and Other if sex at birth is not known, thus unable to perform sex concordance',
  `num_reads` float COMMENT 'Total reads (before/ignoring alignment)',
  `num_bases` float COMMENT 'Number of bases (before/ignoring alignment)',
  `read_length_mean` float COMMENT 'Mean length of all reads (before/ignoring alignment)',
  `num_aligned_reads` float COMMENT 'Total aligned reads',
  `num_aligned_bases` float COMMENT 'Number of bases in aligned reads',
  `aligned_read_length_mean` float COMMENT 'Mean length of aligned reads',
  `read_error_rate` float COMMENT 'Mean empirical per-base error rate of aligned reads',
  `mapped_reads_pct` float COMMENT 'Number between 1 and 100, na',
  `methylation_called` boolean COMMENT 'Indicates whether 5mC and 6mA methylation has been called and annotated in the BAM file''s MM and ML tags',
  `quality_issues` string COMMENT 'describe if there are any QC issues that would be important to note',
  `fiberseq_format` boolean COMMENT 'Indicates if BAM file has been formatted using fibertools to include nucleosome and methyltransferase-sensitive patch (MSP) calls',
  `read_length_n50` float COMMENT 'N50 is the shortest read length that, when all reads are sorted by length from longest to shortest, covers 50% of the total sequence data (longer is better). Value in kilobases'
);

CREATE TABLE `aligned_nanopore_set` (
  `aligned_nanopore_set_id` string PRIMARY KEY COMMENT 'identifier for a set of experiments (primary key)',
  `aligned_nanopore_id` string
);

CREATE TABLE `called_variants_nanopore` (
  `called_variants_nanopore_id` string PRIMARY KEY COMMENT 'unique key for table (anvil requirement)',
  `aligned_nanopore_set_id` string COMMENT 'identifier for experiment set',
  `called_variants_dna_file` string COMMENT 'name and path of the file with variant calls',
  `md5sum` string COMMENT 'md5 checksum for file',
  `caller_software` string COMMENT 'variant calling software used including version number',
  `variant_types` string COMMENT 'types of variants called',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the file; perhaps a link to something like a WDL file or github repository',
  `chrom` enumeration COMMENT 'chromosome of the variants in the VCF file'
);

CREATE TABLE `experiment_pac_bio` (
  `experiment_pac_bio_id` string PRIMARY KEY COMMENT 'identifier for experiment_short_read (primary key)',
  `analyte_id` string,
  `experiment_sample_id` string COMMENT 'identifier used in the data file (e.g. the SM tag in a BAM header, column headers for genotype fields in a VCF file)',
  `seq_library_prep_kit_method` enumeration COMMENT 'Library prep kit used',
  `fragmentation_method` string COMMENT 'method used for shearing/fragmentation',
  `experiment_type` enumeration,
  `targeted_regions_method` string COMMENT 'Capture method used.',
  `targeted_region_bed_file` string COMMENT 'name and path of bed file uploaded to workspace',
  `date_data_generation` date COMMENT 'Date of data generation (First sequencing date)',
  `sequencing_platform` enumeration COMMENT 'sequencing platform used for the experiment',
  `was_barcoded` boolean COMMENT 'indicates whether samples were barcoded on this flowcell',
  `barcode_kit` enumeration COMMENT 'Barcode kit used',
  `application_kit` enumeration COMMENT 'Library prep kits for special applications',
  `smrtlink_server_version` string COMMENT 'Version number of PacBio SMRTLink software',
  `instrument_ics_version` string COMMENT 'Version number of PacBio instrument control software',
  `size_selection_method` string COMMENT 'library prep - method use for library size selection',
  `library_size` string COMMENT 'library prep - expected size of library from FemtoPulse',
  `smrt_cell_kit` string COMMENT 'sequencing - part number of the SMRT Cell',
  `smrt_cell_id` string COMMENT 'sequencing - unique serial number for SMRT Cell',
  `movie_name` string COMMENT 'sequencing - unique name of sequencing collection',
  `polymerase_kit` string COMMENT 'sequencing - part number of polymerase kit used',
  `sequencing_kit` string COMMENT 'sequencing - part number of sequencing kit reagents',
  `movie_length_hours` float COMMENT 'sequencing - length of sequencing collection, in hrs',
  `includes_kinetics` boolean COMMENT 'run reports base kinetics',
  `includes_CpG_methylation` boolean COMMENT 'run reports CpG methylation',
  `by_strand` boolean COMMENT 'run reports separate reads per strand'
);

CREATE TABLE `aligned_pac_bio` (
  `aligned_pac_bio_id` string PRIMARY KEY COMMENT 'identifier for aligned_short_read (primary key)',
  `experiment_pac_bio_id` string COMMENT 'identifier for experiment',
  `aligned_pac_bio_file` string COMMENT 'name and path of file with aligned reads',
  `aligned_pac_bio_index_file` string COMMENT 'name and path of index file corresponding to aligned reads file',
  `md5sum` string COMMENT 'md5 checksum for file',
  `reference_assembly` enumeration,
  `alignment_software` string COMMENT 'Software including version number',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the file; perhaps a DOI or link to something like a WDL file or github repository',
  `mean_coverage` float COMMENT 'Mean coverage of either the genome or the targeted regions',
  `genome_coverage` integer COMMENT 'e.g. ≥90% at 10x or 20x; per consortium decision',
  `contamination` float COMMENT 'Contamination level estimate., e.g. <1% (display raw fraction not percent)',
  `sex_concordance` boolean COMMENT 'Comparison between reported sex vs genotype sex; Other if ploidy NOT XX or XY and Other if sex at birth is not known, thus unable to perform sex concordance',
  `num_reads` float COMMENT 'Total reads (before/ignoring alignment)',
  `num_bases` float COMMENT 'Number of bases (before/ignoring alignment)',
  `read_length_mean` float COMMENT 'Mean length of all reads (before/ignoring alignment)',
  `num_aligned_reads` float COMMENT 'Total aligned reads',
  `num_aligned_bases` float COMMENT 'Number of bases in aligned reads',
  `aligned_read_length_mean` float COMMENT 'Mean length of aligned reads',
  `read_error_rate` float COMMENT 'Mean empirical per-base error rate of aligned reads',
  `mapped_reads_pct` float COMMENT 'Number between 1 and 100, na',
  `methylation_called` boolean COMMENT 'Indicates whether 5mC and 6mA methylation has been called and annotated in the BAM file''s MM and ML tags',
  `quality_issues` string COMMENT 'describe if there are any QC issues that would be important to note',
  `fiberseq_format` boolean COMMENT 'Indicates if BAM file has been formatted using fibertools to include nucleosome and methyltransferase-sensitive patch (MSP) calls',
  `read_length_n50` float COMMENT 'N50 is the shortest read length that, when all reads are sorted by length from longest to shortest, covers 50% of the total sequence data (longer is better). Value in kilobases'
);

CREATE TABLE `aligned_pac_bio_set` (
  `aligned_pac_bio_set_id` string PRIMARY KEY COMMENT 'identifier for a set of experiments (primary key)',
  `aligned_pac_bio_id` string
);

CREATE TABLE `called_variants_pac_bio` (
  `called_variants_pac_bio_id` string PRIMARY KEY COMMENT 'unique key for table (anvil requirement)',
  `aligned_pac_bio_set_id` string COMMENT 'identifier for experiment set',
  `called_variants_dna_file` string COMMENT 'name and path of the file with variant calls',
  `md5sum` string COMMENT 'md5 checksum for file',
  `caller_software` string COMMENT 'variant calling software used including version number',
  `variant_types` string COMMENT 'types of variants called',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the file; perhaps a link to something like a WDL file or github repository',
  `chrom` enumeration COMMENT 'chromosome of the variants in the VCF file'
);

CREATE TABLE `experiment_atac_short_read` (
  `experiment_atac_short_read_id` string PRIMARY KEY COMMENT 'identifier for experiment_atac_short_read (primary key)',
  `analyte_id` string,
  `experiment_sample_id` string COMMENT 'identifier used in the data file (e.g. the SM tag in a BAM header, column headers for genotype fields in a VCF file)',
  `seq_library_prep_kit_method` string COMMENT 'Library prep kit used',
  `read_length` integer COMMENT 'sequenced read length (bp); GREGoR RCs do paired end sequencing, so is the example of 100bp indicates 2x100bp.',
  `experiment_type` enumeration,
  `targeted_regions_method` string COMMENT 'Which capture kit is used. Can be missing if RC receives external data',
  `targeted_region_bed_file` string COMMENT 'name and path of bed file uploaded to workspace',
  `date_data_generation` date COMMENT 'Date of data generation (First sequencing date)',
  `target_insert_size` integer COMMENT 'insert size the protocol targets for DNA fragments',
  `sequencing_platform` string COMMENT 'sequencing platform used for the experiment'
);

CREATE TABLE `aligned_atac_short_read` (
  `aligned_atac_short_read_id` string PRIMARY KEY COMMENT 'identifier for aligned_atac_short_read (primary key)',
  `experiment_atac_short_read_id` string COMMENT 'identifier for experiment',
  `aligned_atac_short_read_file` string COMMENT 'name and path of file with aligned reads',
  `aligned_atac_short_read_index_file` string COMMENT 'name and path of index file corresponding to aligned reads file',
  `md5sum` string COMMENT 'md5 checksum for file',
  `reference_assembly` enumeration,
  `reference_assembly_uri` string,
  `reference_assembly_details` string,
  `alignment_software` string COMMENT 'Software including version number',
  `gene_annotation_details` enumeration,
  `alignment_log_file` string COMMENT 'path of (log) file with all parameters for alignment software',
  `alignment_postprocessing` string COMMENT 'If any post processing was applied',
  `mean_coverage` float COMMENT 'Mean coverage of either the genome or the targeted regions',
  `percent_uniquely_aligned` float COMMENT 'how many reads aligned to just one place',
  `percent_multimapped` float COMMENT 'how many reads aligned to multiple places',
  `percent_unaligned` float COMMENT 'how many reads didn''t align'
);

CREATE TABLE `called_peaks_atac_short_read` (
  `called_peaks_atac_short_read_id` string PRIMARY KEY COMMENT 'unique key for table (anvil requirement)',
  `aligned_atac_short_read_id` string COMMENT 'identifier for aligned ATAC-seq data',
  `called_peaks_file` string COMMENT 'name and path of the bed file with open chromatin peaks after QC filtering',
  `peaks_md5sum` string COMMENT 'md5 checksum for called_peaks_file',
  `peak_caller_software` string COMMENT 'peak calling software used including version number',
  `peak_set_type` enumeration COMMENT 'peak set type, according to ENCODE descriptors',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the called_peaks_file; perhaps a link to something like a WDL file or github repository'
);

CREATE TABLE `allele_specific_atac_short_read` (
  `asc_atac_short_read_id` string COMMENT 'unique key for table (anvil requirement)',
  `called_peaks_atac_short_read_id` string COMMENT 'identifier for called peaks',
  `asc_file` string COMMENT 'name and path of the tsv file with allele-specific chromatin accessibility measures (logFC) at heterozygous sites after QC and significance testing',
  `asc_md5sum` string COMMENT 'md5 checksum for called_peaks_file',
  `peak_set_type` enumeration COMMENT 'peak set type, according to ENCODE descriptors',
  `het_sites_file` string COMMENT 'VCF file containing prefiltered heterozygous sites used for reference alignment bias testing and calling allele-specific chromatin accessibility events',
  `het_sites_md5sum` string COMMENT 'md5 checksum for het_sites_file',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the asc_file; perhaps a link to something like a WDL file or github repository'
);

CREATE TABLE `experiment_optical_mapping` (
  `experiment_optical_mapping_id` string PRIMARY KEY COMMENT 'identifier for experiment_optical_mapping (primary key)',
  `analyte_id` string,
  `experiment_sample_id` string COMMENT 'identifier used in the data file (e.g. the SM tag in a BAM header, column headers for genotype fields in a VCF file)',
  `isolation_protocol` string COMMENT 'Name of DNA Isolation kit used',
  `labeling_protocol` string COMMENT 'Name of DNA labeling kit used',
  `date_data_generation` date COMMENT 'Date of data generation (First sequencing date)',
  `DNA_concentration` float COMMENT 'DNA concentration in ng/uL',
  `mapping_platform` string COMMENT 'OGM platform used for the experiment'
);

CREATE TABLE `molecule_file_optical_mapping` (
  `molecule_file_optical_mapping_id` string PRIMARY KEY COMMENT 'identifier for molecule_file_optical_mapping (primary key)',
  `experiment_optical_mapping_id` string COMMENT 'identifier for experiment',
  `bnx_file` string COMMENT 'name and path of raw molecule file',
  `bnx_version` float COMMENT 'Molecule file version',
  `md5sum` string COMMENT 'md5 checksum for bnx file',
  `n50_gt_20_kbp` float COMMENT 'N50 of the molecules that are 20kbp or longer (in kbp)',
  `n50_gt_150_kbp` float COMMENT 'N50 of DNA molecules that are 150kbp or longer (in kbp)',
  `total_DNA_gt_20_kbp` float COMMENT 'Total amount of DNA from molecules that are 20 kbp or longer (in Gbp)',
  `total_DNA_gt_150_kbp` float COMMENT 'Total amount of DNA from molecules that are 150kbp or longer (in Gpb)',
  `map_rate` float COMMENT 'Percentage of molecules that are 150kbp or longer mapped to the reference',
  `ave_label_density_gt_150_kbp` float COMMENT 'Average number of labels per 100 kbp for the molecules that are 150kbp or longer, example value is 15.57 /100kbp',
  `base_pairs_per_pixel` float COMMENT 'Calculated base pairs per pixel in the alignment by comparing molecules to the reference.',
  `scaling_sd` float COMMENT 'Linear term in sizing error relative to reference',
  `relative_sd` float COMMENT 'Quadratic term in sizing error relative to reference',
  `site_sd` float COMMENT 'Constant term in sizing error relative to reference',
  `positive_label_variance` float COMMENT 'Percentage of labels absent in reference',
  `negative_label_variance` float COMMENT 'Percentage of reference labels absent in molecules',
  `quality_issues` string COMMENT 'describe if there are any QC issues that would be important to note'
);

CREATE TABLE `aligned_molecules_optical_mapping` (
  `aligned_molecules_optical_mapping_id` string PRIMARY KEY COMMENT 'identifier for aligned_molecules_optical_mapping (primary key)',
  `molecule_file_optical_mapping_id` string COMMENT 'identifier for molecule file used for this alignment',
  `aligned_molecules_optical_mapping_file` string COMMENT 'Location of molecule to reference alignment file',
  `aligned_molecules_optical_mapping_index_file` string COMMENT 'Location of molecule to reference alignment index file',
  `md5sum` string COMMENT 'md5 checksum for aligned molecules .bam file',
  `reference_assembly` enumeration,
  `reference_assembly_uri` string,
  `reference_assembly_details` string,
  `reference_length` float COMMENT 'Total length of reference sequence (in base pairs)',
  `bionano_reference` string COMMENT 'The bionano internal cmap name of the reference genome this sample was aligned to',
  `software_interface_version` string COMMENT 'Bionano Access Version (software used for alignment)',
  `number_molecules_aligned` integer COMMENT 'The number of molecules after filtering (≥ 150 kbp) that align to the in silico digested reference file (.cmap), e.g. GRCh37 or GRCh38',
  `fraction_molecules_aligned` float COMMENT 'The proportion of filtered molecules that align to the consensus genome maps (assembly only).',
  `effective_reference_coverage` float COMMENT 'The total length of molecules divided by the length of the reference or consensus assembled maps after de novo assembly.',
  `average_confidence` float COMMENT 'The average alignment score for all the molecules that align to the reference.',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the file; perhaps a DOI or link to something like a WDL file or github repository',
  `quality_issues` string COMMENT 'describe if there are any QC issues that would be important to note'
);

CREATE TABLE `aligned_assembly_optical_mapping` (
  `aligned_assembly_optical_mapping_id` string PRIMARY KEY COMMENT 'identifier for aligned_assembly_optical_mapping (primary key)',
  `molecule_file_optical_mapping_id` string COMMENT 'identifier for molecule file used for this alignment',
  `reference_assembly` enumeration,
  `reference_assembly_uri` string,
  `reference_assembly_details` string,
  `reference_length` float COMMENT 'Total length of reference sequence (in base pairs)',
  `bionano_reference` string COMMENT 'The bionano internal cmap name of the reference genome this sample was aligned to',
  `software_interface_version` string COMMENT 'Bionano Access Version (software used for alignment)',
  `job_name` string COMMENT 'Alias for Job',
  `r_cmap_file` string COMMENT 'Location of reference cmap file',
  `xmap_file` string COMMENT 'Location of molecule to alignment xmap file',
  `q_cmap_file` string COMMENT 'Location of aligned molecule cmap file',
  `cmap_file_version` float COMMENT 'Version of cmap file',
  `xmap_file_version` float COMMENT 'The version of the xmap file',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the file; perhaps a DOI or link to something like a WDL file or github repository',
  `quality_issues` string COMMENT 'describe if there are any QC issues that would be important to note'
);

CREATE TABLE `aligned_optical_mapping` (
  `aligned_optical_mapping_id` string PRIMARY KEY COMMENT 'identifier for a set of experiments (primary key)',
  `aligned_assembly_optical_mapping_id` string,
  `aligned_molecules_optical_mapping_id` string
);

CREATE TABLE `aligned_optical_mapping_set` (
  `aligned_optical_mapping_set_id` string PRIMARY KEY COMMENT 'identifier for a set of experiments (primary key)',
  `aligned_optical_mapping_id` string
);

CREATE TABLE `called_variants_optical_mapping` (
  `called_variants_optical_mapping_id` string PRIMARY KEY COMMENT 'unique key for table (anvil requirement)',
  `aligned_optical_mapping_set_id` string COMMENT 'identifier for set',
  `optical_mapping_vcf_file` string COMMENT 'name and path of the file with optical mapping variant calls',
  `md5sum` string COMMENT 'md5 checksum for vcf file',
  `called_cnv_heterozygosity_variants_optical_mapping_file` string COMMENT 'name and path of the file with copy number variation and absence of heterozygosity calls',
  `solve_version` string COMMENT 'Bionano Solve Version (software that made the structural variation calls)',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the file; perhaps a link to something like a WDL file or github repository',
  `chrom` enumeration COMMENT 'chromosome of the variants in the VCF file'
);

CREATE TABLE `experiment_iclr` (
  `experiment_iclr_id` string PRIMARY KEY COMMENT 'identifier for experiment_iclr (primary key)',
  `analyte_id` string,
  `experiment_sample_id` string COMMENT 'identifier used in the data file (e.g. the SM tag in a BAM header, column headers for genotype fields in a VCF file)',
  `seq_library_prep_kit_method` string COMMENT 'Library prep kit used',
  `read_length` integer COMMENT 'sequenced read length (bp); GREGoR RCs do paired end sequencing, so is the example of 100bp indicates 2x100bp.',
  `experiment_type` enumeration,
  `targeted_regions_method` string COMMENT 'Capture method used.',
  `targeted_region_bed_file` string COMMENT 'name and path of bed file uploaded to workspace',
  `date_data_generation` date COMMENT 'Date of data generation (First sequencing date)',
  `sequencing_platform` string COMMENT 'sequencing platform used for the experiment',
  `sequencing_event_details` string COMMENT 'describe if there are any sequencing-specific issues that would be important to note',
  `unmarked_experiment_id` string COMMENT 'ICLR uses fastqs from a standard Illumina WGS sample that is combined with ICLR data'
);

CREATE TABLE `aligned_iclr` (
  `aligned_iclr_id` string PRIMARY KEY COMMENT 'identifier for aligned_iclr (primary key)',
  `experiment_iclr_id` string COMMENT 'identifier for experiment',
  `aligned_iclr_file` string COMMENT 'name and path of file with aligned reads',
  `aligned_iclr_index_file` string COMMENT 'name and path of index file corresponding to aligned reads file',
  `md5sum` string COMMENT 'md5 checksum for file',
  `reference_assembly` enumeration,
  `reference_assembly_uri` string,
  `reference_assembly_details` string,
  `alignment_software` string COMMENT 'Software including version number',
  `mean_coverage` float COMMENT 'For WGS, mean coverage is calculated as total aligned bases divided by length of the genome. For WES, mean coverage is calculated as total bases within capture regions divided by length of the capture regions. The capture regions are defined in the BED file for the sample (linked in the experiment_dna_iclr table targeted_region_bed_file field).',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the file; perhaps a DOI or link to something like a WDL file or github repository',
  `quality_issues` string COMMENT 'describe if there are any QC issues that would be important to note'
);

CREATE TABLE `aligned_iclr_set` (
  `aligned_iclr_set_id` string PRIMARY KEY COMMENT 'identifier for a set of experiments (primary key)',
  `aligned_iclr_id` string
);

CREATE TABLE `called_variants_iclr` (
  `called_variants_iclr_id` string PRIMARY KEY COMMENT 'unique key for table (anvil requirement)',
  `aligned_iclr_set_id` string COMMENT 'identifier for experiment set',
  `called_variants_dna_file` string COMMENT 'name and path of the file with variant calls',
  `md5sum` string COMMENT 'md5 checksum for file',
  `caller_software` string COMMENT 'variant calling software used including version number',
  `variant_types` enumeration COMMENT 'types of variants called',
  `analysis_details` string COMMENT 'brief description of the analysis pipeline used for producing the file; perhaps a link to something like a WDL file or github repository',
  `chrom` enumeration COMMENT 'chromosome of the variants in the VCF file'
);

ALTER TABLE `participant` ADD FOREIGN KEY (`family_id`) REFERENCES `family` (`family_id`);

ALTER TABLE `phenotype` ADD FOREIGN KEY (`participant_id`) REFERENCES `participant` (`participant_id`);

ALTER TABLE `genetic_findings` ADD FOREIGN KEY (`participant_id`) REFERENCES `participant` (`participant_id`);

ALTER TABLE `genetic_findings` ADD FOREIGN KEY (`partial_contribution_explained`) REFERENCES `phenotype` (`term_id`);

ALTER TABLE `genetic_findings` ADD FOREIGN KEY (`additional_family_members_with_variant`) REFERENCES `participant` (`participant_id`);

ALTER TABLE `analyte` ADD FOREIGN KEY (`participant_id`) REFERENCES `participant` (`participant_id`);

ALTER TABLE `experiment` ADD FOREIGN KEY (`participant_id`) REFERENCES `participant` (`participant_id`);

ALTER TABLE `aligned` ADD FOREIGN KEY (`participant_id`) REFERENCES `participant` (`participant_id`);

ALTER TABLE `experiment_dna_short_read` ADD FOREIGN KEY (`analyte_id`) REFERENCES `analyte` (`analyte_id`);

ALTER TABLE `aligned_dna_short_read` ADD FOREIGN KEY (`experiment_dna_short_read_id`) REFERENCES `experiment_dna_short_read` (`experiment_dna_short_read_id`);

ALTER TABLE `aligned_dna_short_read_set` ADD FOREIGN KEY (`aligned_dna_short_read_id`) REFERENCES `aligned_dna_short_read` (`aligned_dna_short_read_id`);

ALTER TABLE `called_variants_dna_short_read` ADD FOREIGN KEY (`aligned_dna_short_read_set_id`) REFERENCES `aligned_dna_short_read_set` (`aligned_dna_short_read_set_id`);

ALTER TABLE `experiment_rna_short_read` ADD FOREIGN KEY (`analyte_id`) REFERENCES `analyte` (`analyte_id`);

ALTER TABLE `aligned_rna_short_read` ADD FOREIGN KEY (`experiment_rna_short_read_id`) REFERENCES `experiment_rna_short_read` (`experiment_rna_short_read_id`);

ALTER TABLE `aligned_rna_short_read_set` ADD FOREIGN KEY (`aligned_rna_short_read_id`) REFERENCES `aligned_rna_short_read` (`aligned_rna_short_read_id`);

ALTER TABLE `readcounts_rna_short_read` ADD FOREIGN KEY (`aligned_rna_short_read_set_id`) REFERENCES `aligned_rna_short_read_set` (`aligned_rna_short_read_set_id`);

ALTER TABLE `experiment_nanopore` ADD FOREIGN KEY (`analyte_id`) REFERENCES `analyte` (`analyte_id`);

ALTER TABLE `aligned_nanopore` ADD FOREIGN KEY (`experiment_nanopore_id`) REFERENCES `experiment_nanopore` (`experiment_nanopore_id`);

ALTER TABLE `aligned_nanopore_set` ADD FOREIGN KEY (`aligned_nanopore_id`) REFERENCES `aligned_nanopore` (`aligned_nanopore_id`);

ALTER TABLE `called_variants_nanopore` ADD FOREIGN KEY (`aligned_nanopore_set_id`) REFERENCES `aligned_nanopore_set` (`aligned_nanopore_set_id`);

ALTER TABLE `experiment_pac_bio` ADD FOREIGN KEY (`analyte_id`) REFERENCES `analyte` (`analyte_id`);

ALTER TABLE `aligned_pac_bio` ADD FOREIGN KEY (`experiment_pac_bio_id`) REFERENCES `experiment_pac_bio` (`experiment_pac_bio_id`);

ALTER TABLE `aligned_pac_bio_set` ADD FOREIGN KEY (`aligned_pac_bio_id`) REFERENCES `aligned_pac_bio` (`aligned_pac_bio_id`);

ALTER TABLE `called_variants_pac_bio` ADD FOREIGN KEY (`aligned_pac_bio_set_id`) REFERENCES `aligned_pac_bio_set` (`aligned_pac_bio_set_id`);

ALTER TABLE `experiment_atac_short_read` ADD FOREIGN KEY (`analyte_id`) REFERENCES `analyte` (`analyte_id`);

ALTER TABLE `aligned_atac_short_read` ADD FOREIGN KEY (`experiment_atac_short_read_id`) REFERENCES `experiment_atac_short_read` (`experiment_atac_short_read_id`);

ALTER TABLE `called_peaks_atac_short_read` ADD FOREIGN KEY (`aligned_atac_short_read_id`) REFERENCES `aligned_atac_short_read` (`aligned_atac_short_read_id`);

ALTER TABLE `allele_specific_atac_short_read` ADD FOREIGN KEY (`called_peaks_atac_short_read_id`) REFERENCES `called_peaks_atac_short_read` (`called_peaks_atac_short_read_id`);

ALTER TABLE `experiment_optical_mapping` ADD FOREIGN KEY (`analyte_id`) REFERENCES `analyte` (`analyte_id`);

ALTER TABLE `molecule_file_optical_mapping` ADD FOREIGN KEY (`experiment_optical_mapping_id`) REFERENCES `experiment_optical_mapping` (`experiment_optical_mapping_id`);

ALTER TABLE `aligned_molecules_optical_mapping` ADD FOREIGN KEY (`molecule_file_optical_mapping_id`) REFERENCES `molecule_file_optical_mapping` (`molecule_file_optical_mapping_id`);

ALTER TABLE `aligned_assembly_optical_mapping` ADD FOREIGN KEY (`molecule_file_optical_mapping_id`) REFERENCES `molecule_file_optical_mapping` (`molecule_file_optical_mapping_id`);

ALTER TABLE `aligned_optical_mapping` ADD FOREIGN KEY (`aligned_assembly_optical_mapping_id`) REFERENCES `aligned_assembly_optical_mapping` (`aligned_assembly_optical_mapping_id`);

ALTER TABLE `aligned_optical_mapping` ADD FOREIGN KEY (`aligned_molecules_optical_mapping_id`) REFERENCES `aligned_molecules_optical_mapping` (`aligned_molecules_optical_mapping_id`);

ALTER TABLE `aligned_optical_mapping_set` ADD FOREIGN KEY (`aligned_optical_mapping_id`) REFERENCES `aligned_optical_mapping` (`aligned_optical_mapping_id`);

ALTER TABLE `called_variants_optical_mapping` ADD FOREIGN KEY (`aligned_optical_mapping_set_id`) REFERENCES `aligned_optical_mapping_set` (`aligned_optical_mapping_set_id`);

ALTER TABLE `experiment_iclr` ADD FOREIGN KEY (`analyte_id`) REFERENCES `analyte` (`analyte_id`);

ALTER TABLE `experiment_iclr` ADD FOREIGN KEY (`unmarked_experiment_id`) REFERENCES `experiment_dna_short_read` (`experiment_dna_short_read_id`);

ALTER TABLE `aligned_iclr` ADD FOREIGN KEY (`experiment_iclr_id`) REFERENCES `experiment_iclr` (`experiment_iclr_id`);

ALTER TABLE `aligned_iclr_set` ADD FOREIGN KEY (`aligned_iclr_id`) REFERENCES `aligned_iclr` (`aligned_iclr_id`);

ALTER TABLE `called_variants_iclr` ADD FOREIGN KEY (`aligned_iclr_set_id`) REFERENCES `aligned_iclr_set` (`aligned_iclr_set_id`);

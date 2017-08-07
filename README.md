# SAS-Bioinformatics-Toolset
SAS scripts for various bioinformatics applications

1) microarray_glm.sas detects differentially expressed genes associated with quantitative traits from microarray datasets
using linear regression which includes gender and race as categorical variables. A sample data "exp_data.xlsx" is included.<br />
It works as follows:<br />
   i) Process a microarray expression matrix with different levels of headers including the phenotype (e.g. weight), gender and race;<br />
   ii) Build a linear regression model between each gene's expression profile and the phenotype which includes gender and race as categorical variable;<br />
   iii) Ouptut the pvalue of each gene into a dataset which is then corrected for multiple tests by the FDR method
   
2) retrieve_gene_info.sas retrieves genomic information from Ensembl Biomart output for a set gene names

3) microarray_merge_repeats.sas merges repeated measures of samples in microarray data

4) detailed_freq.sas merges two tables and then derives detailed frequencies for the 'weight' variable

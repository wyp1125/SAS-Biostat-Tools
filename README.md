# SAS-Bioinformatics-Toolset
SAS scripts for various bioinformatics applications

1) microarray_glm.sas detects differentially expressed genes associated with quantitative traits from microarray datasets
using linear regression which includes gender and race as categorical variables. A sample data "exp_data.xlsx" is included.
It works as follows:
  i) Process a microarray expression matrix with different levels of headers including the phenotype (e.g. weight), gender and race;
  ii) Build a linear regression model between each gene's expression profile and the phenotype which includes gender and race as categorical variable;
  iii) Ouptut the pvalue of each gene into a dataset which is then corrected for multiple tests by the FDR method

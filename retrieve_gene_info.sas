proc import datafile='/folders/myfolders/gene/ensembl.txt'
         out=ensembl
         dbms=dlm
         replace;
    delimiter='09'x;
    guessingrows=30000;
    run;
    

proc import datafile='/folders/myfolders/gene/gene_list.xlsx'
         out=gene
         dbms=xlsx
         replace;
         sheet=Sheet1;
         getnames=NO;
    run;

   
proc sql;
create table select_gene as
select distinct a.* from ensembl a, gene b 
where a.Gene_name=b.A and a.Chromosome_scaffold_name not like 'CHR%'
order by a.Gene_name;
run;

/*This program realizes a common microarray analysis procedure for quantiatitve traits.
1) Process microarray expression matrix with different levels of headers includding the
phenotype (e.g. weight), gender and race;
2) Build a linear regression model between each gene's expression profile and the phenotype
by considering gender and race;
3) Ouptut the pvalue of each gene into a dataset which is then corrected for multiple tests
by the FDR method*/   

/*Import raw expression matrix with multiple levels of headers.
Column names are coded by A, B, C,...*/
proc import datafile='/folders/myfolders/gene/exp.xlsx' out=temp
            dbms=xlsx replace;
            sheet=Sheet2;
            getnames=NO;
            run;

/*Code race and gender by numbers*/
proc format;
    value $ frace
    'African American'=1
    'Caucasian'=2;
    value $ gd
    'M'=1
    'F'=2;
run;

/*Process the raw expression matrix to partition headers and expression data*/
data exprs sam_ch sam_id;
set temp;
if anydigit(substr(A,1,1),1)>0 then
do;
rename A=id;
output exprs;
end;
else if find(A,"characteristics")>0 then
output sam_ch;
else if A='ID_REF' then
output sam_id;
run;

/*Output the variable names of the expression dataset*/
proc contents data=exprs out=vars(keep=name type);
run;

/*Add new variable names for data type conversion*/
data vars;                                                
set vars;                                                 
if type=2 and name ne 'id';                               
newname=trim(left(name))||"_n";

/*Store old and new variable names into macro variables*/
proc sql;
select trim(left(name)), trim(left(newname)),             
       trim(left(newname))||'='||trim(left(name))         
into :c_list separated by ' ', :n_list separated by ' ',  
     :renam_list separated by ' '                         
from vars;                                                
quit;

/*Process headers, convert data types and generate the phenotype dataset*/
data pheno;
set sam_ch;
where B contains 'weight';
id="weight";
array ch(*) $ &c_list;
array nu(*) &n_list;
do it=1 to dim(ch);
  nu(it)=input(substr(ch(it),24),percent.);
end;
drop it &c_list;                                           
rename &renam_list;
run;

/*Tanspose the phenotype dataset*/
proc transpose data=pheno out=pheno1 (drop=_label_);
var &c_list;
id id;
run;

/*Process headers to generate the gender dataset*/
data gender;
set sam_ch;
where B contains 'gender';
id='gender';
array ch(*) $ &c_list;
do it=1 to dim(ch);
  ch(it)=trim(left(substr(ch(it),9,1)));
end;
format &c_list gd.;
drop it;
run;

/*Tanspose the gender dataset*/
proc transpose data=gender out=gender1 (drop=_label_);
var &c_list;
id id;
run;

/*Process the headers to generate the race dataset*/
data race;
set sam_ch;
where B contains 'race';
id="race";
array ch(*) $ &c_list;
do it=1 to dim(ch);
  ch(it)=trim(left(substr(ch(it),6)));
end;
format &c_list frace.;
drop it;
run;                                           

/*Transpose the race dataset*/
proc transpose data=race out=race1 (drop=_label_);
var &c_list;
id id;
run;

/*Process expression data (convert character to numeric) to generate the expression dataset*/
data exprs1;                                               
set exprs;                                                 
array ch(*) $ &c_list;                                    
array nu(*) &n_list;                                      
do it= 1 to dim(ch);                                      
  nu(it)=input(ch(it),8.);                                  
end;                                                      
drop it &c_list;                                           
rename &renam_list;                                                                                      
run;

/*Transpose the expression dataset*/
proc transpose data=exprs1 out=exprs2 (drop=_label_);
var &c_list;
id id;
run;

/*Merge the transposed phenotype, gender, race and expression datasets for statistical analysis*/
data stat;
merge pheno1 gender1 race1 exprs2;
by _name_;
run;

/*Output the variables of the statistics dataset, i.e. probe_ids*/
proc contents data=stat out=stat_var (keep=name) noprint;
run;

/*Compute the total number of variables (probe_id only) and store it as a macro variable*/
data _NULL_;
dsid = open("stat_var");
obss = attrn(dsid,"NLOBS")-4;
call symput('nprob',compress(put(obss,5.)));
run;

/*Retrive all probe_ids and store them as macro variables*/
proc sql noprint;
select name into: pid1- :pid&nprob from stat_var
where name not in ('_name_','gender','race','weight');
run;

/*This macro constructs a linear regression model for the phenotype on each gene's expression profile,
gender and race, retrieves the p-value for the coefficient of each gene's expression profile, and
output all the pvalues to a dataset named "allp"*/
%macro comput;
%do it=1 %to &nprob;
proc glm data=stat outstat=ttt noprint;
class gender race;
model weight=race gender &&pid&it;
run;

data _NULL_;
ln=4;
set ttt point=ln;
call symputx("pva"||compress(put(&it,5.)),prob);
stop;
run;
%end;

data allp;
%do ii=1 %to &nprob;
gene="&&pid&ii";
pvalue="&&pva&ii";
output;
%end; 
run;
%mend;
%comput;

/*Process the pvalue dataset for multiple testing correction*/
data allp1;
set allp;
raw_p=input(pvalue,best.);
drop pvalue;
run;

/*Correct pvalues by the FDR approach*/
proc multtest inpvalues=allp1 FDR out=allp_adj;
run;

/*Print the probe_ids with significant pvalues*/
proc print data=allp_adj;
where fdr_p<0.05;
run;









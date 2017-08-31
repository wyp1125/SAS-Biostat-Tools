/*
 * This program merges repeated measures of samples in microarray data   
 */

libname ts "/folders/myfolders/gene/tissue";

proc import datafile='/folders/myfolders/gene/gnf.xlsx' out=temp
            dbms=xlsx replace;
            sheet=Sheet2;
            getnames=NO;
            run;
            
/*Disginguish headers and expression data*/                       
data ts.exprs ts.sam_ch ts.sam_id;
set temp;
if anydigit(substr(A,1,1),1)>0 then
do;
rename A=id;
output ts.exprs;
end;
else if find(A,"Sample_description")>0 then
output ts.sam_ch;
else if A='ID_REF' then
output ts.sam_id;
run;
        
/*Output the variable names of the expression dataset*/
proc contents data=ts.exprs out=vars(keep=name type);
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
run;

%put &n_list;

proc contents data=ts.exprs;

/*Process expression data (convert character to numeric) to generate the expression dataset*/
data ts.exprs1;                                               
set ts.exprs;                                                                              
array nu(*) $ &c_list;
array mu(*) &n_list;                   
do it= 1 to dim(nu);                                      
  mu(it)=input(nu(it),8.);                                  
end;                                                      
drop it &c_list;                                           
rename &renam_list;                                                                                      
run;

/*Transpose the expression dataset*/
proc transpose data=ts.exprs1 out=ts.exprs2 (drop=_label_);
var &c_list;
id id;
run;

data ts.pheno;
set ts.sam_ch;
id="tissue";
run;

proc transpose data=ts.pheno out=ts.pheno1 (drop=_label_);
var &c_list;
id id;
run;

data ts.pheno1;
set ts.pheno1;
tissue=lowcase(tissue);

/*merge tissue names and expression data*/

proc sort data=ts.pheno1;
by _name_;

proc sort data=ts.exprs2;
by _name_;

data ts.stat;
merge ts.pheno1 ts.exprs2;
by _name_;
drop _name_;
run;

/*merge repeats according to the same tissue name*/
proc means data=ts.stat noprint;
class tissue;
output out=ts.stat1 (drop=_type_) mean= ;
run;

libname test xlsx '/folders/myfolders/gene/dm_data.xlsx';

data dm;
set test.Obesity_data_read;
where BMI ne .;
run;

proc sort data=dm;
by id;
run;

data sm;
infile '/folders/myfolders/gene/exp_sam.txt' DLM='09'X DSD TRUNCOVER;
input tm1 $ tm2 $ sam $ @;
do while(sam ne '');
id=input(substr(sam,3,2),best.);
output;
input sam $ @;
end;
drop tm1 tm2;
run;

proc sort data=sm;
by id;
run;

data stat;
merge sm(in=rt) dm ;
by id;
Age=AatV1;
drop AatV1;
if rt;
run;

proc means data=stat noprint;
var age BMI;
class weight newrestrained;
output out=res(drop=_type_);
run;

ods rtf file='/folders/myfolders/gene/table1.rtf';
proc print data=res NOOBS label;
label weight="Weight status (1:over;0:normal)"
      newRestrained="Eating behavior(1:Restrained;0:nonrestrained)";
run;
ods rtf close;


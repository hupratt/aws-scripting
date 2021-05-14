libname EVDM "/opt/sas/software/config/Lev1/AppData/SASVisualAnalytics/VisualAnalyticsAdministrator/AutoLoad/EVDMLA" compress=yes;

data test;
set EVDM.audit_visualanalytics_restore (obs=500);
run;

data test2;
set EVDM.audit_visualanalytics_restore (obs=501);
run;

proc sql;
create table test3 as 
select * from WORK.test2 except select * from WORK.test;
quit;


proc append base=work.test data=work.test3;
run;

proc print data=work.test;
run;


data test;
set EVDM.audit_visualanalytics (obs=500);
run;




proc sql;
create table test3 as 
select datepart(min(timestamp_dttm)) as d1 format=DDMMYY10., datepart(max(timestamp_dttm)) as d2 format=DDMMYY10. from EVDM.audit_visualanalytics_restore;
quit;

proc sql;
create table test2 as 
select datepart(min(timestamp_dttm)) as d1 format=DDMMYY10., datepart(max(timestamp_dttm)) as d2 format=DDMMYY10. from EVDM.audit_visualanalytics;
quit;

proc means data=work.shoes mean sum maxdec=2;
data work.shoes;
	set sashelp.shoes;
	NetSales=Sales-Returns;
	Whatever=Sales;
run;

proc means data=work.shoes mean sum maxdec=2;
	var NetSales;
	class region;
run;

PROC CONTENTS data="~/EPG194/data/storm_summary.sas7bdat";
run;

/* Create a library

LIBNAME libref engine "PATH" */
/* Closes the connection to the library

LIBNAME libref clear */
/* Summarize data

proc contents data=libref.tablename; run; */
LIBNAME PG1 base "~/EPG194/data/storm_summary.sas7bdat";
LIBNAME NP xlsx "~/EPG194/data/np_info.xlsx";

PROC CONTENTS data=NP.parks;
run;

LIBNAME NP clear;

/* Import and create a coy of the excel file

proc import datafile="libref" DBMS=filetype OUT=output-table; RUN; */
proc import datafile="~/EPG194/data/storm_damage.tab" dbms=tab 
		out=storm_damage_tab replace;
run;

/* common statistics procedures */
proc print data=pg1.np_summary (obs=20);
	VAR Reg Type ParkName DayVisits TentCampers RVCampers;
run;

proc means data=pg1.np_summary;
	VAR DayVisits TentCampers RVCampers;
run;

proc univariate data=pg1.np_summary;
	VAR DayVisits TentCampers RVCampers;
run;

proc freq data=pg1.np_summary;
	Tables Reg Type;
run;

/* Species_ID starts with YOSE (Yosemite National Park) and Category equals Mammal. */
%let ParkCode=ZION;
%let SpeciesCat=Bird;

proc freq data=pg1.np_species;
	Tables Abundance Conservation_Status;
	WHERE Species_ID like "&ParkCode%" and Category="&SpeciesCat";
run;

proc print data=pg1.np_species;
	VAR Species_ID Category Scientific_Name Common_Names;
run;

proc sort data=PG1.NP_SUMMARY out=NP_SORT;
	WHERE type="NP";
	BY Reg descending DayVisits;
run;

proc sort data=PG1.np_largeparks out=park_clean dupout=park_dups noduprecs;
	BY _all_;
run;

data Storm_cat5;
	set pg1.storm_summary;
	WHERE MaxWindMPH>156 and StartDate >="01JAN2000"d;
	keep Season Basin Name Type MaxWindMPH;
run;

data EU_OCC2016;
	set PG1.EU_OCC;
	where YearMon like "2016%";
	*where ShortStay >= "1Jan2016"d and ShortStay < "1Jan2017"d;
	format Hotel COMMA17. ShortStay COMMA17. Camp COMMA17.;
	drop Geo;
run;

/*
Category is Mammal and Common_Names includes Fox.
*/
data fox;
	set pg1.np_species;
	WHERE Category ="Mammal" and Common_Names like "%Fox%" and Common_Names not like "%Squirrel%";
	DROP Category Record_Status Occurrence Nativeness;
run;

proc sort data=fox;
	by Common_Names;
run;


data pacific;
	set pg1.storm_summary;
	drop Type Hem_EW Hem_NS MinPressure Lat Lon;
	WHERE SUBSTR(Basin,2) = "P";
	*Add a WHERE statement that uses the SUBSTR function;
run;

data eu_occ_total;
	set pg1.eu_occ;
	Year=substr(YearMon,1,4);
	Month=substr(YearMon,6,2);
	ReportDate=MDY(Month,1, Year);
	Format Hotel ShortStay Camp Total COMMA11. ReportDate MONYY7.;
run;

/* pg1.np_summary */

data parks monuments;
	set pg1.np_summary;
	if Type="NP" THEN DO;
		ParkType="Park";
		output parks;
	end;
	if Type="NM" THEN DO;
		ParkType="Monument";
		output monuments;
	end;
	Keep Reg ParkName DayVisits OtherLodging Campers ParkType;
run;


proc freq data=pg1.storm_final order=freq noprint;
	tables StartDate / out= storm_count;
	tables BasinName / out= basin_count;
	format StartDate monname.;
	label BasinName="MONTH_COUNT"
		StartDate="BASIN_COUNT";
run;

ods graphics on;
ods noproctitle;
title "Categories of Reported Species";
title2 "in the Everglades";
proc freq data=pg1.np_species ORDER=FREQ;
	tables Category / NOCUM PLOTS=FREQPLOT;
	WHERE Species_ID like "EVER%" and Category NE "Vascular Plant";
run;
title;



title "Park Types by Region";
proc freq data=pg1.np_codelookup ORDER=FREQ;
	tables Type*Region / norow nocol nopercent;
	WHERE Type not like "%Other%";
run;
title;


ods graphics on;
ods noproctitle;
proc freq data=pg1.np_codelookup ORDER=FREQ;
	tables Type*Region /CROSSLIST
		plots=freqplot(groupby=row scale=grouppercent orient=horizontal);
	WHERE Type not like "%Other%" and Type in ("National Historic Site", "National Monument", "National Park");
run;


proc means data=pg1.storm_final mean min n maxdec=0;
	var MinPressure;
	where Season >=2010;
	class Season Ocean;
	ways 1;
run;

proc means data=pg1.np_westweather noprint;
    where Precip ne 0;
    var Precip;
    class Name Year;
    ways 2;
    output out=rainstats n=RainDays sum=TotalRain;
run;


title1 'Rain Statistics by Year and Park';
proc print data=rainstats label noobs;
    var Name Year RainDays TotalRain;
    label Name='Park Name'
          RainDays='Number of Days Raining'
          TotalRain='Total Rain Amount (inches)';
    sum TotalRain;
run;
title;

title1 'The First Line';
title2 'The Second Line';
proc print data=rainstats;
run;
title2 'The Next Line';
proc print data=rainstats;
run;
title 'The Top Line';
proc print data=rainstats;
run;


proc freq data=sashelp.cars;
    where Cylinders in (4,6) and Type in ('Sedan','SUV');
    tables Type*Cylinders / nocol norow crosslist;
run;

%let outpath=~/EPG194/output;

/*exporting to excel libname, proc export, or ods*/

proc export data=pg1.storm_final
	outfile="&outpath/storm_final.csv";
run; 


libname xl_lib xlsx "&outpath/storm.xlsx";

data xl_lib.storm_final;
	set pg1.storm_final;
	drop Lat Lon Basin OceanCode;
run;

libname xl_lib clear;


ods excel file="&outpath/StormStats.xlsx"
    style=snow
    options(sheet_name='South Pacific Summary');
ods noproctitle;

proc means data=pg1.storm_detail maxdec=0 median max;
    class Season;
    var Wind;
    where Basin='SP' and Season in (2014,2015,2016);
run;

ods excel options(sheet_name='Detail');

proc print data=pg1.storm_detail noobs;
    where Basin='SP' and Season in (2014,2015,2016);
    by Season;
run;

ods excel close;
ods proctitle;


/*exporting to rtf*/


ods rtf file="&outpath/ParkReport.rtf" style=Journal startpage=no;

ods noproctitle;
options nodate;

title "US National Park Regional Usage Summary";

proc freq data=pg1.np_final;
    tables Region /nocum;
run;

proc means data=pg1.np_final mean median max nonobs maxdec=0;
    class Region;
    var DayVisits Campers;
run;

ods rtf style=SASDocPrinter;

title2 'Day Vists vs. Camping';
proc sgplot data=pg1.np_final;
    vbar  Region / response=DayVisits;
    vline Region / response=Campers;
run;
title;

ods proctitle;
ods rtf close;
options date;


/* exp two work sheets */

libname sales xlsx "&outpath/midyear.xlsx";
 
data pg1.stormYY; 
    set pg1.storm_detail; 
run; 
data pg1.stormDD; 
    set pg1.storm_final; 
run;

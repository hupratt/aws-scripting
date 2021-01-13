***********************************************************;
*  LESSON 1                                               *;
***********************************************************;

/*
The SAS language
1. libraries provide a way for everyone to 
access the structured data without having to care
about data format and providing the full path location
2. no indentation, no case sensitivity
3. lib ref (pointer) destroys after session is terminated. 
librefs also create a lock that prevents others from using it at the same time. 
4. Using _ALL_ in the BY statement sorts by all columns and ensures that 
duplicate rows are adjacent in thesorted table and are removed. 
*/

/* 
Data step: copy the library sashelp.shoes, store it in the library work.shoes
and create a new variable/column
*/
data work.shoes;
	set sashelp.shoes;
	NetSales=Sales-Returns;
	Whatever=Sales;
run;

/* Reading meta data */
PROC CONTENTS data="~/EPG194/data/storm_summary.sas7bdat";
run;
PROC CONTENTS data=NP.parks;
run;

/* Create a libref */
LIBNAME PG1 base "~/EPG194/data/storm_summary.sas7bdat";
LIBNAME NP xlsx "~/EPG194/data/np_info.xlsx";

/* Delete the libref so that others can connect to the data (remove lock)*/
LIBNAME NP clear;

/* Import and create a sas table from an excel file */
proc import datafile="~/EPG194/data/storm_damage.tab" dbms=tab 
		out=storm_damage_tab replace;
run;

/* create sas table from csv */
proc import datafile="~/ECRB94/data/payroll.csv" out=payroll dbms=csv replace;
    guessingrows=max; *Specifies the number of rows of the file to scan to determine the appropriate data type and length for the variables.;
run;

/* create sas table from xlsx */
proc import datafile="~/ECRB94/data/employee.xlsx" out=employee dbms=XLSX 
		replace;
run;

/* print xlsx contents */
options validvarname=v7;
libname xl xlsx "&path/employee.xlsx";
proc contents data=xl._all_;
run;


/* Common statistics procedures */
proc print data=pg1.np_summary (obs=20);
	VAR Reg Type ParkName DayVisits TentCampers RVCampers;
run;

proc print data=cr.dates;
format FormattedDate  ddmmyy10.;
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

proc means data=work.shoes mean sum maxdec=2;
	var NetSales;
	class region;
run;

proc means data=cr.employee noprint;
    var Salary;
    class Department City;
    output out=salary_summary mean=AvgSalary sum=TotalSalary;
    ways 2;
run;

/* Macro variables */
%let ParkCode=ZION;
%let SpeciesCat=Bird;

proc freq data=pg1.np_species order=freq;
	Tables Abundance Conservation_Status;
	WHERE Species_ID like "&ParkCode%" and Category="&SpeciesCat";
run;

/* Sorting the data and creating 4 tabs: NP_SUMMARY, np_largeparks, Storm_cat, park_dups */

proc sort data=PG1.NP_SUMMARY out=NP_SORT;
	WHERE type="NP";
	BY Reg descending DayVisits;
run;

proc sort data=PG1.np_largeparks out=park_clean dupout=park_dups noduprecs;
	BY _all_;
run;

data Storm_cat;
	set pg1.storm_summary;
	WHERE MaxWindMPH>156 and StartDate >="01JAN2000"d;
	keep Season Basin Name Type MaxWindMPH;
run;

/* Data + filter+ sorting the data output */
data fox;
	set pg1.np_species;
	WHERE Category ="Mammal" and Common_Names like "%Fox%" and Common_Names not like "%Squirrel%";
	DROP Category Record_Status Occurrence Nativeness;
run;

proc sort data=fox;
	by Common_Names;
run;

/* Functions SUBSTR, MDY */

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

/* IF THEN DO */

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

data bonus;
    set cr.employee;
    where TermDate is missing;
    YearsEmp=yrdif(HireDate, "01JAN2019"d, "age");
    if YearsEmp >= 10 then do;
	     Bonus=Salary*.03;
       Vacation=20;
    end;
    else do;
	     Bonus=Salary*.02;
	     Vacation=15;
    end;
run;

/* Splitting into two tabs */
proc freq data=pg1.storm_final order=freq noprint;
	tables StartDate / out= storm_count;
	tables BasinName / out= basin_count;
	format StartDate monname.;
	label BasinName="MONTH_COUNT"
		StartDate="BASIN_COUNT";
run;

/* Frequency plot */
ods graphics on;
ods noproctitle;
title "Categories of Reported Species";
title2 "in the Everglades";
proc freq data=pg1.np_species ORDER=FREQ;
	tables Category / NOCUM PLOTS=FREQPLOT;
	WHERE Species_ID like "EVER%" and Category NE "Vascular Plant";
run;
title;


/* Cross tab analysis */
title "Park Types by Region";
proc freq data=pg1.np_codelookup ORDER=FREQ;
	tables Type*Region / norow nocol nopercent;
	WHERE Type not like "%Other%";
run;
title;


/* Cross tab analysis + freq plot */
ods graphics on;
ods noproctitle;
proc freq data=pg1.np_codelookup ORDER=FREQ;
	tables Type*Region /CROSSLIST
		plots=freqplot(groupby=row scale=grouppercent orient=horizontal);
	WHERE Type not like "%Other%" and Type in ("National Historic Site", "National Monument", "National Park");
run;

/* Cross tab analysis */
proc freq data=sashelp.cars;
    where Cylinders in (4,6) and Type in ('Sedan','SUV');
    tables Type*Cylinders / nocol norow crosslist;
run;

/* One Way mean analysis */
proc means data=pg1.storm_final mean min n maxdec=0;
	var MinPressure;
	where Season >=2010;
	class Season Ocean;
	ways 1;
run;

/* Two Way mean analysis and change column headers */
proc means data=pg1.np_westweather noprint;
    where Precip ne 0;
    var Precip;
    class Name Year;
    ways 2;
    output out=rainstats n=RainDays sum=TotalRain;
run;

/* Poc print with labels */
title1 'Rain Statistics by Year and Park';
proc print data=rainstats label noobs;
    var Name Year RainDays TotalRain;
    label Name='Park Name'
          RainDays='Number of Days Raining'
          TotalRain='Total Rain Amount (inches)';
    sum TotalRain;
run;
title;

/* Testing titles */
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



/* Exporting to excel libname, proc export, or ods */

%let outpath=~/EPG194/output;
proc export data=pg1.storm_final
	outfile="&outpath/storm_final.csv"
	dbms=csv replace;
run; 


/*  This LIBNAME statement creates the storm.xlsx file if it does not exist. */
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


/* More stats */
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

***********************************************************;
*  LESSON 2                                               *;
***********************************************************;

/* Limiting data intake and logging to the console */
data np_parks;
	set pg2.np_final(obs=5);
	putlog "NOTE:hello";
	length size $6;
	keep Region ParkName AvgMonthlyVisitors Acres Size;
    where Type="PARK";
    putlog column=Type;
	format AvgMonthlyVisitors Acres comma10.;
    Type=propcase(Type);
	AvgMonthlyVisitors=sum(DayVisits,Campers,OtherLodging)/12;
	if Acres<1000 then Size="Small";
	else if Acres<100000 then Size="Medium";
	else Size="Large";
run;

/* Outputing to different tables*/

data camping(keep=ParkName Month DayVisits CampTotal) lodging(keep=ParkName 
		Month DayVisits LodgingOther);
	set pg2.np_2017;
	CampTotal=CampingOther+CampingTent+CampingRV+CampingBackcountry;
	Format CampTotal COMMA7.;

	if CampTotal>0 THEN
		output camping;

	if LodgingOther>0 THEN
		output lodging;
run;

/* Strange behavior: this creates two blank 
integer columns '.' no error is produced*/

data work.boots; 
    set sashelp.shoes(keep=Product Subsidiary);
    where Product='Boot';
    NewSales=Sales*1.25;
run;

/* number to datetime */

data test;
	set work.test;
	*new=(sdcreateven*0.001)+"01jan1970 0:0:0"dt ;
	new=(_TEMG001*0.001)+"01jan1970 0:0:0"dt ;
	Format new datetime23.3;
run;


/* Create an accumulator */

data zurich2017;
	set pg2.weather_zurich;
	*Add a RETAIN statement;
	retain TotalRain 0;
	TotalRain=SUM(TotalRain,Rain_mm);
	DayNum+1;
run;


data work.parktypetraffic;
    set pg2.np_yearlyTraffic;
    where ParkType in ("National Monument", "National Park");
    if ParkType = 'National Monument' then MonumentTraffic+Count;
    else ParkTraffic+Count;
    format MonumentTraffic ParkTraffic comma15.;
run;

/* Get the highest wind speed per Basin group */

/* If statements run during the execution
 phase whereas WHERE statements run in the
 compilation phase */

proc sort data=pg2.storm_2017 out=storm2017_sort;
	by Basin MaxWindMPH;
run;

data storm2017_max;
	set storm2017_sort;
	by Basin MaxWindMPH;
	StormLength=EndDate-StartDate;
	MaxWindKM=MaxWindMPH*1.60934;
	if last.basin=1;
	First=first.basin;
	Last=last.basin;
run;


proc print data=storm2017_max;
	where Last=1;
run;


/* Mean function */

data quiz_summary;
	set pg2.class_quiz;
	Name=UPCASE(Name);
	Mean1=mean(Quiz1, Quiz2, Quiz3, Quiz4, Quiz5);
	/* Numbered Range: col1-coln where n is a sequential number */ 
	Mean2=mean(of Quiz1-Quiz5);
	/* Name Prefix: all columns that begin with the specified character string */ 
	Mean3=mean(of Q:);
run;

/*How many weeks between two dates? */

data storm_length;
	set pg2.storm_final(obs=10);
	keep Season Name StartDate Enddate StormLength WeeksD WeeksC;
	WeeksD=intck('week', StartDate, EndDate, 'D');
	WeeksC=intck('week', StartDate, EndDate, 'C');
run;

/* Average, largest, mean */

data stays;
	set pg2.np_lodging;
	keep Park Stay:;
	Stay1= LARGEST(1, of CL:);
	Stay2= LARGEST(2, of CL:);
	Stay3 = LARGEST(3, of CL:);
	StayAvg= round(MEAN(of CL:));
	if StayAvg>0;
	format Stay: comma11.;
run;

/* Date shift and date extraction from datetime column */

data rainsummary;
	set pg2.np_hourlyrain;
	by Month;
	if first.Month=1 then MonthlyRainTotal=0;
	MonthlyRainTotal+Rain;
	if last.Month=1;
	Date=datepart(DateTime);
	Time=timepart(DateTime)
	MonthEnd=INTNX('month', Date, 0, 'end');
	format MonthEnd Date date9. Time time.;
	keep StationName MonthlyRainTotal Date MonthEnd;
run;

/* Remove hyphens and spaces as well as double spaces */
data weather_japan_clean;
    set pg2.weather_japan;
    NewLocation= COMPBL(Location);
    NewStation= COMPRESS(Station, '- ');*remove dashes and spaces;
run;

/* CHAR manipulations: compbl, propcase, scan and strip */

data weather_japan_clean;
	set pg2.weather_japan;
	Location=compbl(Location);
	City=propcase(scan(Location, 1, ','), ' ');
	Prefecture=strip(scan(Location, 2, ',')); *remove trailing space;
	putlog Prefecture $quote20.;
	if Prefecture="Tokyo";
run;

/* CAT, CATS, CATX*/

data storm_id;
	set pg2.storm_final;
	keep StormID: ;
	Day=StartDate-intnx('year', StartDate, 0);
	StormID1=cat(Name, Season, Day);
	StormID2=cats(Name, '-', Season, Day); *ALFRED-201746;
	StormID3=catx('-', Name, Season, Day); *ALFRED-2017-46;
run;

/* Grab last part of a string 
and store it into another column */

data clean_traffic;
	set pg2.np_monthlytraffic;
	length Type $5;
	Type=SCAN(ParkName,-1," ");
	drop Year;
	Region=UPCASE(COMPRESS(Region));
	Location=PROPCASE(Location);
run;

/* Replace string with another with TRANWRD */

data parks;
	set pg2.np_monthlytraffic;
	where ParkName like '%NP';
	Park=COMPBL(SUBSTR(ParkName,1,FIND(ParkName,'NP')-1));
	Location=COMPBL(PROPCASE(Location));
	Gate=compbl(TRANWRD(Location, 'Traffic Count At', ''));
	GateCode=CATS(ParkCode, '-', Gate);

run;


/* Renaming columns */

data stocks2;
   set pg2.stocks2(rename=(Volume=CharVolume Date=CharDate));
   Volume=input(CharVolume,comma12.);
   Date=input(CharDate, date9.);
   
   drop Char:;
   format Date date9.;
run;

/* add a FORMAT statement */

data work.stocks;
    set pg2.stocks;
    CloseOpenDiff=Close-Open;
    HighLowDiff=High-Low;
    format Date WORDDATE. volume comma17. CloseOpenDiff HighLowDiff dollar7.2;
run;

/* Custom char formats */

proc format;
    value $genfmt 'F'='Female'
                  'M'='Male';
    value HRANGE low-57 = 'Below Average'
                      57<-60 = 'Average'
                      60<-high = 'Above Average' 
                      . = 'miscoded';
    value $region 'NA'='Atlantic'
                  'WP','EP','SP'='Pacific'
                  'NI','SI'='Indian'
                  ' '='Missing'
                  other='Unknown';
run;

proc print data=pg2.class_birthdate noobs;
    where Age=12;
    var Name Gender Height;
    *add to the following FORMAT statement;
    format Gender $genfmt. Height HRANGE.;
run;

/* Use a put format to apply 
the formats directly on the data */

data storm_summary;
    set pg2.storm_summary;
    Basin=upcase(Basin);
    BasinGroup=put(Basin, $region.);
run;


/* Custom format for tables: practice p204p04 */


data type_lookup;
    set pg2.np_codeLookup(rename=(ParkCode=Start Type=Label));
    retain FmtName "$TypeFmt";
    keep Start Label FmtName;
run;

proc format CNTLIN=type_lookup;
run;

title 'Traffic Statistics';
proc means data=pg2.np_monthlyTraffic maxdec=0 mean sum nonobs;
    var Count;
    class ParkCode Month;
    label ParkCode='Name';
    format ParkCode $TypeFmt.;
run;
title;

/* Creating a test dataset */

data inventory;
   input InStock QuantitySold Idnum 8-11 Item $ 13-18;
   datalines;
100 52 1001 hammer
345 49 1020 saw
237 55 2003 wrench
864 65 3015 shovel
932 38 4215 rake
;
run;

/* Difference between two dates */

DATA _NULL_;
date1 = datepart(datetime());
date2 = "26AUG2020"d;
days_in_between = date2 - date1;
PUT days_in_between = ;
RUN;


/* concatenate two datasets with the same columns 
on top of one another*/

data class_current;
    set sashelp.class pg2.class_new2(rename=(Student=Name));
run;

data work.np_combine;
    set pg2.np_2015 pg2.np_2016;
    drop Camping:;
    WHERE month in (6, 7, 8) and ParkCode='ACAD' ;
    CampTotal=SUM(of Camping:);
    format CampTotal comma7.;
run;


/* Merging datasets requires sorting beforehand */

data work.test1;
set pg2.np_codelookup;
run;

data work.test2;
set pg2.np_2016;

run;

proc sort data=test1;
by ParkCode;
run;

proc sort data=test2;
by ParkCode;
run;

data parkStats(keep=ParkCode ParkName Year Month DayVisits) parkOther(keep=ParkCode  ParkName );
merge test1 test2;
by ParkCode;
if missing(DayVisits) then ouput parkOther;
else output parkStats;
run;

data t1;
set sashelp.cars(obs=10);
keep make model;
run;

data t2;
set sashelp.cars(obs=2);
keep make model origin;
run;

data m;
merge t1 t2;
run;

***********************************************************;
*  LESSON 3                                               *;
***********************************************************;

/* tinkering with do loops and financial placements */
data retirement;
	interest=0.075;

	do Year=1 to 6;
		Invest+10000;

		do Quarter=1 to 4;
			Invest+(Invest*(.075/4));
		end;
		output;
	end;
run;

title1 'Retirement Account Balance per Year';

proc print data=retirement(drop=Quarter) noobs;
	format Invest dollar12.2;
run;

title;

/* DO while loop with modulo*/
data IncreaseDayVisits;
	set pg2.np_summary;
	where Reg='NE' and DayVisits<100000;
	IncrDayVisits=DayVisits;
	i=0;
	year=1;

	do while (IncrDayVisits<=100000);
		IncrDayVisits=IncrDayVisits*1.06;

		if mod(i, 12)=0 and i NE 0 then
			year+1;
		i +1;
		output;
	end;
	format IncrDayVisits comma12.;
	keep ParkName DayVisits IncrDayVisits i year;
run;

/* Keep last row only and remove duplicates*/
data class_wide;
	set pg2.class_test_narrow;
	by Name;
	retain Name Math Reading;
	keep Name Math Reading;

	if TestSubject="Math" then
		Math=TestScore;
	else if TestSubject="Reading" then
		Reading=TestScore;

	if last.name=1 then
		output;
run;

/* Transposing columns into rows */

proc print data=sashelp.class;
run;

proc transpose data=sashelp.class out=class_t;
	id Name;
	*adds the column names;
	var Height Weight;
	*filters the rows;
run;

/* Narrow table into wide table*/

data work.camping_narrow(drop=Tent RV Backcountry);
	set pg2.np_2017Camping;
	format CampCount comma12.;
	CampType='Backcountry';
	CampCount=Backcountry;
	output;
	CampType='Tent';
	CampCount=Tent;
	output;
	CampType='RV';
	CampCount=RV;
	output;

	*Add statements to output rows for RV and Backcountry;
run;

proc transpose data=pg2.np_2016camping 
               out=work.camping2016_transposed(drop=_name_);
    by ParkName;
    id CampType;
    var CampCount;
run;

/* Wide table into narrow table*/


data work.camping_wide(keep=Parkname RV Backcountry Tent);
	set pg2.np_2016camping;
	by ParkName;
	retain RV Backcountry Tent;
	if CampType='RV' then RV=CampCount;
	else if CampType='Backcountry' then Backcountry=CampCount;
	else if CampType='Tent' then Tent=CampCount;
	if last.ParkName=1;
run;

proc transpose data=pg2.np_2017camping 
		out=work.camping2017_t(rename=(COL1=Count)) NAME=Location;
	by ParkName;
	var Backcountry Tent RV;
run;


/* List all tables in a lib */

proc contents data=cr._all_ nods;
run;

/* Create a local variable DiffLignes that is the difference between two dataset sizes */

%MACRO Stats;
	proc sql noprint;
	   select count(*)
	      into :DS_CONTRAT_AVT_LIGNES
	      from SBPRH.DS_CONTRAT_AVT;
	quit;

	proc sql noprint;
	   select count(*)
	      into :DS_CONTRAT_AVT_PREV_RUN_LIGNES
	      from SBPRH.DS_CONTRAT_AVT_PREV_RUN;
	quit;
	%let DiffLignes=%SYSEVALF(&DS_CONTRAT_AVT_LIGNES -&DS_CONTRAT_AVT_PREV_RUN_LIGNES);

%MEND Stats;

%Stats;

%MACRO SendEmail;
	FILENAME Mailbox EMAIL;
 	DATA _NULL_;
	FILE Mailbox to=("sendto@him.com") subject='Subject' from='SENDER' CONTENT_TYPE="text/html"
	attach=("/data/sas/exports/LOG.csv"  content_type="application/vnd.ms-excel");
	put "<html><head>";
	put "<style type='text/css' MEDIA=screen><!--";
	put "body { color: #346170; font-family: Verdana; font-size: 10pt; }";
	put "--></style></head><body>";
	PUT "Bonjour,";
	put "<p> Cordialement </p>";
	put "</body></html>"; 
	RUN;	
%MEND SendEmail;

%SendEmail;


/* source: https://github.com/srosanba/sas-comparewarn/blob/master/src/CompareWarn.sas
and http://support.sas.com/resources/papers/proceedings12/063-2012.pdf */
%macro CompareWarn;

   %*--- capture &sysinfo before data _null_ wipes it out ---;
   %local CompareCode;   
   %let CompareCode = &sysinfo;
   
   data errors;
      CompareCode = &CompareCode;
      %*--- all possible return code meanings for PROC COMPARE ---;
      array msg(16) $60 _temporary_ (
         "Les en-têtes de certaines colonnes sont différents                                       ",  /* 1*/
         "Les types de données sont différents",                                                       /* 2*/
         "Certaine(s) variable(s) ont un format d'entrée différent",                                   /* 3*/
         "Certaine(s) variable(s) ont un format différent",                                            /* 4*/
         "Certaine(s) variable(s) ont une longueur différente",                                        /* 5*/
         "Certaine(s) variable(s) ont des en-têtes différents",                                        /* 6*/
         "Le dataset précédent a des observation(s) qui ne sont pas dans le nouveau dataset",          /* 7*/
         "Le nouveau dataset a des observation(s) qui ne sont pas dans le dataset précédent",          /* 8*/
         "Le dataset précédent a des groupement BY qui ne se retrouvent pas dans le nouveau dataset",  /* 9*/
         "Le nouveau dataset a des groupement BY qui ne se retrouvent pas dans le dataset précédent",  /*10*/
         "Le dataset précédent a des variable(s) qui ne se retrouvent pas dans le nouveau dataset",    /*11*/
         "Le nouveau dataset a des variable(s) qui ne se retrouvent pas dans le dataset précédent",    /*12*/
         "Une comparaison retourne une valeur différente",                                             /*13*/
         "Le types de certaine(s) variables diffèrents",                                               /*14*/
         "Les variables du groupement BY ne correspondent pas"                                         /*15*/
         );

      if CompareCode > 0 then do k = 1 to 15;
         match = band(2**(k-1),CompareCode);
         if match > 0 then 
		error=msg(k);
		output;
      end;
   run;

%mend CompareWarn;
%CompareWarn;

/* Char to number in sql */

proc sql;
  create table work.steps as 
  select car_make,
         car_type,
         input(count,best.) as count
  from work.car_overall;
quit; 

/* Number to char in sql */

proc sql;
  create table work.steps as 
  select car_make,
         car_type,
         put(account_number, 15.) as account_number
  from work.car_overall;
quit; 


/* DO ELSE in macros */

%macro MyMacro;
%if nomtab = "lauto"  %then
	%do;
	PROC COMPARE BASE=DEXZOS.LAUTO COMP=DBHSSD.LAUTO_202006
	BRIEF NOVALUES;
	%end;				
	%else
	%do;
	PROC COMPARE BASE=DEXZOS.&&table_&i COMP=&thislib..&&table_&i 
	BRIEF NOVALUES;
	%end;
%mend MyMacro;
%MyMacro;

/* Find records without a counterpart on the other table */
proc sql noprint;
	create table DESTIN.TEMP_except as
	(SELECT Avt_Gen_NPolice,Avt_Gen_NAvenantInterne,Avt_Gen_NAvenantClient,Avt_Gen_Date from DESTIN.DS_CONTRAT_AVT_PREV_RUN
	EXCEPT
	SELECT Avt_Gen_NPolice,Avt_Gen_NAvenantInterne,Avt_Gen_NAvenantClient,Avt_Gen_Date from DESTIN.DS_CONTRAT_AVT)
	UNION
	(SELECT Avt_Gen_NPolice,Avt_Gen_NAvenantInterne,Avt_Gen_NAvenantClient,Avt_Gen_Date from DESTIN.DS_CONTRAT_AVT
	EXCEPT
	SELECT Avt_Gen_NPolice,Avt_Gen_NAvenantInterne,Avt_Gen_NAvenantClient,Avt_Gen_Date from DESTIN.DS_CONTRAT_AVT_PREV_RUN);
quit;

/* reformat results from the linux dd command */

data tests_hdd_auj_;
	length vitesse $20;
	set tests_hdd_auj;
	if find(vitesse,'gb','i') ge 1 THEN vitesse_num=input(SUBSTR(vitesse,1,find(vitesse,'gb','i')-1),best.);
	if find(vitesse,'mb','i') ge 1 THEN vitesse_num=input(SUBSTR(vitesse,1,find(vitesse,'mb','i')-1),best.);
run;

/* Read a csv in, once read in if table is empty delete */

data testdata;

    INFORMAT
        NOEV             $CHAR13.
        'SOURCE GESTION - INSPECTION'n $CHAR17.
        'SOURCE EXPERTS'n $CHAR11.
        'SOURCE LISTINGS'n $CHAR44.
        'DATE DE REMONTEE'n MMDDYY10.
        'Enquête/avis LEG'n BEST1.
        GEST             $CHAR11.
        'N° CLIENT'n     $CHAR10.
        NOM              $CHAR68.
        AGENT            $CHAR46.
        BRANCHE          $CHAR10.
        GARANTIE         $CHAR23.
        'DATE SIN'n      MMDDYY10.
        'ACCUSE DE RECEPTION SOUS 48H'n $CHAR1.
        'AVIS SOUS 72H'n $CHAR1.
        CIRCONSTANCES    $CHAR68.
        ENJEU            $CHAR14.
		'Gain Réel'n     $CHAR14.
        DECISION         $CHAR8.
        REMARQUES        $CHAR94.
        'Charges DAV'n   BEST1.
        'Charges LEG'n   BEST1.
        'Date Cloture'n  $CHAR11.
        'Pertinence du dossier remontée'n $CHAR1.
        'Date rappel'n   DDMMYY10. ;

	infile "/data/mycute.csv"
          LRECL=294
        ENCODING="UTF-8"
        TERMSTR=CRLF
        DLM='7F'x
        MISSOVER
        DSD ;

run;


/* Prevent log tables from getting too big by applying a filter on the datetime value */
data DLKDST.tests_hdd;
	set DLKDST.tests_hdd;
	where date>=intnx('dtday',datetime(),-7,'B');
run;

/* Random task that takes long time to process */

data RandData;
   do i=1 to 10e7;
      x=ceil(10*rand('uniform'));
      output;
   end;
run;

/* testTableCreation macro */
%macro testTableCreation;
    %if %sysfunc(exist(QUAL_DS_CONTRAT_Summary_2)) %then %do;
		data SBPRH.QUAL_DS_CONTRAT_Summary_2;
		TestFormats='OK';
		run;
    %end;
    %else %do;
		data SBPRH.QUAL_DS_CONTRAT_Summary_2;
		TestFormats='KO';
		run;
    %end;
%mend testTableCreation;
%testTableCreation;

/* Creating and using a custom format */

proc format library=DLSNST;
value bbest
other = [BESTDOTX12.];

options fmtsearch = (DLSNST.formats);

proc format
library = DLSNST.formats fmtlib;
select BBEST;
run;

usage in datastep or any other procedure:
input("1221.242248238723872387283", BBEST.);

/* Saving the size of a dataset into a macro variable */

data audit_visualanalyticsBKP;
    set EVDMLA.audit_visualanalytics nobs=n;
	where datepart (timestamp_dttm) between '13Jan2021'd and '13Jan2021'd;
run;

data _null_;
	call symputx("size",size);
	stop;
	set audit_visualanalyticsBKP nobs=size;
run;

%put &size;

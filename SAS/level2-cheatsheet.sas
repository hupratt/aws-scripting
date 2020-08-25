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

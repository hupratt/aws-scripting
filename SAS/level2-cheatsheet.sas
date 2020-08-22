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
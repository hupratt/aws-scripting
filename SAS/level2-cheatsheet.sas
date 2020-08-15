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
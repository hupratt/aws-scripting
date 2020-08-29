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





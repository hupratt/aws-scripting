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

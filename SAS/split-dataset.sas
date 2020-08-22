/*

source: https://communities.sas.com/t5/SAS-Programming/Macro-to-Split-a-SAS-data-set/td-p/525776

This macro splits a data set into data sets of size N. 
The parameters requried are:

1. DSN = input data set name, such as sashelp.cars. 
   The libname should be included unless the data set
   is in the work library.
2. Size = Number of records to be included in each data 
   set. Note that the last data set will be truncated, 
   ie if only 28 records are available only 28 will be 
   written to the output data set.
3. outDsnPrefix = Name of output data sets, will be indexed as 
      outDSNPrefix1
      outDSNPrefix2
      outDSNPrefix3
*/

%macro split (dsn=, size=, outDsnPrefix=Split);

    %*Get number of records and calculate the number of files needed;
    data _null_;
        set &dsn. nobs=_nobs;
        call symputx('nrecs', _nobs);
        n_files=ceil(_nobs/ &size.);
        call symputx('nfiles', n_files);
        stop;
    run;

    %*Set the start and end of data set to get first data set;
    %let first=1;
    %let last=&size.;
    
    %*Loop to split files;
    %do i=1 %to &nfiles;
    
        %*Split file by number of records;
        data SBPRH.&outDsnPrefix.&i.;
            set &dsn. (firstobs=&first obs=&last);
        run;

        %*Increment counters to have correct first/last;
        %let first = %eval(&last+1);
        %let last = %eval((&i. + 1)*&size.);
    %end;
%mend split;

*Example call;
*After running this, you should find 9 data sets named Split1-Split9;
%split(dsn=SBPRH.results1MergeTpd1Tpd2, size=500000, outDsnPrefix=R1Split);

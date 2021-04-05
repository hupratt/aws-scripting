# SAS 9.4 Base Programming – Performance Based Exam

- [x] Access and Create Data Structures <br/>
```sas
data work.junefee;
set cert.admitjune;
where age>39;
run;
```
proc sql noprint;<br/>
   select count(*)<br/>
      into :DS_CONTRAT_AVT_LIGNES<br/>
      from SBPRH.DS_CONTRAT_AVT;<br/>
quit;<br/>

- [ ] Create temporary and permanent SAS data sets. <br/>
- [ ] Use a DATA step to create a SAS data set from an existing SAS data set. <br/>
- [ ] Investigate SAS data libraries using base SAS utility procedures. <br/>
- [ ] Use a LIBNAME statement to assign a library reference name to a SAS librar <br/>y.
- [ ] Investigate a library programmatically using the CONTENTS procedure. <br/>
- [ ] Access data. <br/>
- [ ] Access SAS data sets with the SET statement. <br/>
- [ ] Use PROC IMPORT to access non-SAS data sources. <br/>
- [ ] o Read delimited and Microsoft Excel (.xlsx) files with PROC IMPORT. <br/>
- [ ] o Use PROC IMPORT statement options (OUT=, DBMS=, REPLACE) <br/>
- [ ] o Use the GUESSINGROWS statement <br/>
- [ ] Use the SAS/ACCESS XLSX engine to read a Microsoft Excel workbook.xlsx fil <br/>e.
- [ ] Combine SAS data sets. <br/>
- [ ] Concatenate data sets. <br/>
- [ ] Merge data sets one-to-one. <br/>
- [ ] Merge data sets one-to-many. <br/>
- [ ] Create and manipulate SAS date values. <br/>
- [ ] Explain how SAS stores date and time values. <br/>
- [ ] Use SAS informats to read common date and time expressions. <br/>
- [ ] Use SAS date and time formats to specify how the values are displayed. <br/>
- [ ] Control which observations and variables in a SAS data set are processed a <br/>nd
- [ ] output. <br/>
- [ ] Use the WHERE statement in the DATA step to select observations to be proc <br/>essed.
- [ ] Subset variables to be output by using the DROP and KEEP statements. <br/>
- [ ] Use the DROP= and KEEP= data set options to specify columns to be processe <br/>d and/or
- [ ] output. <br/>
- [ ] Manage Data <br/>
- [ ] 1Exam Content Guide <br/>
- [ ] Sort observations in a SAS data set. <br/>
- [ ] Use the SORT Procedure to re-order observations in place or output to a ne <br/>w dataset
- [ ] with the OUT= option. <br/>
- [ ] Remove duplicate observations with the SORT Procedure. <br/>
- [ ] Conditionally execute SAS statements. <br/>
- [ ] Use IF-THEN/ELSE statements to process data conditionally. <br/>
- [ ] Use DO and END statements to execute multiple statements conditionally. <br/>
- [ ] Use assignment statements in the DATA step. <br/>
- [ ] Create new variables and assign a value. <br/>
- [ ] Assign a new value to an existing variable. <br/>
- [ ] Assign the value of an expression to a variable. <br/>
- [ ] Assign a constant date value to a variable. <br/>
- [ ] Modify variable attributes using options and statements in the DATA step. <br/>
- [ ] Change the names of variables by using the RENAME= data set option. <br/>
- [ ] Use LABEL and FORMAT statements to modify attributes in a DATA step. <br/>
- [ ] Define the length of a variable using the LENGTH statement. <br/>
- [ ] Accumulate sub-totals and totals using DATA step statements. <br/>
- [ ] Use the BY statement to aggregate by subgroups. <br/>
- [ ] Use first. and last. processing to identify where groups begin and end. <br/>
- [ ] Use the RETAIN and SUM statements. <br/>
- [ ] Use SAS functions to manipulate character data, numeric data, and SAS date values <br/>
- [ ] Use SAS functions such as SCAN, SUBSTR, TRIM, UPCASE, and LOWCASE to perform<br/>
- [ ] tasks such as the tasks shown below.<br/>
- [ ] o Replace the contents of a character value.<br/>
- [ ] o Trim trailing blanks from a character value.<br/>
- [ ] o Search a character value and extract a portion of the value.<br/>
- [ ] o Convert a character value to upper or lowercase.<br/>
- [ ] Use SAS numeric functions such as SUM, MEAN, RAND, SMALLEST, LARGEST, ROUND,<br/>
- [ ] and INT.<br/>
- [ ] Create SAS date values by using the functions MDY, TODAY, DATE, and TIME.<br/>
- [ ] Extract the month, year, and interval from a SAS date value by using the functions<br/>
- [ ] YEAR, QTR, MONTH, and DAY.<br/>
- [ ] Perform calculations with date and datetime values and time intervals by using the<br/>
- [ ] functions INTCK, INTNX, DATDIF and YRDIF.<br/>
- [ ] 2Exam Content Guide<br/>
- [ ] Use SAS functions to convert character data to numeric and vice versa.<br/>
- [ ] Explain the automatic conversion that SAS uses to convert values between data types.<br/>
- [ ] Use the INPUT function to explicitly convert character data values to numeric values.<br/>
- [ ] Use the PUT function to explicitly convert numeric data values to character values.<br/>
- [ ] Process data using DO LOOPS.<br/>
- [ ] Explain how iterative DO loops function.<br/>
- [ ] Use DO loops to eliminate redundant code and to perform repetitive calculations.<br/>
- [ ] Use conditional DO loops.<br/>
- [ ] Use nested DO loops.<br/>
- [ ] Restructure SAS data sets with PROC TRANSPOSE.<br/>
- [ ] Select variables to transpose with the VAR statement.<br/>
- [ ] Rename transposed variables with the ID statement.<br/>
- [ ] Process data within groups using the BY statement.<br/>
- [ ] Use PROC TRANSPOSE options (OUT=, PREFIX= and NAME=).<br/>
- [ ] Use macro variables to simplify program maintenance.<br/>
- [ ] Create macro variables with the %LET statement<br/>
- [ ] Use macro variables within SAS programs.<br/>
- [ ] Error Handling<br/>
- [ ] Identify and resolve programming logic errors.<br/>
- [ ] Use the PUTLOG Statement in the Data Step to help identify logic errors.<br/>
- [ ] Use PUTLOG to write the value of a variable, formatted values, or to write values of all<br/>
- [ ] variables.<br/>
- [ ] Use PUTLOG with Conditional logic.<br/>
- [ ] Use temporary variables N and ERROR to debug a DATA step.<br/>
- [ ] Recognize and correct syntax errors.<br/>
- [ ] Identify the characteristics of SAS statements.<br/>
- [ ] Define SAS syntax rules including the typical types of syntax errors such as misspelled<br/>
- [ ] keywords, unmatched quotation marks, missing semicolons, and invalid options.<br/>
- [ ] Use the log to help diagnose syntax errors in a given program.<br/>
- [ ] 3Exam Content Guide<br/>
- [ ] Generate Reports and Output<br/>
- [ ] Generate list reports using the PRINT procedure.<br/>
- [ ] Modify the default behavior of PROC PRINT by adding statements and options such as<br/>
- [ ] o use the VAR statement to select and order variables.<br/>
- [ ] o calculate totals with a SUM statement.<br/>
- [ ] o select observations with a WHERE statement.<br/>
- [ ] o use the ID statement to identify observations.<br/>
- [ ] o use the BY statement to process groups.<br/>
- [ ] Generate summary reports and frequency tables using base SAS procedures.<br/>
- [ ] Produce one-way and two-way frequency tables with the FREQ procedure.<br/>
- [ ] Enhance frequency tables with options (NLEVELS, ORDER=).<br/>
- [ ] Use PROC FREQ to validate data in a SAS data set.<br/>
- [ ] Calculate summary statistics and multilevel summaries using the MEANS procedure<br/>
- [ ] Enhance summary tables with options.<br/>
- [ ] Identify extreme and missing values with the UNIVARIATE procedure.<br/>
- [ ] Enhance reports system user-defined formats, titles, footnotes and SAS System<br/>
- [ ] reporting options.<br/>
- [ ] Use PROC FORMAT to define custom formats.<br/>
- [ ] o VALUE statement<br/>
- [ ] o CNTLIN= option<br/>
- [ ] Use the LABEL statement to define descriptive column headings.<br/>
- [ ] Control the use of column headings with the LABEL and SPLIT=options in PROC PRINT<br/>
- [ ] output.<br/>
- [ ] Generate reports using ODS statements.<br/>
- [ ] Identify the Output Delivery System destinations.<br/>
- [ ] Create HTML, PDF, RTF, and files with ODS statements.<br/>
- [ ] Use the STYLE=option to specify a style template.<br/>
- [ ] Create files that can be viewed in Microsoft Excel.<br/>
- [ ] Export data<br/>
- [ ] Create a simple raw data file by using the EXPORT procedure as an alternative to the<br/>
- [ ] DATA step.<br/>
- [ ] Export data to Microsoft Excel using the SAS/ACCESS XLSX engine.<br/>
- [ ] Note: All 23 main objectives will be tested on every exam. The 70 expanded objectives are<br/>
- [ ] provided for additional explanation and define the entire domain that could be tested.- [ ] <br/>
<br/>

/**************************************************************************** 
 * Job:             MR_STG_EM_LOAN_P00100                 A5AV1B9A.BS000007 * 
 * Description:                                                             * 
 *                                                                          * 
 * Metadata Server: client.demo.sas.com                                     * 
 * Port:            8561                                                    * 
 * Location:        /Products/Solutions/Montepio                            * 
 *                   Report/CRC/Jobs/Staging/Contratos                      * 
 *                                                                          * 
 * Server:          SASApp                                A5AV1B9A.AS000002 * 
 *                                                                          * 
 * Source Table:    LOAN_ACCOUNT - SYDDS.LOAN_ACCOUNT     A5AV1B9A.BG000004 * 
 * Target Table:    TMP_MR_STG_LOAN_EM -                  A5AV1B9A.BG000005 * 
 *                   mtreptmp.TMP_MR_STG_LOAN_EM                            * 
 *                                                                          * 
 * Generated on:    Saturday, July 2, 2022 11:10:38 AM GMT-05:00            * 
 * Generated by:    sasadm@saspw                                            * 
 * Version:         SAS Data Integration Studio 4.904                       * 
 ****************************************************************************/ 

/* Generate the process id for job  */ 
%put Process ID: &SYSJOBID;

/* General macro variables  */ 
%let jobID = %quote(A5AV1B9A.BS000007);
%let etls_jobName = %nrquote(MR_STG_EM_LOAN_P00100);
%let etls_userID = %nrquote(sasadm@saspw);

%global applName;
data _null_;
applName="SAS Data Integration Studio";
call symput('applName',%nrstr(applName));
run;
/* Performance Statistics require ARM_PROC sub-system   */ 
%macro etls_startPerformanceStats;
   %log4sas();
   %log4sas_logger(Perf.ARM, 'level=info');
   options armagent=log4sas armsubsys=(ARM_PROC);
   %global _armexec;
   %let _armexec = 1;
   %perfinit(applname="&applName");
   %global etls_recnt;
   %let etls_recnt=-1;
%mend;
%etls_startPerformanceStats;

%macro etls_setArmagent;
   %let armagentLength = %length(%sysfunc(getoption(armagent)));
   %if (&armagentLength eq 0) %then
      %do;
         %log4sas();
         %log4sas_logger(Perf.ARM, 'level=info');
         options armagent=log4sas armsubsys=(ARM_PROC);
      %end;
%mend etls_setArmagent;

%macro etls_setPerfInit;
   %if "&_perfinit" eq "0" %then 
      %do;
         %etls_setArmagent;
         %global _armexec;
         %let _armexec = 1;
         %perfinit(applname="&applName");
      %end;
%mend etls_setPerfInit; 

/* Setup to capture return codes  */ 
%global job_rc trans_rc sqlrc;
%let sysrc = 0;
%let job_rc = 0;
%let trans_rc = 0;
%let sqlrc = 0;
%global etls_stepStartTime; 
/* initialize syserr to 0 */ 
data _null_; run;

%macro rcSet(error); 
   %if (&error gt &trans_rc) %then 
      %let trans_rc = &error;
   %if (&error gt &job_rc) %then 
      %let job_rc = &error;
%mend rcSet; 

%macro rcSetDS(error); 
   if &error gt input(symget('trans_rc'),12.) then 
      call symput('trans_rc',trim(left(put(&error,12.))));
   if &error gt input(symget('job_rc'),12.) then 
      call symput('job_rc',trim(left(put(&error,12.))));
%mend rcSetDS; 

/* Create metadata macro variables */
%let IOMServer      = %nrquote(SASApp);
%let metaPort       = %nrquote(8561);
%let metaServer     = %nrquote(client.demo.sas.com);

/* Setup for capturing job status  */ 
%let etls_startTime = %sysfunc(datetime(),datetime.);
%let etls_recordsBefore = 0;
%let etls_recordsAfter = 0;
%let etls_lib = 0;
%let etls_table = 0;

%global etls_debug; 
%macro etls_setDebug; 
   %if %str(&etls_debug) ne 0 %then 
      OPTIONS MPRINT%str(;); 
%mend; 
%etls_setDebug; 

/*==========================================================================* 
 * Step:            Extract                               A5AV1B9A.BT00000B * 
 * Transform:       Extract                                                 * 
 * Description:                                                             * 
 *                                                                          * 
 * Source Table:    LOAN_ACCOUNT - SYDDS.LOAN_ACCOUNT     A5AV1B9A.BG000004 * 
 * Target Table:    Extract - work.W9U5QLVP               A5AV1B9A.BW000007 * 
 *==========================================================================*/ 

%let transformID = %quote(A5AV1B9A.BT00000B);
%let trans_rc = 0;
%let etls_stepStartTime = %sysfunc(datetime(), datetime20.); 

%let etls_recnt = 0;
%macro etls_recordCheck; 
   %let etls_recCheckExist = %eval(%sysfunc(exist(SYDDS.LOAN_ACCOUNT, DATA)) or 
         %sysfunc(exist(SYDDS.LOAN_ACCOUNT, VIEW))); 
   
   %if (&etls_recCheckExist) %then
   %do;
      proc sql noprint;
         select count(*) into :etls_recnt from SYDDS.LOAN_ACCOUNT;
      quit;
   %end;
%mend etls_recordCheck;
%etls_recordCheck;

%let SYSLAST = %nrquote(SYDDS.LOAN_ACCOUNT); 

/* Runtime statistics macros  */ 
%etls_setPerfInit;
%perfstrt(txnname=%BQUOTE(_DISARM|&transformID|&syshostname|Extract), metrNam6=_DISROWCNT, metrDef6=Count32)   ;

%global etls_sql_pushDown;
%let etls_sql_pushDown = -1;
option DBIDIRECTEXEC;

/*---- Map the columns  ----*/ 
proc datasets lib = work nolist nowarn memtype = (data view);
   delete W9U5QLVP;
quit;

%put %str(NOTE: Mapping columns ...);
proc sql;
   create view work.W9U5QLVP as
      select
         account_rk,
         applied_amt,
         mg_accredited_credits_cd,
         valid_from_dttm
   from &SYSLAST
      where ("&date_ts."dt  between valid_from_dttm and valid_to_dttm) and source_system_cd='EM' and loan_status_cd not in ('EM0','EM1','EM2','EM3') and loan_proposal_flg='Y'
   ;
quit;

%let SYSLAST = work.W9U5QLVP;

%global etls_sql_pushDown;
%let etls_sql_pushDown = &sys_sql_ip_all;

%rcSet(&sqlrc); 

%perfstop(metrVal6=%sysfunc(max(&etls_recnt,-1)));
%let etls_recnt=-1;



/** Step end Extract **/

/*==========================================================================* 
 * Step:            User Written                          A5AV1B9A.BT00000C * 
 * Transform:       User Written                                            * 
 * Description:                                                             * 
 *                                                                          * 
 * Source Table:    Extract - work.W9U5QLVP               A5AV1B9A.BW000007 * 
 * Target Table:    User Written - work.W9U65EKZ          A5AV1B9A.BW000008 * 
 *                                                                          * 
 * User Written:    SourceCode                                              * 
 *==========================================================================*/ 

%let transformID = %quote(A5AV1B9A.BT00000C);
%let trans_rc = 0;
%let etls_stepStartTime = %sysfunc(datetime(), datetime20.); 

%let etls_recnt = -1;
%let SYSLAST = %nrquote(work.W9U5QLVP); 

/* Runtime statistics macros  */ 
%etls_setPerfInit;
%perfstrt(txnname=%BQUOTE(_DISARM|&transformID|&syshostname|UserWritten), metrNam6=_DISROWCNT, metrDef6=Count32)   ;

%let _INPUT_count = 1;
%let _INPUT = work.W9U5QLVP;
%let _INPUT_connect = ;
%let _INPUT_engine = ;
%let _INPUT_memtype = VIEW;
%let _INPUT_options = %nrquote();
%let _INPUT_alter = %nrquote();
%let _INPUT_path = %nrquote(/Extract_A5AV1B9A.BW000007%(WorkTable%));
%let _INPUT_type = 1;
%let _INPUT_label = %nrquote();
%let _INPUT_filetype = WorkTable;

%let _INPUT1 = work.W9U5QLVP;
%let _INPUT1_connect = ;
%let _INPUT1_engine = ;
%let _INPUT1_memtype = VIEW;
%let _INPUT1_options = %nrquote();
%let _INPUT1_alter = %nrquote();
%let _INPUT1_path = %nrquote(/Extract_A5AV1B9A.BW000007%(WorkTable%));
%let _INPUT1_type = 1;
%let _INPUT1_label = %nrquote();
%let _INPUT1_filetype = WorkTable;

%let _OUTPUT_count = 1;
%let _OUTPUT = work.W9U65EKZ;
%let _OUTPUT_connect = ;
%let _OUTPUT_engine = ;
%let _OUTPUT_memtype = DATA;
%let _OUTPUT_options = %nrquote();
%let _OUTPUT_alter = %nrquote();
%let _OUTPUT_path = %nrquote(/User Written_A5AV1B9A.BW000008%(WorkTable%));
%let _OUTPUT_type = 1;
%let _OUTPUT_label = %nrquote();
/* List of target columns to keep  */ 
%let _OUTPUT_keep = account_rk applied_amt mg_accredited_credits_cd;
%let _OUTPUT_col_count = 3;
%let _OUTPUT_col0_name = account_rk;
%let _OUTPUT_col0_table = work.W9U65EKZ;
%let _OUTPUT_col0_length = 8;
%let _OUTPUT_col0_type = ;
%let _OUTPUT_col0_format = 20.;
%let _OUTPUT_col0_informat = 20.;
%let _OUTPUT_col0_label = %nrquote(account_rk);
%let _OUTPUT_col0_input0 = account_rk;
%let _OUTPUT_col0_input0_table = work.W9U5QLVP;
%let _OUTPUT_col0_exp = ;
%let _OUTPUT_col0_input = account_rk;
%let _OUTPUT_col0_input_count = 1;
%let _OUTPUT_col1_name = applied_amt;
%let _OUTPUT_col1_table = work.W9U65EKZ;
%let _OUTPUT_col1_length = 8;
%let _OUTPUT_col1_type = ;
%let _OUTPUT_col1_format = 19.5;
%let _OUTPUT_col1_informat = 19.5;
%let _OUTPUT_col1_label = %nrquote(applied_amt);
%let _OUTPUT_col1_input0 = applied_amt;
%let _OUTPUT_col1_input0_table = work.W9U5QLVP;
%let _OUTPUT_col1_exp = ;
%let _OUTPUT_col1_input = applied_amt;
%let _OUTPUT_col1_input_count = 1;
%let _OUTPUT_col2_name = mg_accredited_credits_cd;
%let _OUTPUT_col2_table = work.W9U65EKZ;
%let _OUTPUT_col2_length = 3;
%let _OUTPUT_col2_type = $;
%let _OUTPUT_col2_format = $3.;
%let _OUTPUT_col2_informat = $3.;
%let _OUTPUT_col2_label = %nrquote(Código da operação em que os créditos foram cedidos);
%let _OUTPUT_col2_input0 = mg_accredited_credits_cd;
%let _OUTPUT_col2_input0_table = work.W9U5QLVP;
%let _OUTPUT_col2_exp = ;
%let _OUTPUT_col2_input = mg_accredited_credits_cd;
%let _OUTPUT_col2_input_count = 1;
%let _OUTPUT_filetype = WorkTable;

%let _OUTPUT1 = work.W9U65EKZ;
%let _OUTPUT1_connect = ;
%let _OUTPUT1_engine = ;
%let _OUTPUT1_memtype = DATA;
%let _OUTPUT1_options = %nrquote();
%let _OUTPUT1_alter = %nrquote();
%let _OUTPUT1_path = %nrquote(/User Written_A5AV1B9A.BW000008%(WorkTable%));
%let _OUTPUT1_type = 1;
%let _OUTPUT1_label = %nrquote();
/* List of target columns to keep  */ 
%let _OUTPUT1_keep = account_rk applied_amt mg_accredited_credits_cd;
%let _OUTPUT1_col_count = 3;
%let _OUTPUT1_col0_name = account_rk;
%let _OUTPUT1_col0_table = work.W9U65EKZ;
%let _OUTPUT1_col0_length = 8;
%let _OUTPUT1_col0_type = ;
%let _OUTPUT1_col0_format = 20.;
%let _OUTPUT1_col0_informat = 20.;
%let _OUTPUT1_col0_label = %nrquote(account_rk);
%let _OUTPUT1_col0_input0 = account_rk;
%let _OUTPUT1_col0_input0_table = work.W9U5QLVP;
%let _OUTPUT1_col0_exp = ;
%let _OUTPUT1_col0_input = account_rk;
%let _OUTPUT1_col0_input_count = 1;
%let _OUTPUT1_col1_name = applied_amt;
%let _OUTPUT1_col1_table = work.W9U65EKZ;
%let _OUTPUT1_col1_length = 8;
%let _OUTPUT1_col1_type = ;
%let _OUTPUT1_col1_format = 19.5;
%let _OUTPUT1_col1_informat = 19.5;
%let _OUTPUT1_col1_label = %nrquote(applied_amt);
%let _OUTPUT1_col1_input0 = applied_amt;
%let _OUTPUT1_col1_input0_table = work.W9U5QLVP;
%let _OUTPUT1_col1_exp = ;
%let _OUTPUT1_col1_input = applied_amt;
%let _OUTPUT1_col1_input_count = 1;
%let _OUTPUT1_col2_name = mg_accredited_credits_cd;
%let _OUTPUT1_col2_table = work.W9U65EKZ;
%let _OUTPUT1_col2_length = 3;
%let _OUTPUT1_col2_type = $;
%let _OUTPUT1_col2_format = $3.;
%let _OUTPUT1_col2_informat = $3.;
%let _OUTPUT1_col2_label = %nrquote(Código da operação em que os créditos foram cedidos);
%let _OUTPUT1_col2_input0 = mg_accredited_credits_cd;
%let _OUTPUT1_col2_input0_table = work.W9U5QLVP;
%let _OUTPUT1_col2_exp = ;
%let _OUTPUT1_col2_input = mg_accredited_credits_cd;
%let _OUTPUT1_col2_input_count = 1;
%let _OUTPUT1_filetype = WorkTable;

/*---- Start of User Written Code  ----*/ 

proc sort data = &_INPUT. out=tab_order;
by  account_rk valid_from_dttm;
run;

DATA &_OUTPUT.;
set tab_order ;
by  account_rk valid_from_dttm;
if first.account_rk then output;
run;
/*---- End of User Written Code  ----*/ 

%rcSet(&syserr); 
%rcSet(&sqlrc); 
%perfstop(metrVal6=%sysfunc(max(&etls_recnt,-1)));
%let etls_recnt=-1;



/** Step end User Written **/

/*==========================================================================* 
 * Step:            Extract                               A5AV1B9A.BT00000E * 
 * Transform:       Extract                                                 * 
 * Description:                                                             * 
 *                                                                          * 
 * Source Table:    User Written - work.W9U65EKZ          A5AV1B9A.BW000008 * 
 * Target Table:    Extract - work.WAY2K4                 A5AV1B9A.BW000009 * 
 *==========================================================================*/ 

%let transformID = %quote(A5AV1B9A.BT00000E);
%let trans_rc = 0;
%let etls_stepStartTime = %sysfunc(datetime(), datetime20.); 

%let etls_recCheckExist = 0; 
%let etls_recnt = 0; 
%macro etls_recordCheck; 
   %let etls_recCheckExist = %eval(%sysfunc(exist(work.W9U65EKZ, DATA)) or 
         %sysfunc(exist(work.W9U65EKZ, VIEW))); 
   
   %if (&etls_recCheckExist) %then
   %do;
      %local etls_syntaxcheck; 
      %let etls_syntaxcheck = %sysfunc(getoption(syntaxcheck)); 
      /* Turn off syntaxcheck option to perform following steps  */ 
      options nosyntaxcheck;
      
      proc contents data = work.W9U65EKZ out = work.etls_contents(keep = nobs) noprint; 
      run; 
      
      data _null_; 
         set work.etls_contents (obs = 1); 
         call symput("etls_recnt", left(put(nobs,32.))); 
      run;
      
      proc datasets lib = work nolist nowarn memtype = (data view);
         delete etls_contents;
      quit;
      
      /* Reset syntaxcheck option to previous setting  */ 
      options &etls_syntaxcheck; 
   %end;
%mend etls_recordCheck;
%etls_recordCheck;

%let SYSLAST = %nrquote(work.W9U65EKZ); 

/* Runtime statistics macros  */ 
%etls_setPerfInit;
%perfstrt(txnname=%BQUOTE(_DISARM|&transformID|&syshostname|Extract), metrNam6=_DISROWCNT, metrDef6=Count32)   ;

%global etls_sql_pushDown;
%let etls_sql_pushDown = -1;
option DBIDIRECTEXEC;

/*---- Map the columns  ----*/ 
proc datasets lib = work nolist nowarn memtype = (data view);
   delete WAY2K4;
quit;

%put %str(NOTE: Mapping columns ...);
proc sql;
   create view work.WAY2K4 as
      select
         account_rk,
         applied_amt,
         mg_accredited_credits_cd
   from &SYSLAST
   ;
quit;

%let SYSLAST = work.WAY2K4;

%global etls_sql_pushDown;
%let etls_sql_pushDown = &sys_sql_ip_all;

%rcSet(&sqlrc); 

%perfstop(metrVal6=%sysfunc(max(&etls_recnt,-1)));
%let etls_recnt=-1;



/** Step end Extract **/

/*==========================================================================* 
 * Step:            Table Loader                          A5AV1B9A.BT00000D * 
 * Transform:       Table Loader (Version 2.1)                              * 
 * Description:                                                             * 
 *                                                                          * 
 * Source Table:    Extract - work.WAY2K4                 A5AV1B9A.BW000009 * 
 * Target Table:    TMP_MR_STG_LOAN_EM -                  A5AV1B9A.BG000005 * 
 *                   mtreptmp.TMP_MR_STG_LOAN_EM                            * 
 *==========================================================================*/ 

%let transformID = %quote(A5AV1B9A.BT00000D);
%let trans_rc = 0;
%let etls_stepStartTime = %sysfunc(datetime(), datetime20.); 

%let SYSLAST = %nrquote(work.WAY2K4); 

/* Runtime statistics macros  */ 
%etls_setPerfInit;
%perfstrt(txnname=%BQUOTE(_DISARM|&transformID|&syshostname|Loader), metrNam6=_DISROWCNT, metrDef6=Count32)   ;

%global etls_sql_pushDown;
%let etls_sql_pushDown = -1;
option DBIDIRECTEXEC;

%global etls_tableExist;
%global etls_numIndex;
%global etls_lastTable;
%let etls_tableExist = -1; 
%let etls_numIndex = -1; 
%let etls_lastTable = &SYSLAST; 

/*---- Define load data macro  ----*/ 

/* --------------------------------------------------------------
   Load Technique Selection: Replace - EntireTable
   Constraint and index action selections: 'ASIS','ASIS','ASIS','ASIS'
   Additional options selections... 
      Set unmapped to missing on updates: false 
   -------------------------------------------------------------- */
%macro etls_loader;

   %let etls_tableOptions = ;
   
   /*---- Map the columns  ----*/ 
   proc datasets lib = work nolist nowarn memtype = (data view);
      delete W12O83N;
   quit;
   
   %put %str(NOTE: Mapping columns ...);
   proc sql;
      create view work.W12O83N as
         select
            account_rk,
            applied_amt   
               format = 20.5
               informat = 20.5,
            mg_accredited_credits_cd
      from &etls_lastTable
      ;
   quit;
   
   %let SYSLAST = work.W12O83N;
   
   %let etls_lastTable = &SYSLAST; 
   %let etls_tableOptions = ; 
   
   /* Determine if the target table exists  */ 
   %let etls_tableExist = %eval(%sysfunc(exist(mtreptmp.TMP_MR_STG_LOAN_EM, DATA)) or 
         %sysfunc(exist(mtreptmp.TMP_MR_STG_LOAN_EM, VIEW))); 
   
   %if &etls_tableExist %then 
   %do;/* table exists  */ 
      %let etls_hasPreExistingConstraint=0; 
      
      proc datasets lib = work nolist nowarn memtype = (data view);
         delete etls_commands etls_commands_F;
      quit;
      
      %let etls_otherTablesReferToThisTable=0;
      
      %macro etls_CIContents(table=,workTableOut=,inDSOptions=);
         %put NOTE: Building table listing Constraints and Indexes for: &table;
         proc datasets lib=work nolist; delete &workTableOut; quit;
         proc contents data=&table&inDSOptions out2=&workTableOut noprint; run;
         
         data &workTableOut;
            length name $60 type $20 icown idxUnique idxNoMiss $3 recreate $600;
            name = '';
            type = '';
            icown = '';
            idxUnique = '';
            idxNoMiss = '';
            recreate = '';
            set &workTableOut;
            ref = '';
            type=upcase(type);
            if type eq 'REFERENTIAL' then
            do;
               put "WARNING%QUOTE(:) Target table is referenced by constraints in"
                    " another table: " ref;
               call symput('etls_otherTablesReferToThisTable','1');
               delete;
            end;
            if type='INDEX' and ICOwn eq 'YES' then delete;
         run;
         %rcSet(&syserr); 
         
      %mend etls_CIContents;
      
      %etls_CIContents(table=mtreptmp.TMP_MR_STG_LOAN_EM, workTableOut=etls_commands, inDSOptions=);
      
      %if &etls_otherTablesReferToThisTable %then 
         %put WARNING%QUOTE(:) Replacing entire table will fail. Consider an alternate load technique or revising constraints.; 
      %else 
      %do; /* okay - remove foreign keys  */ 
      
         data etls_commands_F; 
            set etls_commands; 
            if upcase(type)="FOREIGN KEY" then 
            do; 
               command='ic delete '||trim(name)||';';
               output etls_commands_F; 
            end; 
         run; 
         
         %put %str(NOTE: Removing foreign keys before dropping table...);
         data _null_;
            set etls_commands_F end=eof;
            if _n_=1 then 
               call execute('proc datasets nolist lib=mtreptmp;modify TMP_MR_STG_LOAN_EM;');
            call execute(command);
            if eof then call execute('; quit;');
         run;
         %rcSet(&syserr); 
         
   %end; /* okay - remove foreign keys  */ 
   
   proc datasets lib = work nolist nowarn memtype = (data view);
      delete etls_commands etls_commands_F;
   quit;
   
   /*---- Drop a table  ----*/ 
   %put %str(NOTE: Dropping table ...);
   proc datasets lib = mtreptmp nolist nowarn memtype = (data view);
      delete TMP_MR_STG_LOAN_EM;
   quit;
   
   %rcSet(&syserr); 
   
   %let etls_tableExist = 0;
   
%end; /* table exists  */ 

/*---- Create a new table  ----*/ 
%if (&etls_tableExist eq 0) %then 
%do;  /* if table does not exist  */ 

   %put %str(NOTE: Creating table ...);
   
   data mtreptmp.TMP_MR_STG_LOAN_EM;
      attrib account_rk length = 8
         format = 20.
         informat = 20.
         label = 'account_rk'; 
      attrib applied_amt length = 8
         format = 20.5
         informat = 20.5
         label = 'applied_amt'; 
      attrib mg_accredited_credits_cd length = $3
         format = $3.
         informat = $3.
         label = 'mg_accredited_credits_cd'; 
      call missing(of _all_);
      stop;
   run;
   
   %rcSet(&syserr); 
   
%end;  /* if table does not exist  */ 

/*---- Append  ----*/ 
%put %str(NOTE: Appending data ...);

proc append base = mtreptmp.TMP_MR_STG_LOAN_EM 
   data = &etls_lastTable (&etls_tableOptions)  force ; 
 run; 

%rcSet(&syserr); 

proc datasets lib = work nolist nowarn memtype = (data view);
   delete W12O83N;
quit;

%mend etls_loader;
%etls_loader;

%let etls_recCheckExist = 0; 
%let etls_recnt = 0; 
%macro etls_recordCheck; 
   %let etls_recCheckExist = %eval(%sysfunc(exist(mtreptmp.TMP_MR_STG_LOAN_EM, DATA)) or 
         %sysfunc(exist(mtreptmp.TMP_MR_STG_LOAN_EM, VIEW))); 
   
   %if (&etls_recCheckExist) %then
   %do;
      %local etls_syntaxcheck; 
      %let etls_syntaxcheck = %sysfunc(getoption(syntaxcheck)); 
      /* Turn off syntaxcheck option to perform following steps  */ 
      options nosyntaxcheck;
      
      proc contents data = mtreptmp.TMP_MR_STG_LOAN_EM out = work.etls_contents(keep = nobs) noprint; 
      run; 
      
      data _null_; 
         set work.etls_contents (obs = 1); 
         call symput("etls_recnt", left(put(nobs,32.))); 
      run;
      
      proc datasets lib = work nolist nowarn memtype = (data view);
         delete etls_contents;
      quit;
      
      /* Reset syntaxcheck option to previous setting  */ 
      options &etls_syntaxcheck; 
   %end;
%mend etls_recordCheck;
%etls_recordCheck;

%perfstop(metrVal6=%sysfunc(max(&etls_recnt,-1)));
%let etls_recnt=-1;



/** Step end Table Loader **/

/*---- Start of Post-Process Code  ----*/ 

%drop_work_table(&jobid);
/*---- End of Post-Process Code  ----*/ 

%rcSet(&syserr); 
%rcSet(&sqlrc); 

%let etls_endTime = %sysfunc(datetime(),datetime.);

/* Turn off performance statistics collection  */ 
data _null_;
   if "&_perfinit" eq "1" then 
      call execute('%perfend;');
      
run;
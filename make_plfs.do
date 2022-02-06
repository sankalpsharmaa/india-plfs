/************/
/* MAKEFILE */
/************/

* This script runs all the code to process raw data from the Periodic Labour Force Survey 

/*****************/
/* Preliminaries */
/*****************/

/* set global paths - change based on where you have stored the repo and raw data files */

/* data directory path */
global plfs "$ldata/plfs"

/* repo path */
global code "~/india-plfs"

/* data dictionary path */
global dict "$code/dict"

/********************/
/* Run script files */
/********************/

/* main cleaning script */
do $code/src/clean_plfs.do

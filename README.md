# **india-plfs**

This repository contains code to process raw data from the Indian Periodic Labour Force Survey, launched by the National Statistical Office of India on April 2017. The raw microdata is provided in `.txt` files which can be accessed from the following links:

- [2017-18](http://microdata.gov.in/nada43/index.php/catalog/146)
- [2018-19](https://mospi.gov.in/documents/213904/531813//README_demo1602840302629.pdf/768fdbbf-a813-e0d3-7242-ab7a9ffd4cd5)
- [2019-20](https://www.mospi.gov.in/documents/213904/1216623//READMEM1627035725633.pdf/77c18981-9c85-a04a-3a35-af31ce8ce685)
- [2020-21](https://www.mospi.gov.in/documents/213904//1944604//1655191099910_4%20README.pdf//a47b5bdc-77e2-ab5a-1851-f1b00efcccbd)

## **Repo Structure**

- `make_plfs.do` is the makefile for the repo that calls all the scripts in the correct order to process raw data
- `dict` contains all the dictionary files for first visits and revisits to parse variables from `.txt` files
- `src` contains the cleaning scripts
- `docs` contains documentation about sampling weights and variables

## Usage Instructions

1. `make_plfs.do` contains globals at the top of the script to specify the filepaths to the data and code folders respectively. The code global assumes by default that the plfs repo lies in your root folder `~`.

## Occupations

PLFS uses the 2004 National Classification of Occupations (NCO) to identify workers. This [file](https://labour.gov.in/sites/default/files/AlphabeticalIndex.pdf) offers a concordance of 2004 NCO codes with 1968 NCO codes to allow linking PLFS to older NSS rounds.

## Final Notes
If you find any issues while using the code, please add them under GitHub issues. Specific suggestions for improving the code can be made via pull request.

Cheers!

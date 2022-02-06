/************************************************/
/* Parse data from Periodic Labour Force Survey */
/************************************************/

* Years covered: 2017 - 2020
* NOTE: This script only parses data from the first visit only, urban revisits are not covered

/********************/
/* 0. Preliminaries */
/********************/

/* add years to a temporary variable */
local year "2017_18 2018_19 2019_20"

/* import raw text files into STATA with a manually created dictionary */
foreach i in `year' {

    di "Year: `i'"

    if "`i'" == "2017_18" {
        infile using "$dict/FHH_FV.dct", using("$plfs/`i'/FHH_FV.TXT") clear
    }

    if "`i'" == "2018_19" {
        infile using "$dict/FHH_FV.dct", using("$plfs/`i'/hh104_fv_final.txt") clear
    }

    if "`i'" == "2019_20" {
        infile using "$dict/FHH_FV.dct", using("$plfs/`i'/HHV1.TXT") clear
    }

/*************************************************/
/* 1. Variable construction for household recode */
/*************************************************/

/* generate unique household id */
egen hhid = concat(quarter visit fsu hg sss hh_no)
label var hhid "Unique household ID - Generated"

/* quarter-wise weight */
gen comb_wt = mult/100 if nss == nsc
replace comb_wt = mult/200 if nss != nsc

/* DATA NOTE FOR NSS REGIONS

1. NSS Region 139 has 128 observations but has no corresponding label and region classification in the data layout
2. Kanshiram Nagar has been labelled as Eastern in the data layout but should lie in Southern Upper Ganga Plains since the NSS region code is 095. We have corrected this misclassification.

*/

/* response code */
cap label drop response_code
label define response_code 1 "co-operative and capable" 2 "co-operative but not capable" 3 "busy" 4 "reluctant" 9 "others"
label values response_code response_code

/* survey code */
cap label drop survey_code
label define survey_code 1 "original" 2 "substitute" 3 "casualty" 
label values survey_code survey_code

/* substitution reason */
cap label drop subs_reason
label define subs_reason 1 "informant busy" 2 "members away from home" 3 "informant non-cooperative" 9 "others"
label values subs_reason subs_reason

/* hh type */
cap label drop hh_type
/* slightly different codes for urban areas */
recode hh_type 1=6 2=7 3=8 9=10 if sector==2
label define hh_type 1 "rural: self-employed in agriculture" 2 "rural: self-employed in non-agriculture" 3 "rural: regular wage/salary earning" 4 "rural: casual labour in agriculture" 5 "rural: casual labour in non-agriculture" 6 "urban: self-employed" 7 "urban: regular wage/salary earning" 8 "urban: casual labour" 9 "rural: others" 10 "urban: others" 
label values hh_type hh_type

/* religion */
cap label drop religion
label define religion 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "others"
label values religion religion

/* social group */
cap label drop social_group
label define social_group 1 "scheduled tribe" 2 "scheduled caste" 3 "other backward class" 9 "others"
label values social_group social_group

/* sector */
cap label drop sector
label define sector 1 "Rural" 2 "Urban"
label values sector sector

order hhid state
di "SUCCESS: PLFS Household build ready!"

/* save the household build in memory */
tempfile file1
save `file1'

/**************************************************/
/* 2. Variable construction for individual recode */
/**************************************************/

clear 

if "`i'" == "2017_18" {
infile using "$dict/FPER_FV.dct", using("$plfs/`i'/FPER_FV.TXT") clear
}
if "`i'" == "2018_19" {
infile using "$dict/FPER_FV.dct", using("$plfs/`i'/per104_fv_final.txt") clear
}
if "`i'" == "2019_20" {
infile using "$dict/FPER_FV.dct", using("$plfs/`i'/PERV1.TXT") clear
}

/* generate unique household identifier */
egen hhid = concat(quarter visit fsu hg sss hh_no)
label var hhid "Unique household ID - Generated"

/* generate unique person identifier */
egen pid = concat(quarter visit fsu hg sss hh_no per_sn)
label var pid "unique person ID - Generated"
 
/* check for duplicates */
isid pid

/* destring features of interest, i.e., wages and multipliers */
destring ERSW_1, replace
destring ERSW_2, replace
destring nss, replace
destring nsc, replace

/* relationship to head */
label define rel_head 1 "self" 2 "spouse of head" 3 "married child" 4 "spouse of married child" 5 "unmarried child" 6 "grandchild" 7 "father/mother/father-in-law/mother-in-law" 8 "brother/sister/brother-in-law/ sister-in-law/other relatives" 9 "servants/employees/other non-relatives"
label values rel_head rel_head

/* sex */
label define sex 1 "male" 2 "female" 3 "third gender"
label values sex sex

/* marital status */
label define marital_status 1 "never married" 2 " currently married" 3 "widowed" 4 "divorced/separated"
label values marital_status marital_status

/* general education level */
label  define gen_edu 01 "not literate" 02 "literate without formal schooling: EGS/ NFEC/ AEC" 03 "literate without formal schooling: TLC" 04 "literate without formal schooling: others" 05 "literate: below primary" 06 "literate: primary"07 "literate: middle" 08 "literate: secondary" 10 "literate: higher secondary" 11 "literate: diploma/certificate course" 12 "literate: graduate" 13 "literate: postgraduate and above" 
label values gen_edu gen_edu

/* technical education level */
label define tech_edu 01 "no technical education" 02 "technical degree in: agriculture" 03 "technical degree in: engineering/ technology" 04 "technical degree in: medicine" 05 "technical degree in: crafts" 06 "technical degree in: other subjects" 07 "diploma or certificate (below graduate level) in: agriculture" 08 "diploma or certificate (below graduate level) in: engineering/technology" 09 "diploma or certificate (below graduate level) in: medicine" 10 "diploma or certificate (below graduate level) in: crafts" 11 "diploma or certificate (below graduate level) in: other subjects" 12 "diploma or certificate (graduate and above level) in: agriculture" 13 "diploma or certificate (graduate and above level) in: engineering/technology" 14 "diploma or certificate (graduate and above level) in: medicine" 15 "diploma or certificate (graduate and above level) in: crafts" 16 "diploma or certificate (graduate and above level) in: other subjects"
label values tech_edu tech_edu

/* status of current attendence */
label define curr_attnd 01 "never attended: school too far" 02 "never attended: to supplement household income" 03 "never attended: education not considered necessary" 04 "never attended: to attend domestic chores" 05 "never attended: others" 11 "ever attended but currently not attending: school too far" 12 "ever attended but currently not attending: to supplement household income" 13 "ever attended but currently not attending:education not considered necessary" 14 "ever attended but currently not attending: to attend domestic chores" 15 "ever attended but currently not attending: others" 21 "currently attending in: EGS/ NFEC/ AEC" 22 "currently attending in: TLC" 23 "currently attending in: pre-primary (nursery/ Kindergarten, etc.)" 24 "currently attending in: primary (class I to IV/ V)" 25 "currently attending in: middle" 26 "currently attending in: secondary" 27 "currently attending in: higher secondary" 28 "graduate in: agriculture" 29 "graduate in: engineering/ technology" 30 "graduate in: medicine" 31 "graduate in: other subjects" 32 "post graduate and above" 33 "diploma or certificate (below graduate level) in: agriculture" 34 "diploma or certificate (below graduate level) in: engineering/ technology" 35 "diploma or certificate (below graduate level) in: medicine" 36 "diploma or certificate (below graduate level) in: crafts" 37 "diploma or certificate (below graduate level) in: other subjects" 38 "diploma or certificate (graduate level) in: agriculture" 39 "diploma or certificate (graduate level) in: engineering/ technology" 40 "diploma or certificate (graduate level) in: medicine" 41 "diploma or certificate (graduate level) in: crafts" 42 "diploma or certificate (graduate level) in: other subjects" 43 "diploma or certificate in post graduate and above level"
label values curr_attnd curr_attnd

/* vocational training */
label define voc_train 1 "yes: received formal vocational/technical training-1" 2 "received vocational/technical training other than formal vocational/technical training: hereditary" 3 "received vocational/technical training other than formal vocational/technical training: self-leanring" 4 "received vocational/technical training other than formal vocational/technical training: learning on the job" 5 "received vocational/technical training other than formal vocational/technical training: others" 6 "did not receive any vocational/technical training"
label values  voc_train voc_train

/* training completion */
label define train_compl 1 "yes" 2 "no"
label values train_compl train_compl

/* training field */
label define train_field 01 "aerospace and aviation" 02 "agriculture, non-crop based agriculture, food processing" 03 "allied manufacturinggems and jewellery, leather, rubber, furniture and fittings, printing" 04 "artisan/craftsman/handicraft/creative arts and cottage based production" 05 "automotive" 06"beauty and wellness" 07 "chemical engineering, hydrocarbons, chemicals and petrochemicals" 08 "civil engineering- construction, plumbing, paints and coatings" 09 "electrical, power and electronics" 10 "healthcare and life sciences" 11 "hospitality and tourism" 12 "iron and steel, mining, earthmoving and infra building" 13 "IT-ITeS" 14 "logistics" 15 "mechanical engineeringcapital goods, strategic manufacturing" 16 "media-journalism, mass communication and entertainment" 17 "office and business related work" 18 "security" 19 "telecom" 20 "textiles and handlooms, apparels" 21 "work related to childcare, nutrition, pre-school and crèche" 99 "other"
label values train_field train_field

/* training duration */
label define dur_train 1 "less than 3 months" 2 "3 months or more but less than 6 months" 3 "6 months or more but less than 12 months" 4 "12 months or more but less than 18 months" 5 "18 months or more but less than 24 months" 6 "24 months or more"
label values dur_train dur_train

/* training type */
label define type_train 1 "on the job" 2 "other than on the job: part time" 3 "other than on the job: full time"
label values type_train type_train

/* training fund source */
label define source_fund_train 1 "govt" 2 "own funding" 9 "others"
label values source_fund_train source_fund_train

/* principal status code */
label define prnc_status_code 11 "worked in h.h. enterprise (self-employed): own account worker" 12 "worked in h.h. enterprise (self-employed): employer" 21 "worked in h.h. enterprise (self-employed): worked as helper in h.h. enterprise (unpaid family worker)" 31 "worked as regular salaried/ wage employee" 41 "worked as casual wage labour: in public works" 51 "worked as casual wage labour: in other types of work" 81 "did not work but was seeking and/or available for work" 91 "attended educational institution" 92 "attended domestic duties only" 93 "attended domestic duties and was also engaged in fre collection of goods (vegetables, roots, firewood, cattle feed, etc.), sewing, tailoring, weaving, etc. for household use" 94 "rentiers, pensioners , remittance recipients, etc." 95 "not able to work due to disability" 97 "others (including begging, prostitution, etc.)" 99 "children aged 0-4 yrs"
label values prnc_status_code prnc_status_code

/* subsidiary capacity */
label define subs_cap 1 "yes" 2 "no"
label value subs_cap subs_cap

/* principal work location */
label define prnc_work_loc 10 "workplace in rural areas and located in: own dwelling unit" 11 "workplace in rural areas and located in: structure attached to own dwelling unit" 12 "workplace in rural areas and located in: open area adjacent to own dwelling unit" 13 "workplace in rural areas and located in:detached structure adjacent to own dwelling unit" 14 "workplace in rural areas and located in: own enterprise/unit/office/shop but away from own dwelling" 15 "workplace in rural areas and located in: employer’s dwelling unit" 16 "workplace in rural areas and located in: employer’s enterprise/unit/office/shop but outside employer’s dwelling" 17 "workplace in rural areas and located in: street with fixed location" 18 "workplace in rural areas and located in:construction site" 19 "workplace in rural areas and located in: others" 20 "workplace in urban areas and located in: own dwelling unit" 21 "workplace in urban areas and located in: structure attached to own dwelling unit" 22 "workplace in urban areas and located in: open area adjacent to own dwelling unit" 23 "workplace in urban areas and located in: detached structure adjacent to own dwelling unit" 24 "workplace in urban areas and located in: own enterprise/unit/office/shop but away from own dwelling" 25 "workplace in urban areas and located in: employer’s dwelling unit" 26 "workplace in urban areas and located in: employer’s enterprise/unit/office/shop but outside employer’s dwelling" 27 "workplace in urban areas and located in: street with fixed location" 28 "workplace in urban areas and located in: construction site" 29 "workplace in urban areas and located in: others" 99 "no fixed workplace"
label values prnc_work_loc prnc_work_loc

/* principal enterprise */
label define prnc_ent_code 01 "proprietary: male" 02 "proprietary: female" 03 "partnership: with members from same household" 04 "partnership: with members from different household" 05 "Government/local body" 06 "Public Sector Enterprises" 07 "Autonomous Bodies" 08 "Public/Private limited company" 10"Co-operative societies" 11 "trust/other non-profit institutions" 12 "employer’s households(i.e., private households employing maid servant, watchman, cook, etc.)" 19 "others"
label values prnc_ent_code prnc_ent_code 

/* principal no. of workers */
label define prnc_workers 1 "less than 6" 2 "6 and above but less than 10" 3 "10 and above but less than 20" 4 "20 and above" 9 "not known"
label values prnc_workers prnc_workers

/* principal job contract */
label define prnc_job_cntrct 1 "no written job contract" 2 "written job contract: for 1 year or less" 3 "written job contract: more than 1 year to 3 years" 4 "written job contract: more than 3 years" 
label values prnc_job_cntrct prnc_job_cntrct

/* principal paid leave */
label define prnc_paid_leave 1 "yes" 2 "no"
label values prnc_paid_leave prnc_paid_leave

/* principal social security benefits */
label define prnc_ssb 1 "eligible for: only PF/ pension (i.e., GPF, CPF, PPF, pension, etc.)" 2 "eligible for: only gratuity" 3 "eligible for: only health care & maternity benefits" 4 "eligible for: only PF/ pension and gratuity" 5 "eligible for: only PF/ pension and health care & maternity benefits" 6 "eligible for: only gratuity and health care & maternity benefits" 7 "eligible for: PF/ pension, gratuity, health care & maternity benefits" 8 "not eligible for any of above social security benefits" 9 "not known" 
label values prnc_ssb prnc_ssb

/* subsidiary status code */
label define subs_status_code 11 "worked in h.h. enterprise (self-employed): own account worker" 12 "worked in h.h. enterprise (self-employed): employer" 21 "worked in h.h. enterprise (self-employed): worked as helper in h.h. enterprise (unpaid family worker)" 31 "worked as regular salaried/ wage employee" 41 "worked as casual wage labour: in public works" 51 "worked as casual wage labour: in other types of work"
label values subs_status_code subs_status_code

/* subsidiary work location */
label define subs_work_loc 10 "workplace in rural areas and located in: own dwelling unit" 11 "workplace in rural areas and located in: structure attached to own dwelling unit" 12 "workplace in rural areas and located in: open area adjacent to own dwelling unit" 13 "workplace in rural areas and located in:detached structure adjacent to own dwelling unit" 14 "workplace in rural areas and located in: own enterprise/unit/office/shop but away from own dwelling" 15 "workplace in rural areas and located in: employer’s dwelling unit" 16 "workplace in rural areas and located in: employer’s enterprise/unit/office/shop but outside employer’s dwelling" 17 "workplace in rural areas and located in: street with fixed location" 18 "workplace in rural areas and located in:construction site" 19 "workplace in rural areas and located in: others" 20 "workplace in urban areas and located in: own dwelling unit" 21 "workplace in urban areas and located in: structure attached to own dwelling unit" 22 "workplace in urban areas and located in: open area adjacent to own dwelling unit" 23 "workplace in urban areas and located in: detached structure adjacent to own dwelling unit" 24 "workplace in urban areas and located in: own enterprise/unit/office/shop but away from own dwelling" 25 "workplace in urban areas and located in: employer’s dwelling unit" 26 "workplace in urban areas and located in: employer’s enterprise/unit/office/shop but outside employer’s dwelling" 27 "workplace in urban areas and located in: street with fixed location" 28 "workplace in urban areas and located in: construction site" 29 "workplace in urban areas and located in: others" 99 "no fixed workplace"
label values subs_work_loc subs_work_loc

/* subsidiary enterprise */
label define subs_ent_code 01 "proprietary: male" 02 "proprietary: female" 03 "partnership: with members from same household" 04 "partnership: with members from different household" 05 "Government/local body" 06 "Public Sector Enterprises" 07 "Autonomous Bodies" 08 "Public/Private limited company" 10"Co-operative societies" 11 "trust/other non-profit institutions" 12 "employer’s households(i.e., private households employing maid servant, watchman, cook, etc.)" 19 "others"
label values subs_ent_code subs_ent_code

/* subsidiary no. of workers */
label define subs_workers 1 "less than 6" 2 "6 and above but less than 10" 3 "10 and above but less than 20" 4 "20 and above" 9 "not known"
label values subs_workers subs_workers

/* subsidiary job contract */
label define subs_job_cntrct 1 "no written job contract" 2 "written job contract: for 1 year or less" 3 "written job contract: more than 1 year to 3 years" 4 "written job contract: more than 3 years" 
label values subs_job_cntrct subs_job_cntrct

/* subsidiary paid leave */
label define subs_paid_leave 1 "yes" 2 "no"
label values subs_paid_leave subs_paid_leave

/* subsidiary SSB */
label define subs_ssb 1 "eligible for: only PF/ pension (i.e., GPF, CPF, PPF, pension, etc.)" 2 "eligible for: only gratuity" 3 "eligible for: only health care & maternity benefits" 4 "eligible for: only PF/ pension and gratuity" 5 "eligible for: only PF/ pension and health care & maternity benefits" 6 "eligible for: only gratuity and health care & maternity benefits" 7 "eligible for: PF/ pension, gratuity, health care & maternity benefits" 8 "not eligible for any of above social security benefits" 9 "not known"
label values subs_ssb subs_ssb

/* status code for activity 1 and 2 */
label define stat_code 11 "worked in h.h. enterprise (self-employed): own account worker" 12 "worked in h.h. enterprise (self-employed): employer" 21 "worked in h.h. enterprise (self-employed): worked as helper in h.h. enterprise (unpaid family worker)" 31 "worked as regular salaried/ wage employee" 51 "worked as casual wage labour: in other types of work" 91 "attended educational institution" 92 "attended domestic duties only" 93 "attended domestic duties and was also engaged in fre collection of goods (vegetables, roots, firewood, cattle feed, etc.), sewing, tailoring, weaving, etc. for household use" 94 "rentiers, pensioners , remittance recipients, etc." 95 "not able to work due to disability" 97 "others (including begging, prostitution, etc.)" 41 "worked as casual wage labour in public works other than MGNREG works" 42 "worked as casual wage labour in MGNREG works" 61 "had work in h.h. enterprise but did not work due to: sickness" 62 "had work in h.h. enterprise but did not work due to: other reasons" 71 "had regular salaried/wage employment but did not work due to: sickness" 72 "had regular salaried/wage employment but did not work due to: other reasons" 81 "sought work" 82 "did not seek but was available for work" 98 "did not work due to temporary sickness (for casual workers only)" 99 "children aged 0-4 yrs"

/* sector */
cap label drop sector
label define sector 1 "Rural" 2 "Urban"
label values sector sector
order hhid state

/* label current weekly status codes */
label values sta_codeact1_7 stat_code
label values sta_codeact2_7 stat_code
label values sta_codeact1_6 stat_code
label values sta_codeact2_6 stat_code
label values sta_codeact1_5 stat_code
label values sta_codeact2_5 stat_code
label values sta_codeact1_4 stat_code
label values sta_codeact2_4 stat_code
label values sta_codeact1_3 stat_code
label values sta_codeact2_3 stat_code
label values sta_codeact1_2 stat_code
label values sta_codeact2_2 stat_code
label values sta_codeact1_1 stat_code
label values sta_codeact2_1 stat_code
label values CWS stat_code  

/*******************************************************************/
/* 3. Merge individual-level dataset with houesehold-level dataset */
/*******************************************************************/

merge m:1 hhid using `file1', force
drop _merge

/* save first visit data */
save "$plfs/`i'/fv_combined_`i'", replace

di "SUCCESS!: `i' PLFS First Visit data stored in $plfs/`i'"

}

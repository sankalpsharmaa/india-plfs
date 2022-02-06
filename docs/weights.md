# Weights used in PLFS

For each Quarter, following values are calculated and kept at the end of each record: 

- NSS (3 bytes) = number of first stage units surveyed within sector x state x stratum x substratum for the sub-sample
- NSC (3 bytes) = number of first stage units surveyed within a sector x state x stratum x substratum for combined sub-samples
- MLTS (10 bytes) = weight or multiplier (in two places of decimal) calculated at the level of Second Stage Stratum (SSS)

In the value fields (in Rs.) the numeric figure is given in whole number including negative values wherever applicable. All records of a segment x second stage stratum of a particular first stage unit (FSU) will have same weight. For generating any estimate, one has to extract relevant portion of the data, and aggregate after applying the weights (i.e. multipliers).

## Use of Sub-sample wise weights (Quarter wise multipliers)

- For generating Sub-sample wise estimates for a quarter, FSU’s or Sub-sample-2 FSU’s of only one sub-sample are to be considered. Sub-sample code is available in the data file at 24th byte (refer to layout of data i.e., Data_LayoutPLFS.XLS).
- For generating sub-sample wise estimate, weight may be applied as follows:
$\text{Final Weight} = MLTS/100$
- For generating combined estimate (taking both the subsamples together), weights may be
applied as follows:
Final weight = MLTS/100 if NSS = NSC
             = MLTS/200 otherwise.
    
- Generation of combined estimate for the entire Year: For annual estimate, MLTS may be divided by number of quarters.
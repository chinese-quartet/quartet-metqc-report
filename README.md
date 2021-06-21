
<!-- README.md is generated from README.Rmd. Please edit that file -->

# MetQC

<!-- badges: start -->

<!-- badges: end -->

The goal of MetQC is to provide Quartet-based QCtools for Metabolomics.

## Installation

You can install the released version of MetQC from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("MetQC")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("chinese-quartet/MetQC")
```

## Example

``` r
library(MetQC)
## Count SNR
CountSNR(sample_data,sample_metadata)
#> [1] 16.1393

## Get PCA table
PCA_table(sample_data,sample_metadata)
#>     col_names        PC1        PC2        PC3         PC4         PC5
#> 1  T_L4_D5_01 -5.0445235  0.7911134  0.9681921 -1.19662981  0.36474921
#> 2  T_L4_D5_02 -4.4863770  0.6349722  0.5798990 -1.59810155 -1.07217322
#> 3  T_L4_D5_03 -4.0967709  1.3875116  1.7524213  0.23286213 -0.55047503
#> 4  T_L4_D6_01 -1.0872611  0.7424875 -1.5680448  2.63449037  1.26205717
#> 5  T_L4_D6_02 -1.1273827  1.1053463 -1.1099040  2.46712732 -0.22338041
#> 6  T_L4_D6_03  0.7863001  2.0574987 -4.1775008 -0.01810007 -0.06195732
#> 7  T_L4_F7_01  4.6201742  1.9861180  1.5502289  0.24021347 -0.13388041
#> 8  T_L4_F7_02  3.3855463  2.1038148  1.7782766  0.02083823  1.05898015
#> 9  T_L4_F7_03  4.0318550  2.0867509  0.4694458 -2.37278049 -0.11473443
#> 10 T_L4_M8_01  2.2504015 -3.6707485  0.1537126  1.18805062 -3.37060002
#> 11 T_L4_M8_02  0.3190665 -5.0002345  1.9222324  1.24660656  1.93128463
#> 12 T_L4_M8_03  0.4489716 -4.2246304 -2.3189590 -2.84457679  0.91012968
#>           PC6          PC7          PC8          PC9        PC10         PC11
#> 1  -0.3537820  1.053845659 -1.366754015  0.335797678 -0.60289592  0.604658535
#> 2   0.1356355 -1.778240808  0.915247667  0.574388720  0.30719698  0.334522270
#> 3   1.0731803  0.764906435  0.345766279 -0.998168327  0.32574406 -0.899968279
#> 4   0.2442051  0.002545147  1.161682724 -0.454045802 -1.00549403  0.513940214
#> 5  -2.2005400  0.386792868  0.034821283  0.836960463  0.53579800 -0.546861890
#> 6   1.3335917 -0.710925270 -1.186557653 -0.185476297  0.32492929 -0.137111562
#> 7   1.7849342  0.802355949  0.388938732  1.192222107 -0.01004686  0.030106367
#> 8  -0.8419803 -0.134810477 -0.126144564 -0.816041300  1.04397653  0.764605696
#> 9  -1.2859859 -0.571268033 -0.006700519 -0.284502804 -1.06004266 -0.621532413
#> 10 -0.1379568  0.166004852 -0.276790215 -0.392523795 -0.19993324  0.366081124
#> 11  0.4306978 -1.080833359 -0.700940287  0.182451115 -0.07360209 -0.399454073
#> 12 -0.1819995  1.099627039  0.817430567  0.008938242  0.41436994 -0.008985989
#>            PC12 strategy dataacquisition lab platform sample rep batch
#> 1  2.770895e-15 Targeted      UPLC-MS/MS  L4     T_L4     D5   1     1
#> 2  2.763313e-15 Targeted      UPLC-MS/MS  L4     T_L4     D5   2     1
#> 3  2.700680e-15 Targeted      UPLC-MS/MS  L4     T_L4     D5   3     1
#> 4  2.628702e-15 Targeted      UPLC-MS/MS  L4     T_L4     D6   1     1
#> 5  2.293372e-15 Targeted      UPLC-MS/MS  L4     T_L4     D6   2     1
#> 6  2.458483e-15 Targeted      UPLC-MS/MS  L4     T_L4     D6   3     1
#> 7  2.607018e-15 Targeted      UPLC-MS/MS  L4     T_L4     F7   1     1
#> 8  2.472306e-15 Targeted      UPLC-MS/MS  L4     T_L4     F7   2     1
#> 9  2.233619e-15 Targeted      UPLC-MS/MS  L4     T_L4     F7   3     1
#> 10 2.724600e-15 Targeted      UPLC-MS/MS  L4     T_L4     M8   1     1
#> 11 2.577718e-15 Targeted      UPLC-MS/MS  L4     T_L4     M8   2     1
#> 12 2.686843e-15 Targeted      UPLC-MS/MS  L4     T_L4     M8   3     1
#>      OlaColName labcode recode    longsp
#> 1  T_L4_D5_1_01     MBP T_L4_1 T_L4_1_D5
#> 2  T_L4_D5_2_01     MBP T_L4_1 T_L4_1_D5
#> 3  T_L4_D5_3_01     MBP T_L4_1 T_L4_1_D5
#> 4  T_L4_D6_1_01     MBP T_L4_1 T_L4_1_D6
#> 5  T_L4_D6_2_01     MBP T_L4_1 T_L4_1_D6
#> 6  T_L4_D6_3_01     MBP T_L4_1 T_L4_1_D6
#> 7  T_L4_F7_1_01     MBP T_L4_1 T_L4_1_F7
#> 8  T_L4_F7_2_01     MBP T_L4_1 T_L4_1_F7
#> 9  T_L4_F7_3_01     MBP T_L4_1 T_L4_1_F7
#> 10 T_L4_M8_1_01     MBP T_L4_1 T_L4_1_M8
#> 11 T_L4_M8_2_01     MBP T_L4_1 T_L4_1_M8
#> 12 T_L4_M8_3_01     MBP T_L4_1 T_L4_1_M8
```

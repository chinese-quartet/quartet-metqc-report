
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
## Get performance report for metabolomics data
### The result document was outputed to "output" directory under the working directory
GetPerformance(dt=sample_data,metadata=sample_metadata)

## Count SNR and plot related PCA plot
CountSNR(dt=sample_data,metadata=sample_metadata)
#> [1] 4.511966

## Count RC and plot related scatter plot
CountRC(dt=sample_data,metadata=sample_metadata)
#> [1] 0.7637139

## Count Recall 
CountRecall(dt=sample_data,metadata=sample_metadata)
#> [1] 0.1649485

### The output directory can also be assigned.
# GetPerformance(output.path = [Your Path],dt=sample_data,metadata=sample_metadata)
# CountSNR(output.path = [Your Path],dt=sample_data,metadata=sample_metadata)
# CountRC(output.path = [Your Path],dt=sample_data,metadata=sample_metadata)
# CountRecall(output.path = [Your Path],dt=sample_data,metadata=sample_metadata)
```

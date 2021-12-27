## code to prepare `DATASET` dataset goes here
library(data.table)
sample_data <- fread("../../02_modifiedData/0916/U_L2.csv")
sample_metadata <- fread("../../02_modifiedData/0916/U_L2.meta.csv")
# write.csv(sample_data,"input/sample_data.csv",row.names = F)
# write.csv(sample_metadata,"input/sample_metadata.csv",row.names = F)

MetInfo <- unique(fread("../../02_modifiedData/0916/MetaboliteAnnot.csv")[,c(2,3)])
MetReference <- fread("../../02_modifiedData/1013/procession/RefDataset.FCwithspikeins.csv")
HistoricalData <- fread("../../02_modifiedData/0206/20210628_qcmetrics.csv")
SpikeinRatios <- fread("../../02_modifiedData/1013/procession/Spike-in.ratios.csv")

usethis::use_data(sample_data,compress = "xz",overwrite = "T")
usethis::use_data(sample_metadata,compress = "xz",overwrite = "T")
usethis::use_data(MetReference,compress = "xz",overwrite = "T")
usethis::use_data(MetInfo,compress = "xz",overwrite = "T")
usethis::use_data(HistoricalData,compress = "xz",overwrite = "T")
usethis::use_data(SpikeinRatios,compress = "xz",overwrite = "T")

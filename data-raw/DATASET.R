## code to prepare `DATASET` dataset goes here
library(data.table)
sample_data <- fread("../../02_modifiedData/0916/T_L1.csv")[,1:14]

sample_metadata <- fread("../../02_modifiedData/0916/Metadata.csv")[OldColName %in% colnames(sample_data),]
cols <- c("OldColName","strategy","lab","sample","rep","batch")
sample_metadata <- sample_metadata[,..cols]
colnames(sample_metadata)[1] <- "col_names"

# write.csv(sample_data,"input/sample_data.csv",row.names = F)
# write.csv(sample_metadata,"input/sample_metadata.csv",row.names = F)

MetInfo <- unique(fread("../../02_modifiedData/0916/MetaboliteAnnot.csv")[,c(2,3)])

multibatches_rawdata <- fread("../../02_modifiedData/0206/20210625_batch1quant.csv")
multibatches_metadata <- fread("../../02_modifiedData/0206/20210625_batch1metadata.csv")
MetReference <- readRDS("../../02_modifiedData/0916/20210916_RefDatasets_CVmethod_9.rds")
HistoricalData <- fread("../../02_modifiedData/0206/20210628_qcmetrics.csv")

# write.csv(sample_data,"input/sample_data.csv",row.names = F)
# write.csv(sample_metadata,"input/sample_metadata.csv",row.names = F)


usethis::use_data(sample_data,compress = "xz",overwrite = "T")
usethis::use_data(sample_metadata,compress = "xz",overwrite = "T")
# usethis::use_data(multibatches_rawdata,compress = "xz",overwrite = "T")
# usethis::use_data(multibatches_metadata,compress = "xz",overwrite = "T")
usethis::use_data(MetReference,compress = "xz",overwrite = "T")
usethis::use_data(MetInfo,compress = "xz",overwrite = "T")
usethis::use_data(HistoricalData,compress = "xz",overwrite = "T")

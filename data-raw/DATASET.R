## code to prepare `DATASET` dataset goes here
library(data.table)
sample_data <- sample_data
cols <- colnames(sample_data)[-1]
sample_data <- sample_data[sample_data[,..cols][,!Reduce(`&`, lapply(.SD, is.na))]]
colnames(sample_data)[1] <- "HMDB_id"

sample_metadata <- load("~/Projects/Quartet/Data/MetforQCtools/MetQC/data/sample_metadata.rda")
cols <- c("col_names","sample","rep","recode","longsp")
sample_metadata <- sample_metadata[,..cols]


multibatches_rawdata <- fread("../../02_modifiedData/0206/20210625_batch1quant.csv")
multibatches_metadata <- fread("../../02_modifiedData/0206/20210625_batch1metadata.csv")
MetReference <- readRDS("../../02_modifiedData/0206/20210504_RefDatasets_CVmethod_9.rds")
colnames(MetReference)[2] <-"HMDB_id"
HistoricalData <- fread("../../02_modifiedData/0206/20210628_qcmetrics.csv")

# write.csv(sample_data,"input/sample_data.csv",row.names = F)
# write.csv(sample_metadata,"input/sample_metadata.csv",row.names = F)


usethis::use_data(sample_data,compress = "xz",overwrite = "T")
usethis::use_data(sample_metadata,compress = "xz",overwrite = "T")
usethis::use_data(multibatches_rawdata,compress = "xz")
usethis::use_data(multibatches_metadata,compress = "xz")
usethis::use_data(MetReference,compress = "xz")
usethis::use_data(HistoricalData,compress = "xz")

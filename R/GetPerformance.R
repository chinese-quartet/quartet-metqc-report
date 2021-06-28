# ---------------------------------------------------------------------------------- #
#' @title Get output table
#'
#' @description Get information of overall performance with historical data.
#'
#' @param dt Data table
#' @param metadata Data table
#'
#' @return Numeric vector
#' @importFrom data.table data.table
#'
#' @examples
#' GetPerformance(sample_data,sample_metadata)
#'
#' @export

GetPerformance <- function(dt,metadata){
    SNR <- CountSNR(dt,metadata)
    CTR <- CountCTR(dt,metadata)
    dt.overall <- HistoricalData
    
    outputdt <- data.table(
        "Quality metrics"= c("Signal-to-Noise Ratio (SNR)","Correlation with Reference Datasets"),
        "Value" = c(as.numeric(round(SNR,2)),as.numeric(round(CTR,2))),
        "Historical value (mean ± SD)"=c(paste(round(mean(dt.overall$SNR),2),"±",round(sd(dt.overall$SNR),2)),
                                          paste(round(mean(dt.overall$CTR),2),"±",round(sd(dt.overall$CTR),2))),
        "Rank"=c(paste(rank(-c(SNR,dt.overall$SNR))[1],"/",nrow(dt.overall)+1),
                 paste(rank(-c(CTR,dt.overall$CTR))[1],"/",nrow(dt.overall)+1))
    )
    path <- getwd()
    write.csv(x = outputdt,file = paste0(path,"/PerformanceTable.csv"),row.names = F,quote = T)
}

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
#' GetPerformance(dt=sample_data,metadata=sample_metadata)
#'
#' @export

GetPerformance <- function(dt.path=NULL, metadata.path=NULL, output.path = NULL, dt=NULL, metadata=NULL){
    if(!is.null(dt.path) & !is.null(metadata.path)){
        dt <- MapIDs(dt.path=dt.path)
        metadata <- fread(metadata.path)
    }
    
    if(is.null(output.path)){
        path <- getwd()
        subDir <- "output"  
        dir.create(file.path(path, subDir), showWarnings = FALSE)
        output.path <- file.path(path,"output")
    } 
    
    SNR <- CountSNR(dt=dt,metadata=metadata,output.path = output.path)
    CTR <- CountCTR(dt=dt,metadata=metadata,output.path = output.path)
    dt.overall <- HistoricalData
    
    outputdt <- data.table(
        "Quality metrics"= c("Signal-to-Noise Ratio (SNR)","Correlation with Reference Datasets"),
        "Value" = c(as.numeric(round(SNR,2)),as.numeric(round(CTR,2))),
        "Historical value (mean ± SD)"=c(paste(round(mean(dt.overall$SNR),2),"±",round(sd(dt.overall$SNR),2)),
                                          paste(round(mean(dt.overall$CTR),2),"±",round(sd(dt.overall$CTR),2))),
        "Rank"=c(paste(rank(-c(SNR,dt.overall$SNR))[1],"/",nrow(dt.overall)+1),
                 paste(rank(-c(CTR,dt.overall$CTR))[1],"/",nrow(dt.overall)+1))
    )
    
    write.csv(x = outputdt,file = file.path(output.path,"PerformanceTable.csv"),row.names = F,quote = T)
}

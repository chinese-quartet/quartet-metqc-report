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
#' @importFrom data.table rbindlist
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
    
    if(is.null(dt.path)){
        dt <- MapIDs(dt = dt)
    }
    
    if(is.null(output.path)){
        path <- getwd()
        subDir <- "output"  
        dir.create(file.path(path, subDir), showWarnings = FALSE)
        output.path <- file.path(path,"output")
    } 
    
    SNR <- CountSNR(dt=dt,metadata=metadata,output.path = output.path)
    CTR <- CountCTR(dt=dt,metadata=metadata,output.path = output.path)
    RMSE <- CountRMSE(dt=dt,metadata=metadata,output.path = output.path)
    
    dt.result <- data.table("QUERIED DATA","SNR"=SNR,"CTR"=CTR,"RMSE"=RMSE)
    names(dt.result)[1] <- names(HistoricalData)[1]
    dt.overall <- rbindlist(list(HistoricalData,dt.result))
    
    fn <- function(x) x * 100/max(x, na.rm = TRUE)
    dt.overall$SNR_normalized <- fn(dt.overall$SNR)
    dt.overall$CTR_normalized <- fn(dt.overall$CTR)
    dt.overall$RMSE_normalized <- 100 - fn(dt.overall$RMSE)
    cols <- c("SNR_normalized", "CTR_normalized","RMSE_normalized")
    dt.overall$Total <- apply(dt.overall[,..cols],1,function(x)mean(x,na.rm = T))
    
    GetClass <- function(aList){
        result <- as.character(cut(aList,
            breaks = quantile(aList, probs = seq(0,1,.25),na.rm = T), 
            include.lowest = T,labels = c("Bad","Fair","Good","Great")))
        return(result)
    }
    
    dt.overall$Class <- GetClass(dt.overall$Total)
    names(dt.overall)[1] <- "batch"
    setkey(dt.overall,batch)
    
    write.csv(x = dt.overall,file = file.path(output.path,"rank_table.csv"),row.names = F,quote = T)
    
    
    cols <- c("SNR","CTR","RMSE","Total")
    dt.overall.hist <- dt.overall[batch != "QUERIED DATA"]
    dt.overall.hist.stat <- apply(dt.overall.hist[batch != "QUERIED DATA",..cols],2, 
                                  function(x)paste(round(mean(x,na.rm = T),2),"±" ,SD = round(sd(x,na.rm = T),2)))
    
    dt.overall$SNR_Class <- GetClass(dt.overall$SNR)
    dt.overall$CTR_Class <- GetClass(dt.overall$CTR)
    dt.overall$RMSE_Class <- GetClass(aList = -dt.overall$RMSE)
    dt.overall$SNR_rank <- paste(rank(-dt.overall$SNR),"/",nrow(dt.overall))
    dt.overall$CTR_rank <- paste(rank(-dt.overall$CTR),"/",nrow(dt.overall))
    dt.overall$RMSE_rank0 <- rank(dt.overall$RMSE,na.last = "keep")
    dt.overall$RMSE_rank <- ifelse(is.na(dt.overall$RMSE_rank0),NA,
                                   paste(dt.overall$RMSE_rank0,"/",nrow(dt.overall)))
    dt.overall$Total_rank <- paste(rank(-dt.overall$Total),"/",nrow(dt.overall))
    
    
    outputdt <- data.table(
        "Quality metrics"= c("Signal-to-Noise Ratio (SNR)","Correlation with Reference Datasets","RMSE of ratios of spike-in pairs","Total Score"),
        "Value" = as.numeric(round(dt.overall["QUERIED DATA",..cols],2)),
        "Historical value (mean ± SD)"= as.character(dt.overall.hist.stat),
        "Rank"= as.character(dt.overall[batch == "QUERIED DATA",c("SNR_rank","CTR_rank","RMSE_rank","Total_rank")]),
        "Performance"= as.character(dt.overall[batch == "QUERIED DATA",c("SNR_Class","CTR_Class","RMSE_Class","Class")])
    )
    write.csv(x = outputdt,file = file.path(output.path,"conclusion_table.csv"),row.names = F,quote = T)
    
}






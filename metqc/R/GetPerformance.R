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
    
    metadata <- metadata[metadata$sample %in% c("D5","D6","F7","M8"),]
    cols <- c("metabolites","HMDBID",metadata$col_names)
    dt <- dt[,..cols]
    
    SNR <- CountSNR(dt=dt,metadata=metadata,output.path = output.path)
    RC <- CountRC(dt=dt,metadata=metadata,output.path = output.path)
    Recall <- CountRecall(dt=dt,metadata=metadata,output.path = output.path)
    
    dt.result <- data.table("QUERIED DATA","SNR"=SNR,"RC"=RC,"Recall"=Recall)
    names(dt.result)[1] <- names(HistoricalData)[1]
    percentile <- ecdf(HistoricalData$Total_normalized)
    HistoricalData$perc <- round(percentile(HistoricalData$Total_normalized)*100,0)
    HistoricalData[Total_normalized == 1]$perc <- 0
    HistoricalData[Total_normalized == 10]$perc <- 100
    
    dt.overall <- rbindlist(list(HistoricalData,dt.result),fill = T)
     
    fn.query <- function(x){
        xMin <- min(x[1:(length(x)-1)], na.rm = TRUE)
        xMax <- max(x[1:(length(x)-1)], na.rm = TRUE)
        
        if (x[length(x)] <= xMin) {return(1)} 
        if (x[length(x)] >= xMax) {return(10)} 
        
        x.norm <- round((10-1)*(x[length(x)] - xMin)/(xMax - xMin)+1,3)
        return(x.norm)
    }
    dt.overall[batchcode == "QUERIED DATA"]$SNR_normalized <- fn.query(dt.overall$SNR)
    dt.overall[batchcode == "QUERIED DATA"]$RC_normalized <- fn.query(dt.overall$RC)
    dt.overall[batchcode == "QUERIED DATA"]$Recall_normalized <- fn.query(dt.overall$Recall)
    cols <- c("SNR_normalized", "RC_normalized","Recall_normalized")
    dt.overall$Total <- apply(dt.overall[,..cols],1,function(x)exp(mean(log(x),na.rm = T)))
    dt.overall[batchcode == "QUERIED DATA"]$Total_normalized <- fn.query(dt.overall$Total)
    
    perc.tt <- HistoricalData[Total_normalized == dt.overall[batchcode == "QUERIED DATA"]$Total_normalized]
    percentile2 <- ecdf(dt.overall$Total_normalized)
    dt.overall[batchcode == "QUERIED DATA"]$perc <- ifelse(nrow(perc.tt)>0,perc.tt$perc,
                                                           round(percentile2(dt.overall[batchcode == "QUERIED DATA"]$Total_normalized)*100,0))
    
    GetClass <- function(aList){
        quantiles <- quantile(aList, probs = seq(0,1,.2),na.rm = T)
        quantiles2 <- quantile(aList, probs = seq(0,1,.25),na.rm = T)
        cutoffs <- c(quantiles[1],quantiles[2],quantiles2[3],quantiles[5],quantiles[6])
        result <- as.character(cut(aList,
                                   breaks = cutoffs, 
                                   include.lowest = T,labels = c("Bad","Fair","Good","Great")))
        return(result)
    }
    
    dt.overall$Class <- GetClass(dt.overall$Total_normalized)
    names(dt.overall)[1] <- "batch"
    setkey(dt.overall,batch)
    
    write.csv(x = dt.overall,file = file.path(output.path,"rank_table.csv"),row.names = F,quote = T)
    
    cols <- c("SNR","RC","Recall","Total")
    dt.overall.hist <- dt.overall[batch != "QUERIED DATA"]
    dt.overall.hist.stat <- apply(dt.overall.hist[batch != "QUERIED DATA",..cols],2, 
                                  function(x)paste(round(mean(x,na.rm = T),2),"±" ,SD = round(sd(x,na.rm = T),2)))
    
    dt.overall$SNR_Class <- GetClass(dt.overall$SNR_normalized)
    dt.overall$RC_Class <- GetClass(dt.overall$RC_normalized)
    dt.overall$Recall_Class <- GetClass(dt.overall$Recall_normalized)
    dt.overall$SNR_rank <- paste(rank(-dt.overall$SNR_normalized,ties.method = "min"),"/",nrow(dt.overall))
    dt.overall$RC_rank <- paste(rank(-dt.overall$RC_normalized,ties.method = "min"),"/",nrow(dt.overall))
    dt.overall$Recall_rank <- paste(rank(-dt.overall$Recall_normalized,ties.method = "min"),"/",nrow(dt.overall))
    dt.overall$Total_rank <- paste(rank(-dt.overall$Total_normalized,ties.method = "min"),"/",nrow(dt.overall))
    

    outputdt <- data.table(
        "Quality metrics"= c("Signal-to-Noise Ratio (SNR)","Relative Correlation with Reference Datasets (RC)","Recall of DAMs in Reference Datasets (Recall)","Total Score"),
        "Value" = as.numeric(round(dt.overall["QUERIED DATA",..cols],3)),
        "Historical value (mean ± SD)"= as.character(dt.overall.hist.stat),
        "Rank"= as.character(dt.overall[batch == "QUERIED DATA",c("SNR_rank","RC_rank","Recall_rank","Total_rank")]),
        "Performance"= as.character(dt.overall[batch == "QUERIED DATA",c("SNR_Class","RC_Class","Recall_Class","Class")])
    )
    write.csv(x = outputdt,file = file.path(output.path,"conclusion_table.csv"),row.names = F,quote = T)
    
    quantiles <- quantile(dt.overall$Total_normalized, probs = seq(0,1,.2),na.rm = T)
    quantiles2 <- quantile(dt.overall$Total_normalized, probs = seq(0,1,.25),na.rm = T)
    cutoffs <- data.frame(c(quantiles[1],quantiles[2],quantiles2[3],quantiles[5],quantiles[6]))
    colnames(cutoffs)[1] <- "Percentile"
    cutoffs$"Cut-off" <- rownames(cutoffs)
    dt.overall.sub <- dt.overall[batch == "QUERIED DATA",c("Total_normalized","perc")]
    dt.overall.sub$perc <- paste0(dt.overall.sub$perc,"%")
    colnames(dt.overall.sub) <- c("Percentile","Cut-off")
    cutoffs.all <- rbind(cutoffs,dt.overall.sub)
    write.csv(x = cutoffs.all,file = file.path(output.path,"cutoff_table.csv"),row.names = F,quote = T)

}






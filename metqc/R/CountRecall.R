# ---------------------------------------------------------------------------------- #
#' @title CountRecall
#'
#' @description Calculate Recall of DAMs
#'
#' @param dt Data table
#' @param metadata Data table
#'
#' @return Numeric vector
#' @importFrom data.table data.table
#' @importFrom data.table melt
#' @importFrom data.table copy
#' @importFrom data.table :=
#' @importFrom data.table setDT
#' @importFrom dplyr group_by
#' @importFrom dplyr %>%	
#' @importFrom stats pairwise.t.test
#' @importFrom stats p.adjust
#'
#' @examples
#' CountRecall(dt=sample_data,metadata=sample_metadata)
#'
#' @export

CountRecall <- function(dt.path=NULL, metadata.path=NULL, output.path = NULL, dt=NULL, metadata=NULL){
    
    if(!is.null(dt.path) & !is.null(metadata.path)){
        dt <- MapIDs(dt.path=dt.path)
        metadata <- fread(metadata.path)
    }
    
    if(is.null(dt.path)){
        dt <- MapIDs(dt = dt)
    }
    
    cols <- metadata$col_names
    setkey(setDT(metadata),col_names)
    
    # remove metabolites without full record
    # 0 recode as NA
    dt.num.0 <- dt[,..cols]
    dt.num.0[dt.num.0 == 0] <- NA
    dt.rmNA <- dt[complete.cases(dt.num.0)]
    
    # log2
    cols <- c("HMDBID",metadata$col_names)
    dt.long <- melt(dt.rmNA[,..cols],id.vars = "HMDBID",variable.name  = "col_names")
    cols <- c("col_names","sample")
    dt.long.info <- data.table(merge(dt.long,metadata[,..cols],by = "col_names"))
    dt.long.info.log2 <- copy(dt.long.info)
    dt.long.info.log2$value <- log2(dt.long.info.log2$value)
    
    # pairwise t test (rstatix)
    mets.hmdb <- unique(dt.long.info.log2$HMDBID)
    dt.log2.stat <- dt.long.info.log2 %>%
        group_by(HMDBID) %>%
        pairwise.t.test(formula = value~sample, p.adjust.method = "holm")
    setDT(dt.log2.stat)
    
    # get log2FC of specific sample pairs (relative to D6)
    dt.log2.stat$mean1 <- sapply(1:nrow(dt.log2.stat),function(x){
        mean(dt.long.info.log2[HMDBID == dt.log2.stat[x,]$HMDBID & sample == dt.log2.stat[x,]$group1,]$value)
    })
    dt.log2.stat$mean2 <- sapply(1:nrow(dt.log2.stat),function(x){
        mean(dt.long.info.log2[HMDBID == dt.log2.stat[x,]$HMDBID & sample == dt.log2.stat[x,]$group2,]$value)
    })
    dt.log2.stat$p.adj2 <- p.adjust(dt.log2.stat$p, method = "holm")
    dt.log2.stat$log2FC <- dt.log2.stat$mean1 - dt.log2.stat$mean2
    
    dt.log2.stat.D6 <- dt.log2.stat[group1 == "D6" |group2 == "D6", ]
    dt.log2.stat.D6$dataset <- ""
    dt.log2.stat.D6[group1 == "D6"]$dataset <- paste0(dt.log2.stat.D6[group1 == "D6"]$group2,"to","D6")
    dt.log2.stat.D6[group2 == "D6"]$dataset <- paste0(dt.log2.stat.D6[group2 == "D6"]$group1,"to","D6")
    
    dt.log2.stat.D6$log2FC <- 0
    dt.log2.stat.D6[group1 == "D6"]$log2FC <- dt.log2.stat.D6[group1 == "D6"]$mean2 - dt.log2.stat.D6[group1 == "D6"]$mean1
    dt.log2.stat.D6[group2 == "D6"]$log2FC <- dt.log2.stat.D6[group2 == "D6"]$mean1 - dt.log2.stat.D6[group2 == "D6"]$mean2
    
    # detected DAMs in RDs
    dt.log2.stat.D6.inRD <- merge(dt.log2.stat.D6,MetReference,by=c("HMDBID","dataset"))
    # identified as DAMs
    dt.log2.stat.D6.inRD.sig <- dt.log2.stat.D6.inRD[p.adj2 < 0.05,]
    
    result <- data.table(N.detected.pairs = nrow(dt.log2.stat.D6.inRD),
                         N.detected.sigpairs = nrow(dt.log2.stat.D6.inRD.sig))

    Recall <- result$N.detected.sigpairs / result$N.detected.pairs

    return(Recall)
}







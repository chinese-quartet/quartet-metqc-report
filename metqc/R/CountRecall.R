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
#' @importFrom reshape2 melt
#' @importFrom data.table copy
#' @importFrom data.table :=
#' @importFrom data.table setDT
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
    
    # pairwise t test (default)
    mets.hmdb <- unique(dt.long.info.log2$HMDBID)
    dt.long.info.log2$sample <- factor(dt.long.info.log2$sample,levels = c("D6","D5","F7","M8"))
    dt.log2.stat <- rbindlist(lapply(mets.hmdb,function(xMet){
        dt.sub <- dt.long.info.log2[HMDBID == xMet,]
        
        if (sd(dt.sub$value) == 0) {
            return(NULL)
        }
        
        dt.ttest <- pairwise.t.test(x=dt.sub$value,g=dt.sub$sample, p.adjust.method = "none")
        dt.ttest.df <- reshape2::melt(dt.ttest$p.value)
        dt.ttest.df.rmNA <- dt.ttest.df[complete.cases(dt.ttest.df),]
        colnames(dt.ttest.df.rmNA) <- c("group1","group2","p")
        dt.ttest.df.rmNA$p.adj <- p.adjust(dt.ttest.df.rmNA$p,method = "holm")
        dt.ttest.df.rmNA$HMDBID <- xMet
        return(dt.ttest.df.rmNA)
    }))
    dt.log2.stat$p.adj2 <- p.adjust(dt.log2.stat$p,method = "fdr")
    
    # get adjusted p of specific sample pairs (relative to D6)
    dt.log2.stat.D6 <- dt.log2.stat[group2 == "D6", ]
    dt.log2.stat.D6$dataset <-  paste0(dt.log2.stat.D6$group1,"to",dt.log2.stat.D6$group2)
    dt.log2.stat.D6.sig <- dt.log2.stat.D6[p.adj2 < 0.05,]
    
    # detected DAMs in RDs
    dt.log2.stat.D6.inRD <- merge(dt.log2.stat.D6,MetReference,by=c("HMDBID","dataset"))
    # identified as DAMs
    dt.log2.stat.D6.inRD.sig <- dt.log2.stat.D6.inRD[p.adj2 < 0.05,]
    
    result <- data.table(N.detected.pairs = nrow(dt.log2.stat.D6.inRD),
                         N.detected.sigpairs = nrow(dt.log2.stat.D6.inRD.sig))

    Recall <- result$N.detected.sigpairs / result$N.detected.pairs

    return(Recall)
}







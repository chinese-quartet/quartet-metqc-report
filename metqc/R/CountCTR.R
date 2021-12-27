# ---------------------------------------------------------------------------------- #
#' @title Calculate and plot CTR
#'
#' @description Calculate correlation to reference datasets and plot related scatter plot
#'
#' @param dt Data table
#' @param metadata Data table
#'
#' @return Numeric vector
#' @importFrom data.table data.table
#' @importFrom data.table rbindlist
#' @importFrom data.table melt
#' @importFrom data.table setDT
#' @importFrom data.table :=
#' @importFrom data.table dcast.data.table
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 geom_point
#' @importFrom ggplot2 theme_bw
#' @importFrom ggplot2 labs
#' @importFrom ggplot2 theme
#' @importFrom ggplot2 scale_color_manual
#' @importFrom ggplot2 scale_alpha_manual
#' @importFrom ggplot2 scale_x_continuous
#' @importFrom ggplot2 scale_y_continuous
#' @importFrom ggplot2 geom_abline
#' @importFrom ggplot2 ggsave
#' @importFrom ggplot2 element_text
#' @importFrom stringr str_split_fixed
#'
#' @examples
#' CountCTR(dt=sample_data,metadata=sample_metadata)
#'
#' @export

CountCTR <- function(dt.path=NULL, metadata.path=NULL, output.path = NULL, dt=NULL, metadata=NULL){
    
    if(!is.null(dt.path) & !is.null(metadata.path)){
        dt <- MapIDs(dt.path=dt.path)
        metadata <- fread(metadata.path)
    }
    
    if(is.null(dt.path)){
        dt <- MapIDs(dt = dt)
    }
    
    RefDataset <- MetReference
    metsinRef <- unique(RefDataset$HMDBID)
    
    metadata$platform <- gsub("Untargeted","U",metadata$strategy)
    metadata$platform <- gsub("Targeted","T",metadata$platform)
    metadata$batchcode <- paste(metadata$platform, metadata$lab, metadata$batch, sep = "_")
    metadata$samplecode <- paste(metadata$batchcode, metadata$sample, sep = "_")

    
    dt.long <- melt(dt[,-c("metabolites")],id.vars = "HMDBID",variable.name  = "col_names")
    dt.long[value == 0]$value <- NA
    dt.long.cp <- dt.long[complete.cases(dt.long),]
    cols <- c("col_names","sample","batchcode","samplecode")
    dt.long.cp.info <- data.table(merge(dt.long.cp,metadata[,..cols],by = "col_names"))
    dt.long.cp.info.log2 <- dt.long.cp.info
    dt.long.cp.info.log2$value <- log2(dt.long.cp.info.log2$value)
    
    togetRe <- dt.long.cp.info[HMDBID %in% metsinRef,]
    # stat numbers, and CV for each samplecode
    cv <- function(x){sd(x, na.rm = T)/mean(x, na.rm=T)}
    togetRe.stat <- togetRe[ , .(COUNT = .N, Mean = mean(value), CV = cv(value)), 
                                               by = c("samplecode","HMDBID")]
    toremove <- togetRe.stat[COUNT < 2 ,c("samplecode","HMDBID"),with = F]
    
    togetRe.log2 <- dt.long.cp.info.log2[HMDBID %in% metsinRef,]
    togetRe.filter <- togetRe.log2[!toremove, on=.(samplecode,HMDBID)]

    cols <- c("HMDBID","sample","value")
    togetRe.ave <- togetRe.filter[,.(log2mean = mean(value)), by = c("HMDBID","sample")]
    togetRe.ave.wide <- dcast.data.table(togetRe.ave,HMDBID~sample,value.var = "log2mean")
    togetRe.ave.wide$D5toD6 <- togetRe.ave.wide$D5 - togetRe.ave.wide$D6
    togetRe.ave.wide$F7toD6 <- togetRe.ave.wide$F7 - togetRe.ave.wide$D6
    togetRe.ave.wide$M8toD6 <- togetRe.ave.wide$M8 - togetRe.ave.wide$D6
    
    cols <- c("HMDBID","D5toD6","F7toD6","M8toD6")
    togetRe.ave.long <- melt(togetRe.ave.wide[,..cols],id.vars = "HMDBID",
                             variable.name = "dataset",value.name = "log2FC")
    
    togetRe.withRef <- merge(togetRe.ave.long,RefDataset,by = c("dataset","HMDBID"))
    togetRe.withRef$type <- ifelse(is.na(togetRe.withRef$SE),"spike-ins","other\nmetabolites")
    
    CTR <- cor(togetRe.withRef$log2FCmedian,togetRe.withRef$log2FC,use = "pairwise.complete.obs",method = "spearman")
    togetRe.withRef$type <- factor(togetRe.withRef$type,levels = c("spike-ins","other\nmetabolites"))

    scplot <- ggplot(togetRe.withRef, aes(x=log2FCmedian, y=log2FC, color=type, alpha = type))+
        geom_point() + 
        scale_color_manual(values = c("other\nmetabolites" = "#999999","spike-ins"="#E41A1C"))+
        scale_alpha_manual(values = c("other\nmetabolites" = 0.8,"spike-ins"= 0.9)) +
        theme(legend.position="right") +
        scale_y_continuous(limits = c(-3,3))+ 
        scale_x_continuous(limits = c(-3,3))+
        labs(x = "Ratios in reference datasets",
             y = "Measured ratios",
             color = "Metabolite type",alpha = "Metabolite type",
             title=sprintf("CTR = %.2f", CTR)) +
        geom_abline(intercept = 0, slope = 1,linetype = "dashed",color="red") +
        theme_bw() + 
        theme(plot.title = element_text(hjust=0.5,size=12)) +
        theme(legend.position = "bottom")
    
    if(is.null(output.path)){
        path <- getwd()
        subDir <- "output"  
        dir.create(file.path(path, subDir), showWarnings = FALSE)
        output.path <- file.path(path,"output")
    } 
    
    write.csv(x = togetRe.withRef,file = file.path(output.path,"CTRtable.csv"),row.names = F)
    ggsave(filename = file.path(output.path,"ScatterPlot_withCTR.png"),scplot,device = "png",
           width = 8.8,height = 8,units = c( "cm"),dpi = 300)
    return(CTR)
}

# ---------------------------------------------------------------------------------- #
#' @title Calculate and plot RC
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
#' @importFrom data.table copy
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
#' CountRC(dt=sample_data,metadata=sample_metadata)
#'
#' @export

CountRC <- function(dt.path=NULL, metadata.path=NULL, output.path = NULL, dt=NULL, metadata=NULL){
    
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
    
    # get relative abundance to D6
    togetRe.log2 <- dt.long.info.log2[HMDBID %in% metsinRef,]
    cols <- c("HMDBID","sample","value")
    togetRe.ave <- togetRe.log2[,.(log2mean = mean(value)), by = c("HMDBID","sample")]
    togetRe.ave.wide <- dcast.data.table(togetRe.ave,HMDBID~sample,value.var = "log2mean")
    togetRe.ave.wide$D5toD6 <- togetRe.ave.wide$D5 - togetRe.ave.wide$D6
    togetRe.ave.wide$F7toD6 <- togetRe.ave.wide$F7 - togetRe.ave.wide$D6
    togetRe.ave.wide$M8toD6 <- togetRe.ave.wide$M8 - togetRe.ave.wide$D6
    
    cols <- c("HMDBID","D5toD6","F7toD6","M8toD6")
    togetRe.ave.long <- melt(togetRe.ave.wide[,..cols],id.vars = "HMDBID",
                             variable.name = "dataset",value.name = "log2FC")
    
    # subset DAMs in RDs
    togetRe.withRef <- merge(togetRe.ave.long,RefDataset,by = c("dataset","HMDBID"))

    # Pearson correlation to RDs
    RC <- cor(togetRe.withRef$Mean,togetRe.withRef$log2FC,
              use = "pairwise.complete.obs",method = "pearson")

    # Scatter plot
    scplot <- ggplot(togetRe.withRef, aes(x=Mean, y=log2FC, color=dataset))+
        geom_point() +
        scale_color_manual(values = c(D5toD6="#4CC3D9",F7toD6="#FFC65D",M8toD6="#F16745")) +
        theme(legend.position="right") +
        scale_y_continuous(limits = c(-3,3))+ 
        scale_x_continuous(limits = c(-3,3))+
        labs(x = "Ratios in reference datasets",
             y = "Measured ratios",
             color = "Sample pair",
             title=sprintf("RC = %.3f", RC)) +
        geom_abline(intercept = 0, slope = 1,linetype = "dashed",color="red") +
        theme_bw() + 
        theme(plot.title = element_text(hjust=0.5,size=12)) 
    
    if(is.null(output.path)){
        path <- getwd()
        subDir <- "output"  
        dir.create(file.path(path, subDir), showWarnings = FALSE)
        output.path <- file.path(path,"output")
    } 
    
    write.csv(x = togetRe.withRef,file = file.path(output.path,"RCtable.csv"),row.names = F)
    ggsave(filename = file.path(output.path,"ScatterPlot_withRC.png"),scplot,device = "png",
           width = 10,height = 8,units = c( "cm"),dpi = 300)
    return(RC)
}

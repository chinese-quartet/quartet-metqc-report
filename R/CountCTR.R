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
#' @importFrom data.table :=
#' @importFrom ggplot2 ggplot
#' @importFrom stringr str_split_fixed
#'
#' @examples
#' CountCTR(sample_data,sample_metadata)
#'
#' @export

CountCTR <- function(dt, metadata){
    RefDataset <- MetReference
    metsinRef <- unique(RefDataset$HMDB_id)
    
    dt.long <- melt(dt,id.vars = "HMDB_id",variable.name  = "col_names")
    dt.long.cp <- dt.long[complete.cases(dt.long),]
    dt.long.cp$value <- 2^dt.long.cp$value
    cols <- c("col_names","sample","recode","longsp")
    dt.long.cp.info <- data.table(merge(dt.long.cp,metadata[,..cols],by = "col_names"))
    
    togetRe <- dt.long.cp.info[HMDB_id %in% metsinRef,]
    togetRe.mean <- togetRe[,.(Mean = mean(value,na.rm = T)),by = c("HMDB_id","longsp","sample","recode")]
    togetRe.mean$N <- togetRe.mean$sample
    togetRe.mean$N <- ifelse(togetRe.mean$sample == "D5",3,1)
    togetRe.mean$N <- ifelse(togetRe.mean$sample == "D6",2,togetRe.mean$N)
    
    togetRe.mean.rep <- togetRe.mean[rep(1:.N,N)][,Indx:=1:.N,by=c("longsp","HMDB_id")]
    togetRe.mean.rep$sample.B <- togetRe.mean.rep$Indx
    togetRe.mean.rep.D5 <- togetRe.mean.rep[sample == "D5",]
    togetRe.mean.rep.D5$sample.B <- gsub(1,"D6",togetRe.mean.rep.D5$sample.B)
    togetRe.mean.rep.D5$sample.B <- gsub(2,"F7",togetRe.mean.rep.D5$sample.B)
    togetRe.mean.rep.D5$sample.B <- gsub(3,"M8",togetRe.mean.rep.D5$sample.B)
    togetRe.mean.rep.D5$sample.B <- paste(togetRe.mean.rep.D5$recode,togetRe.mean.rep.D5$sample.B,sep = "_")
    togetRe.mean.rep.D6 <- togetRe.mean.rep[sample == "D6",]
    togetRe.mean.rep.D6$sample.B <- gsub(1,"F7",togetRe.mean.rep.D6$sample.B)
    togetRe.mean.rep.D6$sample.B <- gsub(2,"M8",togetRe.mean.rep.D6$sample.B)
    togetRe.mean.rep.D6$sample.B <- paste(togetRe.mean.rep.D6$recode,togetRe.mean.rep.D6$sample.B,sep = "_")
    togetRe.mean.rep.F7 <- togetRe.mean.rep[sample == "F7",]
    togetRe.mean.rep.F7$sample.B <- gsub(1,"M8",togetRe.mean.rep.F7$sample.B)
    togetRe.mean.rep.F7$sample.B <- paste(togetRe.mean.rep.F7$recode,togetRe.mean.rep.F7$sample.B,sep = "_")
    togetRe.mean.rep2 <- rbindlist(list(togetRe.mean.rep.D5,togetRe.mean.rep.D6,togetRe.mean.rep.F7))
    
    colnames(togetRe.mean)[c(2,5)] <- c("sample.B","Mean.B")
    cols <- c("HMDB_id","sample.B","Mean.B")
    togetRe.mean.rep.full <- merge(togetRe.mean.rep2,togetRe.mean[,..cols],by = c("HMDB_id","sample.B"))
    togetRe.mean.rep.full$sample.B <- stringr::str_split_fixed(togetRe.mean.rep.full$sample.B,"_",4)[,4]
    togetRe.mean.rep.full$dataset <- paste0(togetRe.mean.rep.full$sample.B,"to",togetRe.mean.rep.full$sample)
    togetRe.mean.rep.full$re <- togetRe.mean.rep.full$Mean.B / togetRe.mean.rep.full$Mean
    
    cols <- c("recode","HMDB_id","dataset","re")
    togetRe.withRef <- merge(togetRe.mean.rep.full[,..cols],RefDataset,by = c("dataset","HMDB_id"))
    togetRe.withRef$type <- ifelse(is.na(togetRe.withRef$recodes),"spike-ins","other\nmetabolites")
    
    CTR <- cor(togetRe.withRef$mean,togetRe.withRef$re,use = "pairwise.complete.obs")
    togetRe.withRef$type <- factor(togetRe.withRef$type,levels = c("spike-ins","other\nmetabolites"))

    scplot <- ggplot(togetRe.withRef, aes(x=mean, y=re, color=type, alpha = type))+
        geom_point() + 
        scale_color_manual(values = c("other\nmetabolites" = "#999999","spike-ins"="#E41A1C"))+
        scale_alpha_manual(values = c("other\nmetabolites" = 0.6,"spike-ins"=1)) +
        theme(legend.position="right") +
        scale_y_log10(limits = c(0.1,10))+ 
        scale_x_log10(limits = c(0.1,10))+
        xlab("Relative metabolic profiles in reference dataset") +
        ylab("Measured ratios between samples") +
        labs(color = "Metabolite type",alpha = "Metabolite type",
             title=sprintf("CTR = %.2f", CTR)) +
        geom_abline(intercept = 0, slope = 1,linetype = "dashed",color="red") +
        theme_bw() + 
        theme(plot.title = element_text(hjust=0.5,size=12)) +
        theme(legend.position = "bottom")
    
    path <- getwd() 
    ggsave(filename = paste0(path,"/ScatterPlot_withCTR.pdf"),scplot,width = 3.8,height = 4)
    return(CTR)
}

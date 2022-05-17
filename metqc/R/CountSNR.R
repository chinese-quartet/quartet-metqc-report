# ---------------------------------------------------------------------------------- #
#' @title Calculate SNR and plot PCA
#'
#' @description Plot PCA and calculate SNR based on the first two principal componants of PCA.
#'
#' @param dt Data table
#' @param metadata Data table
#'
#' @return Numeric vector
#' @importFrom data.table setkey
#' @importFrom data.table fread
#' @importFrom data.table data.table
#' @importFrom data.table rbindlist
#' @importFrom reshape2 melt
#' @importFrom data.table setDT
#' @importFrom data.table :=
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 geom_point
#' @importFrom ggplot2 theme_bw
#' @importFrom ggplot2 labs
#' @importFrom ggplot2 theme
#' @importFrom ggplot2 scale_color_manual
#' @importFrom ggplot2 ggsave
#' @importFrom ggplot2 element_text
#' @examples
#' CountSNR(dt=sample_data,metadata=sample_metadata)
#'
#' @export

CountSNR <- function(dt.path=NULL, metadata.path=NULL, output.path = NULL, dt=NULL, metadata=NULL){
    
    if(!is.null(dt.path) & !is.null(metadata.path)){
        dt <- MapIDs(dt.path=dt.path)
        metadata <- fread(metadata.path)
    }
    
    if(is.null(dt.path)){
        dt <- MapIDs(dt = dt)
    }
    
    cols <- metadata$col_names
    setkey(setDT(metadata),col_names)
    dt.num.0 <- dt[,..cols]
    dt.num.0[dt.num.0 == 0] <- NA
    dt.num.log2 <- apply(dt.num.0, 2, function(x)log2(x))
    dt.num.t.cp <- t(data.frame(dt.num.log2[complete.cases(dt.num.log2),]))

    pca_prcomp <- prcomp(x = dt.num.t.cp,scale. = T)

    pcs <- as.data.frame(predict(pca_prcomp))
    dt.perc.pcs <- data.table(PCX=1:ncol(pcs),
                              Percent=summary(pca_prcomp)$importance[2,],
                              AccumPercent=summary(pca_prcomp)$importance[3,])

    dt.dist <- data.table(ID.A = rep(rownames(pcs),each=nrow(pcs)),
                          ID.B = rep(rownames(pcs),time=nrow(pcs)))

    map <- metadata$sample
    names(map) <- metadata$col_names
    dt.dist$Group.A <- map[dt.dist$ID.A]
    dt.dist$Group.B <- map[dt.dist$ID.B]

    dt.dist[,Type:=ifelse(ID.A==ID.B,'Same',
                          ifelse(Group.A==Group.B,'Intra','Inter'))]
    dt.dist[,Dist:=(dt.perc.pcs[1]$Percent*(pcs[ID.A,1]-pcs[ID.B,1])^2+dt.perc.pcs[2]$Percent*(pcs[ID.A,2]-pcs[ID.B,2])^2)]

    dt.dist.stats <- dt.dist[,.(Avg.Dist=mean(Dist)),by=Type]
    setkey(dt.dist.stats,Type)
    signoise <- dt.dist.stats['Inter']$Avg.Dist/dt.dist.stats['Intra']$Avg.Dist

    signoise_db <- 10*log10(signoise)
    
    pcs$col_names <- rownames(pcs)
    dt.forPlot <- merge(pcs,metadata,by='col_names')
    colors.Quartet <- c(D5="#4CC3D9",D6="#7BC8A4",F7="#FFC65D",M8="#F16745")
    
    pcaplot <- ggplot(dt.forPlot,aes(x=PC1,y=PC2)) +
        geom_point(aes(color=sample),
                   size=3) + theme_bw()+
        labs(x=sprintf("PC1: %.1f%%", summary(pca_prcomp)$importance[2,1]*100),
             y=sprintf("PC2: %.1f%%", summary(pca_prcomp)$importance[2,2]*100),
             color='sample',
             title=sprintf("SNR = %.2f", signoise_db))+
        theme(plot.title = element_text(hjust=0.5,size=12))+
        scale_color_manual(values=colors.Quartet) +
        theme(legend.position = "right")
    
    
    if(is.null(output.path)){
        path <- getwd()
        subDir <- "output"  
        dir.create(file.path(path, subDir), showWarnings = FALSE)
        output.path <- file.path(path,"output")
    } 
    
    write.csv(x = dt.forPlot,file = file.path(output.path,"PCAtable.csv"),row.names = F)
    ggsave(filename = file.path(output.path,"PCA_withSNR.png"),pcaplot,
           device = "png",width = 10,height = 8,units = c( "cm"),dpi = 300)
    return(signoise_db)
}




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
#' @importFrom data.table data.table
#' @importFrom data.table :=
#' @importFrom ggplot2 ggplot
#'
#' @examples
#' CountSNR(sample_data,sample_metadata)
#'
#' @export

CountSNR <- function(dt, metadata){
    cols <- metadata$col_names
    #!!!!!!!!!!!!!!!! Must set key
    setkey(setDT(metadata),col_names)
    dt.num <- subset(x = dt,select = cols)
    dt.num.t.cp <- t(data.frame(dt.num[complete.cases(dt.num),]))

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
        theme(legend.position = "bottom")
    
    path <- getwd()
    ggsave(filename = paste0(path,"/PCA_withSNR.pdf"),pcaplot,width = 4,height = 4)
    return(signoise_db)
}




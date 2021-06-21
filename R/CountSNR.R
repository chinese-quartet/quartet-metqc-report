# ----------------------------------------------------------------------------------#
#' @import data.table
#'
#' @title Calculate SNR
#'
#' @description Use the top two principal componants in PCA plot for the calculation of SNR.
#'
#' @param dt Data table
#' @param metadata Data table
#'
#' @return Numeric vector
#' @import data.table
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

    dt.dist.stats <- dt.dist[,.(Avg.Dist=mean(Dist)),by=.(Type)]
    setkey(dt.dist.stats,Type)
    signoise <- dt.dist.stats['Inter']$Avg.Dist/dt.dist.stats['Intra']$Avg.Dist

    signoise_db <- 10*log10(signoise)
    return(signoise_db)
}




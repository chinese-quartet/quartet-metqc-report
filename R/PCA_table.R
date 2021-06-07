# ----------------------------------------------------------------------------------#
#' Plot PCA
#' NOTE: with all PCs
#'
#' @import data.table
#' @param dt Data table
#' @param expDesign Data table, with a column named "col_names"
#'
#' @return Data table
#'
#' @examples
#' dt <- fread("./log2data.csv")
#' metadata <- fread("./metadata.csv")
#' PCA_table(dt,metadata)
#'
#' @export


PCA_table <- function(dt,metadata){
    cols <- metadata$col_names
    dt.t <- data.frame(t(na.omit(dt[,..cols])))
    dt.pca <- prcomp(x = dt.t)

    pca_prcomp <- dt.pca
    pcs <- as.data.frame(predict(pca_prcomp))
    pcs$col_names <- rownames(pcs)
    dt.forPlot <- merge(pcs,metadata,by='col_names')

    return(dt.forPlot)
}




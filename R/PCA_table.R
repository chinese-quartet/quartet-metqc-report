# ----------------------------------------------------------------------------------#
#' @title Export table to plot PCA
#' @description NOTE: with all PCs exported
#'
#' @import data.table
#' @param dt Data table
#' @param metadata Data table, with a column named "col_names"
#'
#' @return Data table
#'
#' @examples
#' PCA_table(sample_data,sample_metadata)
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




# ---------------------------------------------------------------------------------- #
#' @title Calculate and RMSE
#'
#' @description Calculate RMSE of ratios of spike-in pairs
#'
#' @param dt Data table
#' @param metadata Data table
#'
#' @return Numeric vector
#' @importFrom data.table data.table
#' @importFrom data.table melt
#' @importFrom data.table :=
#'
#' @examples
#' CountRMSE(dt=sample_data,metadata=sample_metadata)
#'
#' @export

CountRMSE <- function(dt.path=NULL, metadata.path=NULL, output.path = NULL, dt=NULL, metadata=NULL){
    
    if(!is.null(dt.path) & !is.null(metadata.path)){
        dt <- MapIDs(dt.path=dt.path)
        metadata <- fread(metadata.path)
    }
    
    if(is.null(dt.path)){
        dt <- MapIDs(dt = dt)
    }
    
    spikeins <- c(SpikeinRatios$ID.A,"HMDB0000138")
    dt.spins <- dt[HMDBID %in% spikeins]
    
    if(nrow(dt.spins) < 3 | !("HMDB0000138" %in% dt.spins$HMDBID)){
        return(NA)
    }
    
    dt.spins.long <- melt(dt.spins[HMDBID != "HMDB0000138",-"metabolites"],id.vars = "HMDBID")
    dt.spins.ref <- melt(dt.spins[HMDBID == "HMDB0000138",-"metabolites"],id.vars = "HMDBID",value.name = "HMDB0000138")
    dt.spins.full <- merge(dt.spins.long,dt.spins.ref[,c("variable","HMDB0000138")],by = c("variable"))
    dt.spins.full$re <-  dt.spins.full$value / dt.spins.full$HMDB0000138
    dt.spins.full.true <- merge(dt.spins.full,SpikeinRatios,by.x = "HMDBID",by.y = "ID.A")
    
    RMSE <- sqrt(mean((dt.spins.full.true$ratio - dt.spins.full.true$re)^2))
    return(RMSE)
}







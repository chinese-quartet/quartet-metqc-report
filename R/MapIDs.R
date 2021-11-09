# ---------------------------------------------------------------------------------- #
#' @title Pre-process dataset
#'
#' @description Map the name of metabolites to the existing ID files.
#'
#' @param dt Data table
#'
#' @return Numeric vector
#' @importFrom data.table data.table
#'
#' @examples
#' MapIDs(dt=sample_data)
#'
#' @export


MapIDs <- function(dt.path=NULL, dt=NULL){
    if(!is.null(dt.path)){
        dt <- fread(dt.path)
    }
    
    map <- MetInfo$HMDBID
    names(map) <- MetInfo$metabolites
    
    dt[is.na(HMDBID)]$HMDBID <- map[dt[is.na(HMDBID)]$metabolites]
    if(sum(is.na(dt$HMDBID))){
        dt[is.na(HMDBID)]$HMDBID <- sprintf("Unknown%04s",171:(170+nrow(dt[is.na(HMDBID)])))
    }
    return(dt)
}
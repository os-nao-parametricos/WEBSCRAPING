#' @function character.to.na
#' @param x - string
#' 
#' @return convert character(0) to NA

# character.to.na ---------------------------------------------------------

character.to.na <- function(x){
  
  if(identical(x,character(0))) {
    x <- NA  
  } else x
}

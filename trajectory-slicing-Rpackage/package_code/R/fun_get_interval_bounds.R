#' get_interval_bounds
#'
#' This utility function is to be used together with the "cut" function of base R. The "cut" function allows you to "bin" a continuous numerical variable, returning a character vector as output.
#' Often, instead of a string describing the bin you want instead to have the lower limit and the upper limit for each bin that is returned by the "cut" function. The present function does precisely that.
#'
#'
#' @param x <character vector> character vector as returned by the "cut" function in BASE R.
#' @param name_prefix <string> a prefix to be included for the column names of the output variables (representing the lower limit and the upper limit of the bin). If this is "", the default,
#' then the output column names are simply "inf" and "sup". If, for example you put name_prefix = "latitude", then the output names will be "latitude_inf" and "latitude_sup".
#'
#' @return <data frame> this returns a data frame with two columns. The present function is meant to be used within a tidyr pipe
#' (within dplyr::mutate, more specifically). For example:
#' "mydf = mydf \%>\% dplyr::mutate(get_interval_bounds(latitude, name_prefix = "latitude"))"
#' @export
#'
#' @examples
#'
#' test_vec = cut(1:10, seq(0,10,2))
#' get_interval_bounds(test_vec, "var")
#'
get_interval_bounds = function (x, name_prefix = "")
{
  lim_inferior = gsub("\\(", "", x)
  lim_inferior = gsub("\\[", "", lim_inferior)
  lim_inferior = gsub(",.*", "", lim_inferior)
  lim_inferior = as.numeric(lim_inferior)

  lim_superior = gsub(".*,", "", x)
  lim_superior = gsub("\\]", "", lim_superior)
  lim_superior = as.numeric(lim_superior)

  outframe = data.frame(inf = lim_inferior, sup = lim_superior)
  if (name_prefix != ""){names(outframe) = paste0(name_prefix,"_",names(outframe))}
  return(outframe)
}



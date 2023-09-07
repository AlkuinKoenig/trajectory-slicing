#' get_slice_crossing_df
#'
#' @param traj_df <data.frame> a data frame containing the trajectory information. The following columns MUST be present.
#' 1: ID columns that (see below under "ID_columns")
#' 2: lat_i: <numeric> latitude of trajectory emission
#' 3: lon_i: <numeric> longitude of trajectory emission
#' 4: hour_along: <numeric> hours since trajectory emission. If not 0, this should be negative for back trajectories and positive for forward trajectories
#' 5: If "radial slices" are to be computed: radius: <numeric> radius from trajectory endpoint to radial center (point of emission).
#' 6: "" "" "": angle: <circular> angle between trajectory endpoing and radial center (point of emission)
#' 7: all additional columns specified in "extra_vars"
#'
#' For "radial slices", the user should calculate the "radius" and "angle" columns beforehand. This is not done within the function.
#' If necessary, the user should also rename the columns of the input trajectory data frame accordingly (e.g. "longitude" --> "lon").
#'
#' @param slice_type <one of c("radial","latitudinal","longitudinal")>
#' If "radial": Find where a trajectory crossed a circle (usually centerd on the point of emission)
#' If "latitudinal": Find where a trajectory crossed a certain latitude (for example 0, the equator)
#' If "longitudinal": Find where a trajectory crossed a certain longitude
#'
#' @param slice_position <numeric vector> for which values should the slices be computed?
#' Interpreted as radius if slice_type == "radial", as latitude if slice_type == "latitudinal", and as longitude if slice_type == "longitudinal"
#' @param extra_vars <character vector> column names of any additional variables for which the value at slice crossing should be computed. For example: c("air_temp","sp_humidity")
#' @param delta_filter <numeric> filtering parameter to speed up computation. The idea is to only look at rows that are "close" to the slice that is to be crossed.
#' You generally want delta_filter to correspond to the maximum distance (in longitude, latitude, or radius) that you expect a trajectory to cross within one time step.
#' Ideally, you would check an adequate value before using this function, but for HYSPLIT and hourly endpoints, ~ 3 is usually safe.
#' @param ID_columns <undefined type> The name of one (or several) columns to be used as ID for each trajectory. Each trajectory should correspond to
#' a unique combination of values in the ID columns. For example, if trajectories were released from one single emission point, then the time of
#' emission could be used as ID, like ID_columns = c("time_of_emission") (note that this is a placeholder name).
#' If you also emitted trajectories from different altitudes, for example, then at least one column should represent this
#' information, e.g. ID_columns = c("time_of_emission","altitude_of_emission")
#'
#' @return <data.frame> A data.frame with information on where a slice was crossed:
#' 1: How was the slice crossed? <one of c("decreasing","increasing","no crossing")>.
#'   a) "decreasing" means that the trajectory passed from "larger than the slice position" to "lower than the slice position".
#'     For example, in "radial" this would correspond to a trajectory moving closer to the radial centerpoint (usually point of emission).
#'   b) "increasing" means the opposite of decreasing.
#'   c) "no crossing" means that the trajectory defined by c(ID_location, ID_time) did not cross the respective slice.
#'     This information comes in handy for normalization.
#' 2: the mean coordinates (and additional variable values) at slice crossing. "wmean" means weighted mean, which is calculated by default.
#' @export
#'
#' @examples
get_slice_crossing_df = function(traj_df,  slice_type = "radial", slice_position, ID_columns = c("ID"),
                                 extra_vars = c("height"), delta_filter = 10){

  #Preparation and sanity checks----------------------------
  delta_column = case_when(slice_type == "radial" ~ "radius",
                           slice_type == "latitudinal" ~ "lat",
                           slice_type == "longitudinal" ~ "lon")

  if(is.na(delta_column)){warning(paste0("Error: ", slice_type, " is an invalid slice type")); return(NULL)}

  summary_vars = case_when(slice_type == "radial" ~ c("hour_along","radius","angle", extra_vars),
                           slice_type == "latitudinal" ~ c("hour_along","lat","lon", extra_vars),
                           slice_type == "longitudinal" ~ c("hour_along","lat","lon", extra_vars))

  select_vars = c(ID_columns,"lat_i","lon_i",summary_vars)

  for (i in 1:length(select_vars)){
    if (!(select_vars[i] %in% names(traj_df))) {warning(paste0("Error: Column ", select_vars[i], " not present in input data frame. "));
      return(NULL)}
  }
  #----------------------------------------------------------------

  #main computation
  traj_df.sliced = traj_df %>%
    dplyr::select(all_of(select_vars))%>%
    dplyr::mutate(position_delta = get(delta_column) - slice_position)%>%
    #some filtering to save computational time (We don't need to look at points, but points close to the "slice")
    dplyr::filter(abs(position_delta) <= delta_filter)%>%
    dplyr::group_by(across(all_of(ID_columns)))%>%
    dplyr::arrange(hour_along)%>%
    dplyr::mutate(position_delta_before = lag(position_delta,1),
                  crossing_type = case_when(position_delta <= 0 & position_delta_before>0 ~ "decreasing",
                                            position_delta >= 0 & position_delta_before<0 ~ "increasing",
                                            1 ==1 ~ "no crossing"))%>%
    #To use both "x" and "lagged x" later within rowwise and across, I codify the information as a string and later de-codify it again. Kind of a workaround, but works.
    dplyr::mutate(across(.cols = all_of(summary_vars), .fns = function(x){paste0(x,"_",lag(x,1))}, .names = "{.col}_c"))%>%
    # as "angle" is circular, it gets special treatment, but only if it exists
    {if("angle" %in% summary_vars) dplyr::mutate(., angle_before = lag(angle,1)) else .}%>%
    # another filtering that saves time. We only look at crossings of the slice now.
    dplyr::filter(crossing_type %in% c("decreasing","increasing"))%>%
    rowwise()%>% #rowwise because for each row, we want to compute operations between a variable and the same variable one time step before
    dplyr::mutate(across(.cols = paste0(summary_vars[summary_vars != "angle"],"_c"),
                         .fns = function(x){ weighted.mean(c(as.numeric(gsub("_.*","",x)), as.numeric(gsub(".*_","",x))),
                                                           w = abs(c(1/position_delta, 1/position_delta_before)))},
                         .names="{gsub('_c','',.col)}_wmean"))%>%
    #Again, angle is circular so it get's special treatment.
    {if("angle" %in% summary_vars) dplyr::mutate(., angle_wmean = weighted.mean.circular(x=c(angle,angle_before),
                                                                                         w = abs(c(1/position_delta, 1/position_delta_before)))) else .}%>%

    #cleanup of unwanted columns in the output
    dplyr::select(!ends_with("_c") & !contains("_before") &!one_of(summary_vars))%>%
    dplyr::ungroup()%>% #undoing rowwise
    # joining back initial info so that all IDs are present in the output
    dplyr::full_join(., traj_df %>% dplyr::select(ID_columns)%>%unique(),
                     by = ID_columns)%>%
    #adding metadata
    dplyr::mutate(crossing_type = ifelse(is.na(crossing_type), "no crossing", crossing_type))%>%
    dplyr::mutate(slice_position = slice_position,
                  slice_type = slice_type,
                  .before = crossing_type)


  return(traj_df.sliced)
}#get_slice_crossing_df



# get_slice_crossing_df = function(traj_df,  slice_type = "radial", slice_position, extra_vars = "height", delta_filter = 10){
#
#   #Preparation and sanity checks----------------------------
#   delta_column = case_when(slice_type == "radial" ~ "radius",
#                            slice_type == "latitudinal" ~ "lat",
#                            slice_type == "longitudinal" ~ "lon")
#
#   if(is.na(delta_column)){warning(paste0("Error: ", slice_type, " is an invalid slice type")); return(NULL)}
#
#   summary_vars = case_when(slice_type == "radial" ~ c("hour_along","radius","angle", extra_vars),
#                            slice_type == "latitudinal" ~ c("hour_along","lat","lon", extra_vars),
#                            slice_type == "longitudinal" ~ c("hour_along","lat","lon", extra_vars))
#
#   select_vars = c("ID_time", "ID_location","lat_i","lon_i",summary_vars)
#
#   for (i in 1:length(select_vars)){
#     if (!(select_vars[i] %in% names(traj_df))) {warning(paste0("Error: Column ", select_vars[i], " not present in input data frame. "));
#       return(NULL)}
#   }
#   #----------------------------------------------------------------
#
#   #main computation
#   traj_df.sliced = traj_df %>%
#     dplyr::select(all_of(select_vars))%>%
#     dplyr::mutate(position_delta = get(delta_column) - slice_position)%>%
#     #some filtering to save computational time (We don't need to look at points, but points close to the "slice")
#     dplyr::filter(abs(position_delta) <= delta_filter)%>%
#     dplyr::group_by(ID_time, ID_location)%>%
#     dplyr::arrange(hour_along)%>%
#     dplyr::mutate(position_delta_before = lag(position_delta,1),
#                   crossing_type = case_when(position_delta <= 0 & position_delta_before>0 ~ "decreasing",
#                                             position_delta >= 0 & position_delta_before<0 ~ "increasing",
#                                             1 ==1 ~ "no crossing"))%>%
#     #To use both "x" and "lagged x" later within rowwise and across, I codify the information as a string and later de-codify it again. Kind of a workaround, but works.
#     dplyr::mutate(across(.cols = all_of(summary_vars), .fns = function(x){paste0(x,"_",lag(x,1))}, .names = "{.col}_c"))%>%
#     # as "angle" is circular, it gets special treatment, but only if it exists
#     {if("angle" %in% summary_vars) dplyr::mutate(., angle_before = lag(angle,1)) else .}%>%
#     # another filtering that saves time. We only look at crossings of the slice now.
#     dplyr::filter(crossing_type %in% c("decreasing","increasing"))%>%
#     rowwise()%>% #rowwise because for each row, we want to compute operations between a variable and the same variable one time step before
#     dplyr::mutate(across(.cols = paste0(summary_vars[summary_vars != "angle"],"_c"),
#                          .fns = function(x){ weighted.mean(c(as.numeric(gsub("_.*","",x)), as.numeric(gsub(".*_","",x))),
#                                                            w = abs(c(1/position_delta, 1/position_delta_before)))},
#                          .names="{gsub('_c','',.col)}_wmean"))%>%
#     #Again, angle is circular so it get's special treatment.
#     {if("angle" %in% summary_vars) dplyr::mutate(., angle_wmean = weighted.mean.circular(x=c(angle,angle_before),
#                                                                                          w = abs(c(1/position_delta, 1/position_delta_before)))) else .}%>%
#
#     #cleanup of unwanted columns in the output
#     dplyr::select(!ends_with("_c") & !contains("_before") &!one_of(summary_vars))%>%
#     dplyr::ungroup()%>%
#     # joining back initial info so that all IDs are present in the output
#     dplyr::full_join(., traj_df %>% dplyr::select(ID_time, ID_location)%>%unique(),
#                      by = c("ID_time", "ID_location"))%>%
#     #adding metadata
#     dplyr::mutate(crossing_type = ifelse(is.na(crossing_type), "no crossing", crossing_type))%>%
#     dplyr::mutate(slice_position = slice_position,
#                   slice_type = slice_type,
#                   .before = crossing_type)
#
#
#   return(traj_df.sliced)
# }#get_slice_crossing_df

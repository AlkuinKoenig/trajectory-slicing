#' create_radial_guide_df
#'
#' creates a df containing necessary information to plot a "radial reference system" on a map. This is, concentric cycles centered on the
#' centerpoint of the polar reference system.
#'
#' @param slice_radius <numeric vector> radii (in geographical degrees) for the slices
#' @param lat_center <numeric> center latitude of the circles
#' @param lon_center <numeric> center longitude of the circles
#' @param stepwidth <numeric> angle (in degrees) between steps.
#'
#' @return <data.frame> Contains several columns, among them the radius and angle of the polar coordinate system and the corresponding lat-lon coordinates (if you want to plot this on a lat-lon grid, fore example over a map).
#' The "angle" column is contained in two formats: "angle" is given in "0 to 360 degree" format (with N = 0, E=90, S=180 and W=270),
#' "angle2" is given in "-180 to 180 degree format (with N = 0, E=90, S = 180/-180, W = -90).
#'
#' @export
#'
#' @examples
#'#create a radial slice dataframe centered on 16.35S, 68.13W (check google maps ;))
#' radial_slice_df = create_radial_guide_df(slice_radius=c(5,10,15),lat_center = -16.35, lon_center = -68.13)
#'
#' library(ggplot2)
#'
#' #plot all the circles
#' ggplot(radial_slice_df, aes(x=lon, y = lat, group= slice_position))+
#'   geom_path()+
#'   coord_fixed(xlim = quantile(radial_slice_df$lon, c(0,1)), ylim = quantile(radial_slice_df$lat, c(0,1)))
#'
#' #plot for all circles only the first quadrant
#' ggplot(subset(radial_slice_df, angle <=90), aes(x=lon, y = lat, group= slice_position))+
#'   geom_path()+
#'   coord_fixed(xlim = quantile(radial_slice_df$lon, c(0,1)), ylim = quantile(radial_slice_df$lat, c(0,1)))
#'
#' #plot for all circles only the arc between 150 degrees and -150 degrees (in the -180 to 180 degree definition, North = 0)
#' ggplot(subset(radial_slice_df, angle_180 >= 150 | angle_180 <=-150), aes(x=lon, y = lat, group= slice_position))+
#'   geom_path()+
#'   coord_fixed(xlim = quantile(radial_slice_df$lon, c(0,1)), ylim = quantile(radial_slice_df$lat, c(0,1)))
#'
create_radial_guide_df = function(slice_radius, lat_center,lon_center, stepwidth = 0.5){
  radial_frame = expand.grid(slice_position = slice_radius, angle = seq(0,360,stepwidth))%>%
    #I create a rotated angle column because by default sinus and cosinus place "0" degrees to the east. But we want 0 degrees to point north
    dplyr::mutate(angle_temp = (angle-90)%%360)%>%
    dplyr::mutate(lat = -sin(angle_temp*2*pi/360)*slice_radius + lat_center ,
                  lon = cos(angle_temp*2*pi/360)*slice_radius + lon_center)%>%
    #If the -180 to 180 degrees definition of an angle is preferred, this column can come in handy, for example for subsetting
    dplyr::mutate(angle_180 = ifelse(angle <=180, angle, angle - 360))%>%
    dplyr::mutate(lat_center = lat_center, lon_center = lon_center, .before = 1)%>%#metadata
    dplyr::select(-angle_temp)#cleanup

  return(radial_frame)
}

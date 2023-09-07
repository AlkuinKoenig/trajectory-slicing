#' plot_cyl_surface_on_map
#'
#' visualizes the radii of the selected cylindrical surfaces on a map.
#'
#' @param lat_center <numerical> latitude of center point for radius
#' @param lon_center <numerical> longitude of center point for radius
#' @param radselect <numerical vector> radii to be plotted on map
#' @param angle_marks <numerical vector> angles, at which marks should be added. Defaults to c(0,90,180,270)
#' @param radius_marks <numerical vector> radii, at which marks should be added. Defaults to all angle_marks
#' @param xlim <c(lon_min, lon_max)> longitude limits of the map to be plotted
#' @param ylim <c(lat_min, lat_max)> latitude limits of the map to be plotted
#'
#' @return a ggplot object
#' @export
#'
#' @examples #none
plot_cyl_surface_on_map = function(lat_center, lon_center,radselect, angle_marks = seq(0,270,90),
                                   radius_marks = radselect,
                                   xlim = c(-180,180), ylim = c(-90,90)){

  polar_to_latlon = function(radius, angle){
    lat = cos(angle/360*2*pi)*radius
    lon = sin(angle/360*2*pi)*radius
    return(list(lat,lon))
  }


  dummyraster =raster(xmn = -180, xmx = 180, ymn = -90, ymx = 90, res = c(1,1))
  values(dummyraster) = NA

  circle_frame =expand.grid(angle = seq(0,360,1),
                            radius = radselect)%>%
    dplyr::mutate(lat_d = polar_to_latlon(radius,angle)[[1]],
                  lon_d = polar_to_latlon(radius,angle)[[2]],
                  lat = lat_d + lat_center,
                  lon = lon_d  + lon_center)

  worldmap = plot_rasterlayer_on_map(dummyraster, xlim = xlim,ylim=ylim)+
    geom_path(data=circle_frame,aes(x=lon, y=lat, col=as.factor(radius)),size=1)+
    geom_label(data=circle_frame%>%dplyr::filter(angle %in% angle_marks, radius %in% radius_marks),
               aes(x=lon,y=lat,label=angle,col=as.factor(radius)), fontface="bold", show.legend = FALSE)+
    labs(col = "radius")

  worldmap
}

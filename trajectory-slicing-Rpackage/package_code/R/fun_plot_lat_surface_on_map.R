#' plot_lat_surface_on_map
#'
#' visualizes the latitudes of the selected latitudinal surfaces on a map.
#'
#' @param latselect <numerical vector> latitudes to be plotted on map
#' @param xlim <c(lon_min, lon_max)> longitude limits of the map to be plotted
#' @param ylim <c(lat_min, lat_max)> latitude limits of the map to be plotted
#'
#' @return a ggplot object
#' @export
#'
#' @examples #none
plot_lat_surface_on_map = function(latselect,
                                   xlim = c(-180,180), ylim = c(-90,90)){


  dummyraster =raster(xmn = -180, xmx = 180, ymn = -90, ymx = 90, res = c(1,1))
  values(dummyraster) = NA

  line_frame =expand.grid(lon = seq(-180,180,1),
                            lat = latselect)

  worldmap = plot_rasterlayer_on_map(dummyraster, xlim = xlim,ylim=ylim)+
    geom_path(data=line_frame,aes(x=lon, y=lat, col=as.factor(lat)),size=1)+
    labs(col = "latitude")

  worldmap
}

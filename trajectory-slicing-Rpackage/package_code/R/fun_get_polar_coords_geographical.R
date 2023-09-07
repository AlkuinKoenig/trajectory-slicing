#' get_polar_coords_geographical
#'
#' converts coordinates from a latitude - longitude format into polar (cylindrical) coordinates with respect to a center point.
#' Cylindrical coordinates are defined by the angle from the North (north = 0), and by the radius (in "geographical degrees", i.e. radius = sqrt((latitude_difference)^2) + (longitude_difference)^2).
#' \cr\cr
#' This function takes into account that the earth is round and that longitude is a circular variable.
#' This means, that to get from one point to another point on the same latitude, you can go either east or west - but one of the pathways will be longer.
#' This function considers the shorter of the two possible pathways. For example, a point with coordinates
#' lon = -179, lat = 0 will be EAST (angle = 90 degrees) of a centerpoint with coordinates lon = 179, lat = 0.
#' \cr\cr
#' The geographical longitude could be conceivable given in -180 to 180 degrees format, or in 0 to 360 degrees format. This function works for both.
#'
#' @param lat <numerical> latitude of point whose polar coordinates should be determined
#' @param lon <numerical> longitude of point whose polar coordinates should be determined
#' @param latcenter <numerical> latitude of the center of the polar coordinate system (For example, the emission point of back trajectories)
#' @param loncenter <numerical> longitude of the center of the polar coordinate system (For example, the emission point of back trajectories)
#'
#' @return <data.frame> a data frame with two columns: 1) the radius from the point in question to the polar centerpoint (in geographical degrees), and
#' 2) the angle from the point in question to the polar centerpoint (in degrees from North, with N = 0, E = 90, S = 180, and W = 270).
#' The radius is given as a regular numeric variable, while the angle is given as a "circular" variable. (see "circular" package).\cr
#' The present function is meant to be used within a tidyr pipe (within dplyr::mutate, more specifically). For example:\cr
#' mydf = mydf \%>\% dplyr::mutate(get_polar_coords_geographical(lat, lon, latcenter, loncenter))
#' @export
#'
#' @examples
#' get_polar_coords_geographical(0, -179, 0, 179) #-180 to 180 degrees format
#' get_polar_coords_geographical(0, 181, 0, 179) # 0 to 360 degrees format
get_polar_coords_geographical = function(lat,lon,latcenter,loncenter){


  lat_to_cent=lat-latcenter

  lon_to_cent_1= ((lon-loncenter) %% 360) - 360
  lon_to_cent_2= (((lon-loncenter) %% 360) - 360) %%360
  lon_to_cent = ifelse(abs(lon_to_cent_1) < abs(lon_to_cent_2), lon_to_cent_1, lon_to_cent_2)

  angle_deg=coord2rad(lat_to_cent,lon_to_cent,control.circular = list(type="angles", units = "degrees",modulo="2pi", zero=0))
  radius=sqrt((lat_to_cent^2+lon_to_cent^2))

  return(data.frame(radius = radius, angle=angle_deg))
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fun_plot_cyl_surface_on_map.R
\name{plot_cyl_surface_on_map}
\alias{plot_cyl_surface_on_map}
\title{plot_cyl_surface_on_map}
\usage{
plot_cyl_surface_on_map(
  lat_center,
  lon_center,
  radselect,
  angle_marks = seq(0, 270, 90),
  radius_marks = radselect,
  xlim = c(-180, 180),
  ylim = c(-90, 90)
)
}
\arguments{
\item{lat_center}{<numerical> latitude of center point for radius}

\item{lon_center}{<numerical> longitude of center point for radius}

\item{radselect}{<numerical vector> radii to be plotted on map}

\item{angle_marks}{<numerical vector> angles, at which marks should be added. Defaults to c(0,90,180,270)}

\item{radius_marks}{<numerical vector> radii, at which marks should be added. Defaults to all angle_marks}

\item{xlim}{<c(lon_min, lon_max)> longitude limits of the map to be plotted}

\item{ylim}{<c(lat_min, lat_max)> latitude limits of the map to be plotted}
}
\value{
a ggplot object
}
\description{
visualizes the radii of the selected cylindrical surfaces on a map.
}
\examples{
#none
}

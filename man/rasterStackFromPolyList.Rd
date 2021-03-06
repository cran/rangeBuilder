\name{rasterStackFromPolyList}
\alias{rasterStackFromPolyList}
\title{Polygon List to rasterStack}
\usage{
rasterStackFromPolyList(polyList, resolution = 50000,
  retainSmallRanges = TRUE, extent = "auto", nthreads = 1)
}
\arguments{
\item{polyList}{a list of SpatialPolygon objects, named with taxon names}

\item{resolution}{vertical and horizontal size of raster cell, in units 
of the polygons' projection}

\item{retainSmallRanges}{boolean; should small ranged species be dropped or preserved.
See details.}

\item{extent}{if 'auto', then the maximal extent of the polygons will be used. 
If not auto, must be a numeric vector of length 4 with minLong, maxLong, minLat, maxLat.}

\item{nthreads}{number of threads to use for parallelization of the function. The R
package    \code{parallel} must be loaded for \code{nthreads > 1}.}
}
\value{
an object of class \code{RasterStack} where all rasters contain values of 
either NA or 1.
}
\description{
Takes a list of polygons and creates a rasterStack.
}
\details{
In the rasterization process, all cells for which the polygon covers the midpoint are
	considered as present and receive a value of 1. If \code{retainSmallRanges = FALSE}, 
	then species whose ranges are so small that no cell registers as present will be 
	dropped. If \code{retainSmallRanges = TRUE}, then the cells that the small polygon
	is found in will be considered as present.
}
\examples{

\dontrun{
data(crotalus)

# standardize species names
crotalus$genSp <- synonymMatch(crotalus$genSp, db='squam')

# get 10 species occurrence sets
uniqueSp <- unique(crotalus$genSp)[1:10]
uniqueSp <- uniqueSp[complete.cases(uniqueSp)]

# create range polygons
ranges <- vector('list', length = length(uniqueSp))
for (i in 1:length(uniqueSp)) {
	x <- crotalus[which(crotalus$genSp == uniqueSp[i]),]

	ranges[[i]] <- getDynamicAlphaHull(x, coordHeaders = c('decimallongitude', 
		'decimallatitude'), clipToCoast = 'terrestrial')
}

# name the polygons
names(ranges) <- uniqueSp

# keep only the polygons
ranges <- lapply(ranges, function(x) x[[1]])

# Create a rasterStack with the extent inferred from the polygons, and a cell
# resolution of 0.2 degrees.
# cells with the presence of a species get a value of 1, NA if absent. 

rangeStack <- rasterStackFromPolyList(ranges, resolution = 0.2)

# calculate species richness per cell, where cell values are counts of species
richnessRaster <- calc(rangeStack, fun=sum, na.rm = TRUE)

# set values of 0 to NA
richnessRaster[richnessRaster == 0] <- NA

#plot
ramp <- colorRampPalette(c('blue','yellow','red'))
plot(richnessRaster, col=ramp(100))

plot(gshhs, add = TRUE, lwd=0.5)

}
}
\author{
Pascal Title
}

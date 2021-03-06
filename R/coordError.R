# function to take coordinates, and determine the maximum amount of error in meters from the lack of coordinate precision

# input expected as numeric vector of long, lat in decimal degrees

coordError <- function(coords, nthreads = 1) {
		
	calcError <- function(xy) {
		# determine number of decimal places
		if (any(is.na(xy))) {
			return(NA)
		} else {
			if (grepl('\\.', xy[1])) {
				longDecPlaces <- nchar(strsplit(xy[1], '\\.')[[1]][2])
			} else {
				xy[1] <- paste0(xy[1], '.')
				longDecPlaces <- 0
			}
			if (grepl('\\.', xy[2])) {
				latDecPlaces <- nchar(strsplit(xy[2], '\\.')[[1]][2])
			} else {
				xy[2] <- paste0(xy[2], '.')
				latDecPlaces <- 0
			}
			
			maxDec <- max(longDecPlaces, latDecPlaces)
			
			# min coords
			minCoords <- vector('character', length = 2)
			if (maxDec - longDecPlaces > 0) {
				minCoords[1] <- paste0(xy[1], paste(rep('0', maxDec - longDecPlaces), collapse = ''), '0')
			} else {
				minCoords[1] <- paste0(xy[1], '0')
			}
		
			if (maxDec - latDecPlaces > 0) {
				minCoords[2] <- paste0(xy[2], paste(rep('0', maxDec - latDecPlaces), collapse = ''), '0')
			} else {
				minCoords[2] <- paste0(xy[2], '0')
			}
		
			# max coords
			maxCoords <- vector('character', length = 2)
			if (maxDec - longDecPlaces > 0) {
				maxCoords[1] <- paste0(xy[1], paste(rep('0', maxDec - longDecPlaces), collapse = ''), '9')
			} else {
				maxCoords[1] <- paste0(xy[1], '9')
			}
		
			if (maxDec - latDecPlaces > 0) {
				maxCoords[2] <- paste0(xy[2], paste(rep('0', maxDec - latDecPlaces), collapse = ''), '9')
			} else {
				maxCoords[2] <- paste0(xy[2], '9')
			}
			
			# calculate distance
			pts <- SpatialPoints(rbind(as.numeric(minCoords), as.numeric(maxCoords)), proj4string = CRS('+proj=longlat +datumWGS84'))
			
			pts <- sp::spTransform(pts, CRS('+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs'))
			
			return(rgeos::gDistance(pts[1], pts[2]))
		}
	}
	
	scipenVal <- getOption('scipen')
	options('scipen' = 999)
	
	# vector of coordinates
	if (is.vector(coords)) {
		if (!all(is.na(coords))) {
			if (class(coords) != 'numeric' & class(coords) != 'character') {
				stop('coords must be of class numeric or character.')
			}
			if (length(coords) != 2) {
				stop('coords must be of length 2: long, lat.')
			}
			if (class(coords) == 'numeric') {
				coords <- as.character(coords)
			}
			# if either coordinate is invalid, replace with NA to trip that check later
			if (abs(as.numeric(coords[1])) > 180 | abs(as.numeric(coords[2])) > 90) {
				coords[1] <- NA
			}
		}
		res <- calcError(coords)
	}
	
	#table of coordinates
	if (is.data.frame(coords)) {
		coords <- as.matrix(coords)
	}
	if (is.matrix(coords)) {
		if (ncol(coords) != 2) {
			stop('coords must be 2 columns: long and lat.')
		}
		mode(coords) <- 'character'
	
		# to simplify handling, convert any NAs to long 190 and lat 100 for now
		if (any(is.na(coords[,1]))) {
			coords[which(is.na(coords[,1])),1] <- "190"
		}
		if (any(is.na(coords[,2]))) {
			coords[which(is.na(coords[,2])),2] <- "100"
		}
		
		#now all bad records have invalid coordinates, no NA
		# switch back to NA
		coords[which(abs(as.numeric(coords[,1])) > 180), 1] <- NA
		coords[which(abs(as.numeric(coords[,2])) > 90), 2] <- NA
		
		
		
		if (nthreads > 1) {
			cl <- parallel::makePSOCKcluster(nthreads)
			parallel::clusterExport(cl = cl, varlist = c('coords', 'calcError', 'SpatialPoints', 'CRS', 'spTransform'), envir = environment())
			parallel::clusterExport(cl = cl, varlist = 'gDistance', envir = environment(rgeos::gDistance))
			res <- pbapply::pbapply(coords, 1, calcError, cl = cl)
			parallel::stopCluster(cl)
		} else {
			res <- pbapply::pbapply(coords, 1, calcError)
		}
		names(res) <- NULL
	}
	
	options('scipen' = scipenVal)
	
	return(res)
}
	
	
	
	








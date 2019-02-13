# netCDF2csv.R

# NOTES ON USING THIS SCRIPT ----------------------------------------------

# 1. SST data processed by this script can be retrieved from:
# https://podaac.jpl.nasa.gov/ using the python script `subset_dataset.py`.
# 2. Subsetting and the selection of the time steps to be done via the python
# script `subset_dataset.py`.
# 3. This R script requires the already subsetted netCDFs to reside inside a
# directory whose path is specified by `in.dir`, below.
# 4. The .csv files produced will be placed inside of the directory named by
# `csv.dir` (make sure this directory already exists).
# 5. The dates that will be included with the final .csv file will be extracted
# directly from the names of the daily netCDF files; please, therefore, make
# sure to never change them by manually editing them.
# 6. The base name of the new .csv file will be partly based on the name of the
# input netCDF files, with the start and end dates appended at the end. These
# things are hard coded into the script below.
# 7. I am sure I have missed some things, or that some things may break somehow;
# please let me know if this happens and I shall fix it.
# 8. This file may take a while to run (10s of minutes to hours, depending on
# the amount of data processed); please be patient while it does its thing.

# Author: AJ Smit
# Date: 27 April 2018
# e-mail: ajsmit@uwc.ac.za


# CAUTION -----------------------------------------------------------------

# This function will append data to the end of an existing file that had been
# previously produced by this script. This will result in duplicate data. If you
# need to rerun the script for some reason, please make sure to delete the file
# created as the result of the previous run from the `csv.dir`.


# LOAD LIBRARIES ----------------------------------------------------------

library(ncdf4) # library for processing netCDFs
library(plyr) # for `llply()`
library(data.table) # for fast .csv write function, `fwrite()`
library(tidyverse) # misc. data processing conveniences
library(reshape2) # for making a long data format
library(lubridate) # for working with dates
library(stringr) # for working with strings


# MULTICORE SETUP ---------------------------------------------------------

# This file was tested on an AWS m4.10xlarge instance. This instance has 40 cores
# and 160Gb RAM; it reads in 5859 x 1.4Mb netCDF files, combines them into one csv
# file, and saves it to a 19Gb file on disk in 28 seconds!
library(doMC); doMC::registerDoMC(cores = 8) # for multicore spead-ups


# SPECIFY FILE PATHS ------------------------------------------------------

# Setup MUR netCDF data path and csv file output directory (on AWS)
# in.dir <- "/mnt/data/MUR-JPL-L4-GLOB-v4.1"
# csv.dir <- "/mnt/data/MUR-JPL-L4-GLOB-v4.1.csv"

# Setup MUR netCDF data path and csv file output directory (local)
# in.dir <- "/Volumes/Benguela/OceanData/MUR-JPL-L4-GLOB-v4.1/daily"
# csv.dir <- "/Volumes/Benguela/spatial/processed/MUR-JPL-L4-GLOB-v4.1/Benguela_Current/daily"

in.dir <- "/Volumes/Benguela/OceanData/OISSTv2/daily/netCDF"
csv.dir <- "/Volumes/Benguela/spatial/processed/OISSTv2/WBC/daily"

# specify the region as "latmin", "latmax", "lonmin", "lonmax"
source("/Users/ajsmit/Dropbox/R/Ocean_MHW/Changing_nature_of_ocean_heat/setup/regionDefinition.R")
region <- "EAC"
coords <- bbox[, region]
coords <- c(-42.5, -15.0, 145.0, 160.0) # this is the EAC

# PARSE FILE INFO (not used directly) -------------------------------------

# Use to determine the start/end points of the `name.stem` (see code below)
#          1         2         3         4         5         6         7
# 123456789012345678901234567890123456789012345678901234567890123456789012345
# avhrr-only-v2.19810901.nc
# 20091231120000-NCEI-L4_GHRSST-SSTblend-AVHRR_OI-GLOB-v02.0-fv02.0_subset.nc
# 20020601-JPL-L4UHfnd-GLOB-v01-fv04-MUR.nc


# netCDF READ FUNCTION ----------------------------------------------

nc.files <- list.files(path = in.dir, pattern = "*.nc", full.names = TRUE, include.dirs = TRUE)

# nc.files <- nc.files[1:10]

strt.date <- str_sub(basename(nc.files[1]), start = 15, end = 22)
end.date <- str_sub(basename(nc.files[length(nc.files)]), start = 15, end = 22)
nc.init <- nc_open(nc.files[1])
LatIdx <- which(nc.init$dim$lat$vals > coords[1] & nc.init$dim$lat$vals < coords[2])
LonIdx <- which(nc.init$dim$lon$vals > coords[3] & nc.init$dim$lon$vals < coords[4])
nc_close(nc.init)

# nc.file <- nc.files[1]

ncFun <- function(nc.file = nc.files, csv.dir = csv.dir) {
  nc <- nc_open(nc.file)
  name.stem <- substr(basename(nc.file), 1, 13) # local
  date.stamp <- substr(basename(nc.file), 15, 22)
  sst <- round(ncvar_get(nc,
                         varid = "sst",
                         start = c(LonIdx[1], LatIdx[1], 1, 1),
                         count = c(length(LonIdx), length(LatIdx), 1, 1)),
               3)
  dimnames(sst) <- list(lon = nc$dim$lon$vals[LonIdx],
                        lat = nc$dim$lat$vals[LatIdx])
  nc_close(nc)
  sst <-
    as.data.frame(melt(sst, value.name = "temp"), row.names = NULL) %>%
    mutate(t = ymd(date.stamp)) %>%
    na.omit()
  fwrite(sst,
         file = paste0(csv.dir, "/", region, "-", name.stem, "-", strt.date, "-", end.date, ".csv"),
         append = TRUE, col.names = FALSE)
  rm(sst)
}

llply(nc.files, ncFun, csv.dir = csv.dir, .parallel = TRUE)

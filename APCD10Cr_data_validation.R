# Copyright 2021 Bryce Carson
# Author: Bryce Carson <bcars268@mtroyal.ca>
# URL: https://github.com/bryce-carson/APCD10Cr_Carson_2022
#
# dataValidation.R is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# dataValidation.R is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

## if(!require(c(assertr, devtools, fs, rlang, tidyverse))) {
##   install.packages(c("assertr", "tidyverse", "fs", "rlang", "devtools"))
##   library(devtools)
##   if(!require(data.validator)) devtools::install_github("Appsilon/data.validator")
## }

library(assertr)
library(data.validator)
library(foreach)
library(fs)
library(doParallel)
library(rlang)
library(tidyverse)

dataValidationTemplate <- function(dataframe, reportObject, objectNameInReport) {
  if(!is.data.frame(dataframe)) { stop("object to validate is not a dataframe.") }

  validate(data = dataframe,
           name = objectNameInReport,
           description = paste("A test of tibble:", objectNameInReport)) %>%
    validate_cols(description = "All specified columns are present.",
                  predicate = function(dataframe) all(names(dataframe) == c("RUN_id", "replicate", "population", "type", "descrip", "position", "originGen", "originPop", "selCoef", "freq", "outputGen")),
                  cols = c(1:11)) %>%
    validate_cols(description = "position, originGen, originPop, and outputGen are integers.",
                  predicate = is_integer,
                  cols = c(6:8, 11)) %>%
    validate_cols(description = "population, type, and description are characters.",
                  predicate = is_character,
                  cols = c(3:5)) %>%
    validate_cols(description = "replicate is zero.",
                  predicate = in_set(c(0)),
                  cols = 2) %>%
    validate_cols(description = "population is one of 'p1' or 'p2'.",
                  predicate = in_set(c("p1", "p2")),
                  cols = 3) %>%
    validate_cols(description = "type is one of 'm2', 'm3', or 'm4'.",
                  predicate = in_set(c("m2", "m3", "m4")),
                  cols = 4) %>%
    validate_cols(description = "descrip is one of 'CD' or 'AP'.",
                  predicate = in_set(c("CD", "AP")),
                  cols = 5) %>%
    validate_cols(description = "position is between 0 and 1000998.",
                  within_bounds(0, 1000998),
                  cols = 6) %>%
    validate_cols(description = "originGen is between 0 and 349999.",
                  predicate = within_bounds(0, 349999),
                  cols = 7) %>%
    validate_cols(description = "originPop is one of '1' or '2'.",
                  predicate = in_set(c(1,2)),
                  cols = 8) %>%
    validate_cols(description = "RUN_ID, selCoef and freq are doubles.",
                  predicate = is_double,
                  cols = c(1,9,10)) %>%
    validate_cols(description = "freq is between 0 and 1.",
                  predicate = within_bounds(0, 1),
                  cols = 10) %>%
    validate_cols(description = "outputGen is between 100,000 and 350,000.",
                  predicate = within_bounds(100000, 350000),
                  cols = 11) %>%
    validate_if(expr = all(min(outputGen) == 100000, max(outputGen) == 350000),
                description = "outputGen has a minimum of 100,000 and a maximum of 350,000.") %>%
    return()
}

readMutationsOutputFile <- function(filename) {
  read.table(
    file = filename,
    sep = " ",
    comment.char = "R",
    colClasses = c(
      "double",
      "integer",
      "character",
      "character",
      "character",
      "integer",
      "integer",
      "integer",
      "double",
      "double",
      "integer"
    ),
    col.names = c(
      "RUN_id",
      "replicate",
      "population",
      "type",
      "descrip",
      "position",
      "originGen",
      "originPop",
      "selCoef",
      "freq",
      "outputGen"
    )
  ) %>% tibble() %>% return()

}

logValidationErrors <-
  function(data, dataname, logfile) {
    dataValidationResults <-
      dataValidationTemplate(data,
                             data_validation_report(),
                             objectNameInReport = dataname)

    if (!is.null(attr(dataValidationResults, "assertr_error"))) {
      cat(append = TRUE,
          file = logfile,
          dataname,
          sep = "\n")

      attr(dataValidationResults, "assertr_error") %>% print.listof() %>% capture.output(append = TRUE, file = logfile)
      cat(append = TRUE,
          sep = "\n",
          "\n",
          file = logfile)
    }
  }

validationErrorLog <- file_create(path = paste0("~/dataValidation-", format(Sys.time(), "%Y-%m-%d"), ".log"))
filenames <- dir_ls(path = "~/scratch/Output/outputToValidate-2021-11-05/", glob = "*out_Muts.txt")

# Create an array from the NODESLIST environnement variable
nodeslist = unlist(strsplit(Sys.getenv("NODESLIST"), split=" "))

# Create the cluster with the nodes name. One process per count of node name.
# nodeslist = node1 node1 node2 node2, means we are starting 2 processes on node1, likewise on node2.
cl = makeCluster(nodeslist, type = "PSOCK")
registerDoParallel(cl)

foreach(filename = filenames, .errorhandling = "pass", .combine = "list") %dopar% { library(assertr); library(data.validator); library(rlang); library(tidyverse); readMutationsOutputFile(filename) %>% logValidationErrors(dataname = filename, logfile = validationErrorLog) }

# Don't forget to release resources
stopCluster(cl)

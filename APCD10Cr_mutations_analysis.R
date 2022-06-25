# Copyright 2022 Bryce Carson
# Author: Bryce Carson <bcars268@mtroyal.ca>
# URL: https://github.com/bryce-carson/APCD10Cr_Carson_2022
#
# MeeCarsonYeaman2021.R is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# MeeCarsonYeaman2021.R is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

## NOTE:
## STORAGE CLASSES IN SQLite
## integer real text blob null
options(scipen=999,
        readr.show_progress = FALSE)
library(assertr)
library(DBI)
library(RSQLite)
library(tidyverse, quietly = TRUE, warn.conflicts = FALSE)
library(vroom)
library(fs)
library(memoise)
library(rlist)
library(data.table)
library(digest)
library(doParallel)
library(futile.logger)
library(tryCatchLog)
library(rlang)

flog.appender(appender.file("~/RSQLite/MeeCarsonYeaman2021.log"))
flog.threshold(ERROR)

print("Libraries, options, and packages were loaded.")
print("Watch for errors.")

## NOTE: ensure that the working directory is the node-local storage, slurm temporary directory.
if(!getwd() == Sys.getenv(x = "SLURM_TMPDIR")) {
  print(paste0("Working directory set to: ",
               as_fs_path(setwd(Sys.getenv("SLURM_TMPDIR")))))
}
SLURM_TMPDIR <- as_fs_path(system("echo $SLURM_TMPDIR", intern = TRUE))
if(!getwd() == SLURM_TMPDIR) {
  stop("The working directory is _still_ not the SLURM temporary directory. FIXME!")
}

if(file.exists("~/scratch/MeeCarsonYeaman2021.db")) {
  db <- dbConnect(RSQLite::SQLite(),
                  file_copy(path = "~/scratch/MeeCarsonYeaman2021.db",
                            new_path = SLURM_TMPDIR))
} else {
  db <- dbConnect(RSQLite::SQLite(),
                  path(SLURM_TMPDIR, "MeeCarsonYeaman2021.db"))
}

## NOTE: create the SQLite3 database table schemas.
dbSendStatement(db, "CREATE TABLE IF NOT EXISTS heatmaps (heatmapList BLOB, filename TEXT);")
dbSendStatement(db, "CREATE TABLE IF NOT EXISTS sojournDensities (sojournDensityList BLOB, filenameList BLOB);")
dbSendStatement(db, "CREATE TABLE IF NOT EXISTS metadata (intraR REAL, interR REAL, muAP REAL, N INTEGER, m REAL, phi REAL, sCD REAL, muCD REAL, sAP REAL, filenameList BLOB, replicates INTEGER);")

is_not_na <- function(x) { return(is_na(x) == FALSE) }

## FIXME: certain files will produce output with dimensions 1000 x 52, leading
## to the error(s) seen in the log file about the number of items to replace not
## being a multiple of the replacement length.
## I'm not sure what it is about these files yet, but upon inspection with a
## testFile,
## `APCD10Cr_R=1e-07_r=0.000001_muAP=0.0001_N=1000_m=0.001_phi=0.1_sCD=-0.0005_muCD=1e-08_sAP=-0.100.1_Replicate=0_1790362563305_out_Muts.txt`
## there seems to be something about the population two (2) data that causes the
## dimensions to be 52 generations, with the 52nd being named (dim-name) `1`,
## and the column data being `NA`.
createUnderlayMatrix <- function(input, windowSize = 1, population = 1) {
  filteredInput <- input %>%
    filter(c(population == 1 & type == 2) | c(population == 2 & type == 3))

  dfDimensions <- filteredInput %>% dim.data.frame()
  if(dfDimensions[1] == 0) {
    return(matrix(data = 1, nrow = 1000,
                  ncol = seq(100000,
                             input %>%
                             summarize(max(outputGen))
                             %>% as.integer(),
                             5000) %>% length(),
                  dimnames =
                    list(NULL,
                         seq(100000,
                             input %>% summarize(max(outputGen))
                             %>% as.integer(),
                             5000))))
  } else {
    return(
      filteredInput %>%
      calculateCDLoadSimulationOutput(windowSize = 1, population)
    )

  }
}

createOverlayMatrix <- function(input, population) {
  filteredInput <- input %>%
    filter(c(population == population & type == 4))

  dfDimensions <- filteredInput %>% dim.data.frame()
  if(dfDimensions[1] == 0) {
    return(matrix(data = 0,
                  nrow = 10,
                  ncol = seq(100000,
                             input %>%
                             summarize(max(outputGen))
                             %>% as.integer(),
                             5000) %>% length(),
                  dimnames =
                    list(1:10,
                         seq(100000,
                             input %>% summarize(max(outputGen))
                             %>% as.integer(),
                             5000))))
  } else {
    return(filteredInput %>%
           select(population, type, position, selCoef, freq, outputGen, chromosome) %>%
           group_by(outputGen, position, chromosome) %>%
           summarize(szAP = sum(selCoef * freq), .groups = 'keep') %>%
           pivot_wider(names_from = outputGen, values_from = szAP, id_cols = position) %>% ungroup() %>% select(!1) %>% as.matrix())
  }
}

overlayAPMatrix <- function(overlayMatrix, underlayMatrix, windowSize = 1) {
  if(windowSize == 1) {
    underlayMatrix[seq(50, 950, by = 100),] <- overlayMatrix
  }
  ## NOTE: I've been hardcoding windowSize as `1` for so long now, that I
  ## can't remember if windowSize should be `100` or `10` for this second
  ## sequence. If you're using this code and want a larger window size,
  ## you'll need to figure it out. It _is_ either `100` or `10` though.
  else if(windowSize == 100) {
    underlayMatrix[seq(5, 95, by = 10),] <- overlayMatrix
  }
  else {
  	stop("ERROR: The `windowSize` is not `1` or `100`, this is an unhandled case.")
  } 
  return(underlayMatrix)}

calculateCDLoadSimulationOutput <- function(input, windowSize = 1, populationFunInput) {
  ## NOTE: The second argument of left_join() is the data coming through the pipes.
  conditionallyDeleteriousLoad.Tibble <- input %>%
    filter(population == populationFunInput) %>%
    mutate(sf = selCoef*freq) %>%
    filter(sf != 0) %>%
    mutate(sf = sf + 1) %>%
    left_join(x = tibble(gene = 1:1000), by = "gene") %>%
    ## NOTE: cut allows the grouping of genes together for summarizing when the
    ## windowSize greater than one is desired. For now, only a windowSize of
    ## one is used.
    group_by(outputGen, chromosome, genes = cut(gene, breaks = seq(1, 1001, by = windowSize), right = FALSE)) %>%
    summarize(load = (1 - abs(last(cumprod(sf)))), .groups = 'keep') %>%
    arrange(genes) %>%
    ungroup() %>%
    select(outputGen, genes, load) %>%
    pivot_wider(id_cols = genes, names_from = outputGen, values_from = load) %>%
    arrange(genes) %>%
    ## Removing the NA column is enough to fix all of the issues that were encountered.
    mutate(genes = NULL, `NA` = NULL)

  CDloadMatrix <- conditionallyDeleteriousLoad.Tibble %>%
    relocate(sort(dimnames(.)[[2]])) %>%
    as.matrix()

  CDloadMatrix[is.na(CDloadMatrix)] <- 0
  CDloadMatrix + 1
}

## Subset the data for the AP freq table.
subsetAPSimulationOutput <- function(tidySimulationOutput, population) {
  tidySimulationOutput %>%
    filter(c(population == population & type == 4)) %>%
    filter(freq != 0) %>%
    select(population, type, position, selCoef, freq, outputGen, chromosome) %>%
    group_by(outputGen, position, population)
}

## Create the matrices for the mean population frequency of AP alleles at every locus.
populationAPFrequencyMatrix <- function(subsetAP, population) {
  filter(subsetAP, population == population) %>%
    group_by(outputGen, position) %>%
    summarize(count = n(), spread = sd(freq), maximum = max(freq), minimum = min(freq), mean = mean(freq), szAP = sum(selCoef * freq), .groups = 'keep') %>%
    pivot_wider(names_from = outputGen, values_from = szAP, id_cols = position) %>%  select(!1) %>% as.matrix()
}

doWork <- function(input) {
  underlayMatrices <- list(length = 2)
  overlayMatrices <- list(length = 2)
  heatmaps <- list(length = 2)
  for(i in c(1,2)) {
    underlayMatrices[[i]] <- input %>% createUnderlayMatrix(population = i)
    overlayMatrices[[i]] <- input %>% createOverlayMatrix(population = i)
    heatmaps[[i]] <- overlayAPMatrix(overlayMatrices[[i]],
                                     underlayMatrices[[i]])}
  return(heatmaps)}


## NOTE: INSERT INTO metadata
metadata <- function() {
  ## NOTE: it is impossible to invalidate earlier results and over-write
  ## them, as the random seeds used by SLiM should always be unique
  ## especially when paired with parameters in the filename. This
  ## prevents re-runs of a parameter set from being compared with older
  ## data by the birth-time of the file; younger and older data must be
  ## curated manually, where if older data is not wanted it should be
  ## pruned from the database manually.
  ## This also protects younger data being appended to the database by
  ## avoiding conflict, where the parameters and the seed are enough to
  ## uniquify a given file, and the birth time is not necessary metadata
  ## to associate with the file and the results created from it and
  ## stored in other tables.
  ## It is possible that a given seed could be re-run, but this is not
  ## done in practice.
  ## To know if a file is already accounted in the metadata table, the
  ## seed should be queried. If the seed is present, then we will not
  ## append it to the metadata table and that is all.

  filenames <- dir_ls(path = getwd(), glob = "*out_Muts.txt", recurse = FALSE)

  RSQLite::dbWriteTable(db,
                        "metadata",
                        tibble(path = basename(filenames)) %>%
                        separate(remove = FALSE,
                                 col = path,
                                 sep = "_",
                                 into = c(NA,    "intraR", "interR", "muAP", "N", "m", "phi",
                                          "sCD", "muCD",   "sAP",    NA,     NA,  NA,  NA)) %>%
                        modify_at(.at = c("intraR", "interR", "muAP",
                                          "N",      "m",      "phi",
                                          "sCD",    "muCD",   "sAP"),
                                  .f = str_extract,
                                  pattern = "[^[[:alpha:]]=](.*)$") %>%
                        mutate(sAP = as.numeric(
                                 str_sub(sAP,
                                         2,
                                         floor((str_length(sAP) - 1) / 2) + 1))) %>%
                        group_by(intraR, interR, muAP,
                                 N,      m,      phi,
                                 sCD,    muCD,   sAP) %>%
                        summarize(filenameList = list(path),
                                  replicates = n(),
                                  .groups = 'keep') %>%
                        select(everything(), filenameList, replicates) %>%
                        type_convert(col_types="dddiddddcli") %>%
                        mutate(filenameList = list(serialize(filenameList, NULL))),
                        append = TRUE)
  return(filenames)}

readFile <- function(fileName) {
  ## RUN_id replicate population type descrip position originGen originPop selCoef freq outputGen
  ## int int char char char int int int float float int
  ## 1656581627904 0 p1 m2 CD 1176 98128 2 -0.0017236 0.04515 100000
  ## 1656581627904 0 p1 m2 CD 2302 99997 1 -0.010445 5e-05 100000
  ## 1656581627904 0 p1 m2 CD 3895 99986 1 -0.0440263 0.00015 100000
  ## 1656581627904 0 p1 m2 CD 4635 99923 1 -0.00307199 0.00085 100000

  ## File Processing
  ## NOTE: fread, by `grep` and its own usage, will read the given file in the
  ## currect directory if not an absolute path. This is helpful since `basename`
  ## is applied to the paths gotten from `dir_ls`.
  current_file <-
    fread(colClasses=list(character=c(3,4,5), integer=c(6,7,8,11), double=c(9,10)), drop=c(1,2), col.names = c("population", "type", "descrip", "position", "originGen", "originPop", "selCoef", "freq", "outputGen"), cmd = paste0("grep -v -e\"^R.*\" ", fileName)) %>%
    map_at(str_extract, pattern = "[[:digit:]]", .at = vars(population, type)) %>%
    as_tibble() %>%
    mutate_at(vars(population, type), as.double) %>%
    arrange(position)

  ## NOTE: simple data cleaning.
  if(hasName(current_file, "gene") == F) {
    current_file <- mutate(current_file, gene = floor((position/1001)) + 1)}
  if(hasName(current_file, "chromosome") == F) {
    current_file <- mutate(current_file, chromosome = ceiling(gene/100))}

  ## End of Function
  return(current_file)}

doSojournWork <- function(filenameVector) {

  if(all(is.vector(filenameVector) == TRUE, length(filenameVector) == 10) == FALSE) {
    print("filenameVector is not a vector of length ten. Major error.")
    stop()
  } else {
    map_dfr(.f = calculateSojournDensity,
            .x = map(
              .f = readFile,
              .x = filenameVector)) %>%
      ungroup() %>%
      select(position.x,
             sojournDensity,
             sojournTime,
             meanFreq
             ) %>%
      mutate(position = position.x,
             density = sojournDensity,
             time = sojournTime,
             meanFrequency = meanFreq
             ) %>%
      group_by(position) %>%
      summarize(meanDensity   = mean(density),
                minDensity    = min(density),
                maxDensity    = max(density),
                meanTime      = mean(time),
                minTime       = min(time),
                maxTime       = max(time),
                meanFrequency = mean(meanFrequency),
                minFrequency  = min(meanFrequency),
                maxFrequency  = max(meanFrequency)) %>%
      return()
  }
}

calculateSojournDensity <- function(inputData) {
  ## TODO: the main function needs to be advised that the Sojourn Density plot should be handled differently for such a file as the test below identifies.
  ## if(max(current_file$type) != 4) {
  ##   print(paste0("Output file only has conditionally deleterious mutations. This file is a muAP=0 simulation."))}
  mutations <- inputData %>% mutate_at(.vars = vars(population, type), .fun = str_extract, "[[:digit:]]") %>%
    mutate_at(.vars = vars(population, type), .fun = as.numeric) %>%
    group_by(mutationIDInferred = factor(population * type * position * originGen * originPop)) %>%
    arrange(position, outputGen, .by_group = TRUE)

  mutationsSojournTime <- mutations %>% filter(freq == 0) %>%
    summarize(sojournTime = outputGen - originGen, position = position, .groups = 'keep') %>%
    arrange(mutationIDInferred)
  mutationsMeanFreq <- mutations %>% summarize(meanFreq = mean(freq), position = position, .groups = 'keep')

  return(left_join(mutationsSojournTime, mutationsMeanFreq, by = "mutationIDInferred") %>%
         mutate(sojournDensity = meanFreq / sojournTime))}

main <- function() {
  ## NOTE: Create the metadata table in the SQLite database.
  filenames <- metadata()

  ## NOTE: Make `filenameList` not a list column of lists, but a list column of
  ## character vectors.
  ## EXAMPLE
  ## > list(c("one", "two", "three"), c("four", "five")) %>% tibble()
  ## # A tibble: 2 × 1
  ##   .
  ##   <list>
  ## 1 <chr [3]>
  ## 2 <chr [2]>
  ## NOTE: Verify and assert that it must be so. It seems that if the assertions fail, an
  ## error is encountered in the assertion function itself, and the proper
  ## behaviour of an assertion violation is not observed. FIXME.
  filenameVectorsListToProcess <-
    RSQLite::dbGetQuery(db, "SELECT filenameList FROM metadata EXCEPT SELECT filenameList FROM sojournDensities WHERE sojournDensityList IS NOT NULL") %>%
    tibble() %>%
    mutate(filenameList = map(filenameList, unserialize)) %>%
    unnest(filenameList) %>%
    chain_start() %>%
    verify(is.list(filenameList) == TRUE) %>%
    assert(is.character, filenameList) %>%
    pull(filenameList) %>%
    set_tidy_names(quiet = TRUE,
                   syntactic = TRUE) %>%
    verify(is_list(.) == TRUE) %>%
    chain_end()

  ## NOTE: SOJOURN DENSITIES
  sojournDensitiesTable <- foreach(filenameVector = filenameVectorsListToProcess, .verbose = TRUE, .combine = 'bind_rows') %dopar% {
    ## NOTE: the default value to write to the database.
    here <- rlang::env()
    assign(
      x = "sojournDensity",
      value = tibble(
        sojournDensityList = NULL,
        filenameList = list(serialize(list(filenameVector %>%
          set_tidy_names(quiet = TRUE, syntactic = TRUE) %>%
          verify(is_character(.) == TRUE)),
        connection = NULL
        ))
      ),
      envir = here
    )

    tryCatchLog(
      expr = assign(
        x = "sojournDensity",
        value = tibble(
          sojournDensityList = list(serialize(doSojournWork(filenameVector), connection = NULL)),
          filenameList = list(serialize(list(filenameVector), connection = NULL))
        ),
        envir = here
      ),
      error = function(e) print(paste("An error occured while doing sojourn density work for (digest):", digest(filenameVector), "and the default value will be written to the database.")),
      write.error.dump.file = TRUE,
      write.error.dump.folder = path("~/scratch/tryCatchLog-dumps")
    )

    rlang::env_get(env = here,
                   nm = "sojournDensity")
  }

    ## Append the table to the database. The table is of the form of a tibble or
    ## data.frame where the records to be in the database are individual results
    ## from each worker, with the result being described in the table definition
    ## for the sojournDensities table of the database earlier in this script.
    RSQLite::dbWriteTable(db, "sojournDensities", sojournDensitiesTable, append = TRUE)

  ## NOTE: HEATMAPS
heatmapsTable <- filenameVectorsListToProcess %>%
  unlist() %>% 
  set_tidy_names(quiet = TRUE,
                 syntactic = TRUE) %>%
  verify(is.character(.)) %>%
  foreach(file = .,
          .verbose = TRUE,
          .combine = 'bind_rows') %dopar% {
    ## NOTE: the default value to write to the database.
    here <- rlang::env()
    assign(x = "individualHeatmap",
           value = tibble(heatmapList = NULL, filename = file),
           envir = here)

    tryCatchLog(expr = assign(x = "individualHeatmap",
                              value = tibble(heatmapList = list(serialize(doWork(readFile(file)), connection = NULL)),
                                             filename = file),
                              envir = here),
                error = function(e) print(paste("An error occured while doing heatmap work for", file, "and the default value will be written to the database.")),
                write.error.dump.file = TRUE,
                write.error.dump.folder = path("~/scratch/tryCatchLog-dumps"))

    rlang::env_get(env = here,
                   nm = "individualHeatmap")
  }
    ## Append the table to the database. The table is of the form of a tibble or
    ## data.frame where the records to be in the database are individual results
    ## from each worker, with the result being described in the table definition
    ## for the heatmaps table of the database earlier in this script.
    RSQLite::dbWriteTable(db, "heatmaps", heatmapsTable, append = TRUE)

}

ncores = Sys.getenv("SLURM_CPUS_PER_TASK")
registerDoParallel(cores=ncores)
print(paste0("An R parallel 'cluster' has been registered with ", ncores, " cores."))
getDoParWorkers()

## Do analytical work!
format(c("Calling main() at:", date()))
main()
format(c("Execution of main() completed:", date()))

## Disconnect from the database when the work is done.
dbDisconnect(db)

## NOTE: move the database from the node-local storage to the sratch directory with a timestamped filename.
file_copy(path = path(SLURM_TMPDIR, "MeeCarsonYeaman2021.db"),
          new_path = path("~/scratch/", paste0("MeeCarsonYeaman2021-", format(Sys.time(), "%m-%dT%H:%M"), ".db")),
          overwrite = FALSE)

# Copyright 2021 Bryce Carson
# Author: Bryce Carson <bcars268@mtroyal.ca>
# URL: https://github.com/bryce-carson/APCD10Cr_Carson_2022
#
# APCD10Cr_continue_sims_20211005_part_one.R is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# APCD10Cr_continue_sims_20211005_part_one.R is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

options("scipen" = 20)
library(tidyverse)
library(fs)
library(data.table)
library(stringr)

## NOTE: `filesToComplete` is not an object in the R environment or workspace
## that this script runs within. The object was created from SLURM log files
## that indicated a number of simulations experienced input–output errors during
## the writing of output files to disk.
##
## The object, as the name implies, contained a list of filenames and other
## metadata about those files which experienced the errors. The
## `filesToComplete` object was lost during production after it was used; a list
## of which files experienced input–output errors was not retained either,
## however, this part of the production workflow follows an algorithm that is
## reliable enough that the output could be repaired. For a full discussion of
## the situation and its remedy, see the README for this repository.

filenamesAndParameters <- filesToComplete %>% as_tibble() %>%
    separate(sep = "_", col = value, remove = FALSE,
             into = c(NA, "intraR", "interR", "muAP", "N", "m", "phi",
                      "sCD", "muCD", "sAP", NA, "RUN_id", NA, NA)) %>%
    map_at(.at = c("intraR", "interR", "muAP", "N", "m", "phi",
                   "sCD", "muCD", "sAP"),
           str_extract, pattern = "[^[[:alpha:]]=](.*)$") %>%
  ## NOTE: The `pattern` argument (`"00."`) is used to split up the older sAP
  ## parameter key and its meaningful value. See the full discussion of sAP and
  ## sAPValue in the `README.md` file.
    map_at("sAP", str_split, pattern = "00.") %>%
    map_at("sAP", map, first) %>%
    map_at("sAP", as_vector) %>%
    as_tibble() %>%
    mutate(outputMutationsFilename = map_chr(value, .f = ~ system(intern = TRUE,
                                                                  paste("find",
                                                                        "~/scratch/Output/",
                                                                        "-not -wholename '*corrupt*'",
                                                                        "-name",
                                                                        .))),
           outputIndFitnessFilename = map_chr(value, .f = ~ system(intern = TRUE,
                                                                   paste("find",
                                                                         "~/scratch/Output/",
                                                                         "-not -wholename '*corrupt*'",
                                                                         "-name",
                                                                         str_replace(.,
                                                                                     pattern = "out_Muts.txt",
                                                                                     replacement = "out_indFitness.txt")))),
           value = NULL,
           saveStateFilename = map(outputMutationsFilename, .f = ~ system(intern = TRUE,
                                                                          paste("find",
                                                                                "~/scratch/Output/",
                                                                                "-not -wholename '*corrupt*'",
                                                                                "-name",
                                                                                str_replace(basename(.),
                                                                                            replacement = "outputFull_Generation=*.txt",
                                                                                            pattern = "out_Muts.txt"))) %>%
                                                                sort() %>%
                                                                last(n = 2)),
           generationToDelete = map_dbl(.x = saveStateFilename, .f = ~ last(.) %>% str_extract(pattern = "[123][[:digit:]][0,5][0]{3}") %>%
                                                                    as.numeric()))

arguments <- filenamesAndParameters %>% str_glue_data(.sep = "\n",
                                                      "-d R={intraR}",
                                                      "-d r={interR}",
                                                      "-d N={N}",
                                                      "-d m={m}",
                                                      "-d phi={phi}",
                                                      "-d sCD={sCD}",
                                                      "-d sAPValue={sAP}",
                                                      "-d muAP={muAP}",
                                                      "-d muCD={muCD}",
                                                      "-d REP=0",
                                                      "-s {RUN_id}",
                                                      "-d saveStateFilename=\'\"{map_chr(.x = saveStateFilename, 1)}\"\'",
                                                      "-d saveStateDirectory=\'\"{map_chr(.x = saveStateFilename, 1) %>% dirname()}\"\'",
                                                      "-d outputMutationsFile=\'\"{outputMutationsFilename}\"\'",
                                                      "-d outputIndFitnessFile=\'\"{outputIndFitnessFilename}\"\'",
                                                      "-d outputEveryNGenerations=5000")

## Write out the parameter files
parameterFilePaths <- map(seq(arguments), .f = ~ file_temp(pattern = paste0("argumentNumber", .), ext = ".txt", tmp_dir = fs_path("/home/bcars268/scratch/")))
pmap(list(args = arguments, files = parameterFilePaths), function(args, files) writeLines(text = toString(args), con = files))
commandLines <- map_chr(parameterFilePaths, .f = ~ paste0("/home/bcars268/bin/slim -m -l `xargs -a ", ., "` /home/bcars268/2021-09-24/APCD10Cr2021-10-03.slim"))

## NOTE: be cautious and do not run the real code here until the test below has been confirmed.
## NOTE: create a backup, just in case.
filesToBackup <- c(filenamesAndParameters$outputMutationsFilename, filenamesAndParameters$outputIndFitnessFilename, map_chr(filenamesAndParameters$saveStateFilename, 1), map_chr(filenamesAndParameters$saveStateFilename, 2)) %>% unlist() %>% as_fs_path()
dir_create("~/scratch/backupSimulations-2021-10-04/")
file_copy(path = filesToBackup, new_path = path("~/scratch/backupSimulations-2021-10-04/", basename(filesToBackup)))

sensitiveCommands <- transmute(filenamesAndParameters,
                               deleteLinesMutationsCommand = paste0("sed -i '/", generationToDelete, "$/d' ", outputMutationsFilename),
                               deleteLinesIndividualsCommand = paste0("sed -i '/", generationToDelete, "$/d' ", outputIndFitnessFilename),
                               deleteSaveStateCommand = map_chr(.x = saveStateFilename, 2) %>% path()
                               )

map(sensitiveCommands$deleteLinesMutationsCommand, .f = ~ system(command = .))
map(sensitiveCommands$deleteLinesIndividualsCommand, .f = ~ system(command = .))
file_delete(sensitiveCommands$deleteSaveStateCommand)

## NOTE: perform the last works before handing off to GNU parallel.
commandLinesFile <- file("~/commandLinesFile-continueSimulations-2021-10-12.txt")
writeLines(text = commandLines, con = commandLinesFile)
close(commandLinesFile)
save(filenamesAndParameters, "~/filenamesAndParameters-2021-10-12.RData")

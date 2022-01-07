library(fs)
library(tidyverse)
load("~/filenamesAndParameters-2021-10-12.RData")
dir_create("~/scratch/Output/completeOutput")
completedOutputToMove <- c(
    filenamesAndParameters$outputMutationsFilename,
    filenamesAndParameters$outputIndFitnessFilename
) %>%
    as_fs_path()
file_move(path = completedOutputToMove,
          new_path = path("~/scratch/Output/completeOutput", basename(completedOutputToMove)))

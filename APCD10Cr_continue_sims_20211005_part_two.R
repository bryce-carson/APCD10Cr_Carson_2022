# Copyright 2021 Bryce Carson
# Author: Bryce Carson <bcars268@mtroyal.ca>
# URL: https://github.com/bryce-carson/APCD10Cr_Carson_2022
#
# APCD10Cr_continue_sims_20211005_part_two.R is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# APCD10Cr_continue_sims_20211005_part_two.R is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

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

#!/bin/bash
#SBATCH --time=00-01:30:00
#SBATCH --mem=0
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --job-name="SQLite Database Generation"
#SBATCH --mail-type=TIME_LIMIT_90,ARRAY_TASKS,FAIL,END
#SBATCH --mail-user=recipient@example.org

# Prepare the working files for the parallel workers.
find ~/scratch/Output/validatedOutput-2021-11-05 -type f -name "*out_Muts.txt" -exec cp -t ${SLURM_TMPDIR} {} +
cd ${SLURM_TMPDIR}

# Load and exeute R upon the dataset.
module load r/4.1.0
R CMD BATCH --vanilla /home/bcars268/RSQLite/MeeCarsonYeaman2021.R  /home/bcars268/RSQLite/MeeCarsonYeaman2021.Rout

# Copyright 2021 Bryce Carson
# Author: Bryce Carson <bcars268@mtroyal.ca>
# URL: https://github.com/bryce-carson/APCD10Cr_Carson_2022
#
# MeeCarsonYeaman2021.sh is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# MeeCarsonYeaman2021.sh is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

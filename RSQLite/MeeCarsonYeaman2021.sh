#!/bin/bash
#SBATCH --time=00-01:30:00
#SBATCH --mem=0
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --job-name="MeeCarsonYeaman2021"
#SBATCH --mail-type=TIME_LIMIT_90,ARRAY_TASKS,FAIL,END
#SBATCH --mail-user=bcars268@mtroyal.ca

# Prepare the working files for the parallel workers.
find ~/scratch/Output/validatedOutput-2021-11-05 -type f -name "*out_Muts.txt" -exec cp -t ${SLURM_TMPDIR} {} +
cd ${SLURM_TMPDIR}

# Load and exeute R upon the dataset.
module load r/4.1.0
R CMD BATCH --vanilla /home/bcars268/RSQLite/MeeCarsonYeaman2021.R  /home/bcars268/RSQLite/MeeCarsonYeaman2021.Rout


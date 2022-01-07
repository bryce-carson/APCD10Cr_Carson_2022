#!/bin/bash
#SBATCH --job-name="continueParallel-2021-10-05"
#SBATCH --mail-type=TIME_LIMIT_90,ARRAY_TASKS,FAIL
#SBATCH --mail-user=bcars268@mtroyal.ca
#SBATCH --account=def-jonmee    # replace this with your supervisors account
#SBATCH --ntasks-per-node=2     # add this line to make sure that SLURM uses multiple nodes
#SBATCH --ntasks=26             # number of processes
#SBATCH --mem-per-cpu=9G        # memory; default unit is megabytes
#SBATCH --time=03-12:00:00      # time (DD-HH:MM:SS)

# NOTE: R needs to be loaded.
module load gcc/9.3.0 r/4.1.0

# NOTE: Generate the command-lines that GNU parallel will use to launch
# processes, as well as run `sed` on the *out_Muts.txt and *out_indFitness.txt
# files, and deleting the very last saveState file, and backing up all three files.
R CMD BATCH --vanilla ~/continueSimulations/continueSimulations-2021-10-05-partOne.R  ~/continueSimulations/continueSimulations-2021-10-05-partOne.Rout

# NOTE: If GNU parallel completes successfully, ie all of the processes it
# spawns exist successfully, the second R process in this job will move the
# completed output to '~/scratch/Output/completeOutput/'.
scontrol show hostname > ~/continueSimulations/node_list_${SLURM_JOB_ID}
parallel --jobs ${SLURM_NTASKS_PER_NODE} --sshloginfile ~/continueSimulations/node_list_${SLURM_JOB_ID} --workdir ${PWD} --joblog ~/continueSimulations/continueGNUParallel.log < ~/continueSimulations/commandLinesFile-continueSimulations-2021-10-12.txt && R CMD BATCH --vanilla ~/continueSimulations/continueSimulations-2021-10-05-partTwo.R ~/continueSimulations/continueSimulations-2021-10-05-partTwo.Rout

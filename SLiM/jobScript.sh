#!/bin/bash
#SBATCH --array=1-6
#SBATCH --time=06-12:00:00
#SBATCH --mem-per-cpu=9G
#SBATCH --ntasks=1
#SBATCH --no-kill
#SBATCH --job-name="nTenThousand-MissingParams-2021-12-22.txt"
#SBATCH --mail-type=TIME_LIMIT_90,ARRAY_TASKS,FAIL
#SBATCH --mail-user=bcars268@mtroyal.ca
slim -m -l `xargs -a params_${SLURM_ARRAY_TASK_ID}` APCD10Cr-2021-12-22.slim
# To have replicates, this job should merely be submitted ten times for ease.

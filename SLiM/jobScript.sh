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

# Copyright 2021 Bryce Carson
# Author: Bryce Carson <bcars268@mtroyal.ca>
# URL: https://github.com/bryce-carson/Carson2022
#
# jobScript.sh is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# jobScript.sh is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

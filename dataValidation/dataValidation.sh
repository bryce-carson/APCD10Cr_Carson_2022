#!/bin/bash
#SBATCH --ntasks-per-node=4     # add this line to make sure that slurm uses multiple nodes
#SBATCH --ntasks=120            # number of processes
#SBATCH --mem-per-cpu=512M      # memory; default unit is megabytes
#SBATCH --time=02:30:00         # time (HH:MM:SS)

module load gcc/9.3.0 r/4.1.0

# Export the nodes names. 
# If all processes are allocated on the same node, NODESLIST contains : node1 node1 node1 node1
# Cut the domain name and keep only the node name
export NODESLIST=$(echo $(srun hostname | cut -f 1 -d '.'))
echo "Beginning data validation at: $(date -Im)."
R CMD BATCH ~/dataValidation/dataValidation.R ~/dataValidation/dataValidation.Rout
echo "Finished data validation at: $(date -Im)."

# Copyright 2021 Bryce Carson
# Author: Bryce Carson <bcars268@mtroyal.ca>
# URL: https://github.com/bryce-carson/Carson2022
#
# dataValidation.sh is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# dataValidation.sh is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

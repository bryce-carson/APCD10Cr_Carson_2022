# Copyright 2021 Bryce Carson
# Author: Bryce Carson <bcars268@mtroyal.ca>
# URL: https://github.com/bryce-carson/APCD10Cr_Carson_2022
#
# APCD10Cr_model_generate_parameter_files.R is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# APCD10Cr_model_generate_parameter_files.R is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

library(tidyverse)
library(glue)

parameters <- read_csv("parameters.csv") %>% as_tibble() %>% mutate(outputEveryNGenerations=5000)

glue_data(
  .x = parameters,
  .sep = "\n",
  "-d R={intraR}", # intra-gene recombination rate (recombination rate between base pairs within genes)
  "-d r={interR}", # inter-gene recombination rate (recombination rate between genes)
  "-d muAP={muAP}", # mutation rate of alleles with antagonistic pleiotropy
  "-d muCD={muCD}", # mutation rate of alleles with conditional neutrality
  "-d N={N}", # Population size
  "-d m={m}", # migration rate

  ## Selection
  "-d phi={phi}", ## 1 - phi*(((theta1 - zAP)/2*theta1)^gamma);
                  ## zAP = individual.sumOfMutationsOfType(m4); # sum of the effect size of AP alleles
                  ## defineConstant("gamma", 2); //Curvature
                  ## defineConstant("theta1", -1.0); //Phenotypic optimum one
                  ## defineConstant("theta2", 1.0); //Phenotypic optimum two

  "-d sCD={sCD}", # selection coefficient of alleles with conditional neutrality
  "-d sAPValue={sAP}", # selection coefficient of alleles with antagonistic pleiotropy
  "-d outputEveryNGenerations={outputEveryNGenerations}" # frequency of simulation output
) %>%
  str_split(pattern = "\n") %>%
  map2(.x = .,
       .y = paste0("params_", 1:238),
       ~ write_lines(x = .x, file = .y))

if(!system("command -v sbatch")) {
  system2(
    command = "sbatch",
    input = c(
      "#!/bin/bash",
      "#SBATCH --array=1-238",
      "#SBATCH --time=06-12:00:00",
      "#SBATCH --mem-per-cpu=9G",
      "#SBATCH --ntasks=1",
      "#SBATCH --no-kill",
      '#SBATCH --job-name="APCD10Cr_EXAMPLE"',
      "#SBATCH --mail-type=TIME_LIMIT_90,ARRAY_TASKS,FAIL",
      "#SBATCH --mail-user=user@example.com",
      "slim -m -l `xargs -a params_${SLURM_ARRAY_TASK_ID}` APCD10Cr-2021-12-22.slim",
      "# To have replicates, this job should merely be submitted ten times for ease."
    )
  )
} else { stop("sbatch was not found on the path.") }

## system2("rm", args = paste0("params_", 1:238))

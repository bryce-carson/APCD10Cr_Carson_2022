<!-- # TODO: -->
<!-- 1. Identify all cases of absolute file paths and environment variable dependent paths. -->
<!-- 2. Document identified paths which cannot be handled defensively. -->
<!-- 3. & more! -->

<!-- # Directories -->
<!-- ``` -->
<!-- $HOME/scratch/Output -->
<!-- $HOME/scratch/Output/n{One,Ten}Thousand{OutputData,saveStates} -->
<!-- ``` -->

<div align="center">
<h2>APCD10Cr</h2>
<h3>Antagonistic Pleiotropy & Conditionally Deleterious Mutations</h3>
<h3>in Local Adaptation with Functional Genetic Redundancy</h3>
<h5>Bryce Carson</h5>
<h5>2022-04-30</h5>
</div>

# About this repository
<a href="https://www.github.com/Bryce-Carson/APCD10Cr_Carson_2022">The <code>APCD10Cr_Carson_2022</code> repository</a> hosts the source code and the documentation of that code used in the production of data for a paper in preparation titled: *The accumulation of conditionally deleterious mutational load is augmented in regions linked to adaptive loci*.

During the course of data production and the supporting programming in BASH, R, and SLiM's domain-specific language Eidos the project was referred to internally as APCD10Cr. APCD10Cr is an abbreviation for: Antagonistic Pleiotropy & Conditionally Deleterious Mutations, in Local Adaptation with Functional Genetic Redundancy.

## Publication and contribution details
At the time of publication of the data to the Federated Research Data Repository (hereafter FRDR; <a href="https://www.frdr-dfdr.ca/">www.frdr-dfdr.ca</a>), the manuscript by Mee, Carson, & Yeaman describing this research is not published and is in preparation; a preprint manuscript will be published to BioRXiv when ready. The researchers involved in this study are listed in the table below.

The title for the BioRXiv manuscript in preparation is: Mee, J.A., Carson, C., & Yeaman, S.M. (2022) *The accumulation of conditionally deleterious mutational load is augmented in regions linked to adaptive loci*.

<table>
  <caption><b>Table 1:</b> The owner of this repository, Bryce Carson, is the sole author of the source code for the source files in this repository, and the sole author of the dataset linking to this repository from the FRDR [1]. Data published in the FRDR was created as a research output during the method of study for a forthcoming publication by the data author and others. When the manuscript is in a pre-print archive or officially published this repository will be updated to reflect that. If you have questions related to the data published in the FRDR or this GitHub repository contact Bryce Carson (<a href="mailto:bcars268@mtroyal.ca">bcars268@mtroyal.ca</a>).</caption>
  <tr><th>Contributor</th><th>ORCID iD</th><th>Contributor role and details</th><th>Affiliation</th></tr>
  
  <tr class="table-row">
    <td class="table-column-contributors-names">Bryce Carson</td>
    <td class="table-column-contributors-orcid-id"><a href="https://orcid.org/0000-0002-1362-2998">0000-0002-1362-2998</a></td>
    <td class="table-column-contributors-affiliations">Sole author of data and source code for multi-chromosome simulations (see details)</td>
    <td class="table-column-contributors-affiliations">Mount Royal University (Research Assistant)</td>
  </tr>

  <tr class="table-row">
    <td class="table-column-contributors-names">Jon Mee</td>
    <td class="table-column-contributors-orcid-id"><a href="https://orcid.org/0000-0003-0688-1390">0000-0003-0688-1390</a></td>
    <td class="table-column-contributors-contribution">Principle investigator</td>
    <td class="table-column-contributors-affiliation">Mount Royal University (Associate Professor)</td>
  </tr>

  <tr class="table-row">
    <td class="table-column-contributors-names">Sam Yeaman</td>
    <td class="table-column-contributors-orcid-id"><a href="https://orcid.org/0000-0002-1706-8699">0000-0002-1706-8699</a></td>
    <td class="table-column-contributors-contribution">Principle investigator</td>
    <td class="table-column-contributors-affiliation">University of Calgary (Associate Professor)</td>
  </tr>
</table>

# Contents summary
A workflow manager was not used during data production, so several scripts were written to produce, validate, and aggregate the data. Data production, validation, and aggregation are described individually in separate sections of this README.

Summarizing the whole workflow:

1. Population genetic data is produced using SLiM 3 [2] with
   `APCD10Cr_model_20211222.slim` as the input model, and submitted to the scheduler
   using `APCD10Cr_model_20211222_job_script.sh` which depends on temporary
   files created by `APCD10Cr_model_generate_parameter_files.sh` and
   `APCD10Cr_model_20211218_parameters.tsv`. (See the ["Data
   production"](#data-production) section to use an improved workflow, written
   specially for reproduction purposes.)

2. The produced data is validated with `APCD10Cr_data_validation.R`, scheduled
   with `APCD10Cr_data_validation_job_script.sh`, and uses an R packages
   lock-file `APCD10Cr_data_validation_renv.lock`.

3. Aggregation of the data is performed with `APCD10Cr_mutations_analysis.R`,
   scheduled with `APCD10Cr_mutations_analysis_job_script.sh`, and uses the R
   packages lock-file `APCD10Cr_mutations_analysis_renv.lock`.

4. Visualization of aggregated data with a Shiny application
   (`APCD10Cr_mutations_app.R`), with the data contained in
   `APCD10Cr_mutations_app_db_created_20211228.db`, and an R packages lock-file
   `APCD10Cr_mutations_app_renv.lock`.

| **⚠ Warning** |
|:--------------|
| Use the R function `renv::load`, from the `renv` package, to load the lock-file for each R workflow (the name of the lock file is named for the workflow; e.g. continue_sims, data_validation, and so on). Lockfiles specify the packages (and versions and dependencies thereof) used in the project regardless of machine or architecture. See the vignette for renv and the talk at rstudio::conf 2020 for more information on and an introduction to renv. |

| **⚠ Warning** |
|:--------------|
| Paths and filenames were refactored to assist in reproduction. Where relevant, the variables or file-names referred to in source files have been documented. During reproduction, editing the files may still be necessary to ensure that files are found in the expected places; it is recommended to study the source files before attempting reproduction following the instructions in this repository. |

## Software used
- GNU R v3.4 (though v3.3 was used at other times as well)
  - All of the R libraries used are documented in the several `.lock` files in the repository. The lock files are named for the part of the workflow they correspond to.
- SLiM version 3.3.2, built May 4 2020 19:43:23 (built from sources on the cluster)

# Data production
This section documents the first use–case, new simulations.

The SLiM model script is not particularly complex, but the supporting work files may be challenging. There are three use cases of the script: new simulations; continuing existing simulations; increasing the output frequency for existing simulations.

On a command-line, using SLiM v3.3.2, call `slim` with the `--define` command–line argument for each parameter required by the simulation.

The command-line argument `--define` or `-d` sets the parameters of the simulation (such as `R=1e-8` to set the recombination rate). The command–line arguments for the model are generated from a BASH script which depends on a SLURM environment variable, `$SLURM_ARRAY_JOB_ID`. The parameter file is read by `xargs` and is used to define the simulation parameters. Parameters are generated from a tsv file. See the `APCD10Cr_model_20211218_parameters.tsv` file for an example.


| **⚠ Warning** |
|:--------------|
| The recommended usage when reproducing data is to select a row of parameters from the `parameters.csv` file in `R`, then use that data with the provided ["Reproduction R script"](#reproduction-r-script) to generate the command-line. |


1. Run the "Reproduction R Script" to generate 238 `params_*` files, which are read by `xargs`.
2. Submit `APCD10Cr_model_20211222_job_script.sh` to a cluster managed by SLURM. If replicates are desired, submit the job multiple times. The job script uses an array to launch subjobs. See [Job arrays - Digital Research Alliance of Canada Wiki](https://docs.alliancecan.ca/wiki/Job_arrays) for more information.

<table>
<thead>
  <tr>
    <th align="left"><bold>⚠ Warning</bold></th>
  </tr>
</thead>
<tbody>
  <tr>
    <td><p>The SLiM model outputs the entire model state for save files in the same event block as the custom output is generated. This was written mostly in 2019, and as such was not changed. The implication of output being at the beginning of a generation or the end was discussed and deemed not an important distinction when the frequency of output is every five thousand generations.</p> <p>This creates the following warning, but can be (and was) ignored:</p> <p><code>#WARNING (SLiMSim::ExecuteMethod_outputFull): outputFull() should probably not be called from an early() event in a WF model; the output will reflect state at the beginning of the generation, not the end.</code></p></td>
  </tr>
</tbody>
</table>

## Creating New Simulations
Parameters are generated from a plaintext file originally created with `paste`. See the `APCD10Cr_model_20211218_parameters.tsv` file for an example of the file used internally. GitHub provides a nicely rendered view of the TSV file. View the file: [`APCD10Cr_model_20211218_parameters.tsv`](https://github.com/bryce-carson/APCD10Cr_Carson_2022/blob/main/APCD10Cr_model_20211218_parameters.tsv).

```bash
cat > R
R
1e-7
^D
cat > muAP
muAP
1e-4
^D
# and so forth
paste R muAP N m phi muCD sAP r sCD outputEveryNGenerations
```

---

<div id="reproduction-r-script">

### Reproduction R script

For the *reader's* convenience, an R script was written for your use. All the parameters used throughout any simulation are contained in the `parameters.csv` file.

| **⚠ Warning** |
|:---------------|
|Unfortunately, not enough SBATCH / SLURM accounting logs exist at this time to provide those wishing to reproduce the data with information about the time and memory requirements for all the parameter combinations. However, from memory, and this script, the larger simulations with N=10000 run approximately 5.5 - 7.2 days, and require from 4 - 15GB of RAM. The smaller simulations with N=1000 typically complete in 2.5 days or less, and require no more than 5GB of RAM.|

[![asciicast](https://asciinema.org/a/499176.svg)](https://asciinema.org/a/499176)

```R
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
```

</div>

## Changing output frequency
Implemented in the SLiM workflow is the ability to continue simulations and also
to specify the output frequency. This allows a user of the model to increase the
frequency of output from 5,000 generations per output to a higher frequency to
gain more insight into the population genetic dynamics during a period of time
in the local adaptation of the populations. To change the frequency of output:

 - modify the SLiM command-line argument `-d outputEveryNGenerations=5000`,
adjusting the integer, to change the frequency of output.

# Data validation
The mutation output files for every simulation included in the SQLite database
and usable with the Shiny application were validated using the `assertr` and
Appsilon `data.validator` packages. The HTML report feature of `data.validator`
was not used, but was toyed with. The actual method used to monitor for file
corruption or incompletion was the tryCatchLog dump, a log file, the Rout file,
and simple stderr or SLURM facilities.

In short, `assertr` was used to ensure data was not corrupt and `grep` was used
mindfully to watch for any potential errors.

## Continue or validate failed simulations
The second case is implemented with command-line arguments to SLiM defining
constants which specify the random seed, the output directory where save states
can be found, and the output directory where mutation and individual fitness
output files can be found. Pseudocode for how simulations were continued is
provided in the next below.

| **⚠ Warning** |
|:--------------|
| <p>The `*_continue_sims_*` files were used to complete a small number of simulations that had corrupted output at later stages due to filesystem-io errors. The former situation, filesystem-io errors, needed a different solution because the last output generation could not be assured to be completely-output, so the last generation was deleted from the output file and the previous generation save state loaded to resimulate the generations preceeding the error and until completion.</p><p>The scripting for continuing simulations that failed due to memory or time constraints on the computing clusters were ad-hoc and used the logging from SLiM (`-l`), BASH, and some `grep`ing to collect together the necessary information: what simulations failed?; what are the parameters of the failed simulations?; where are the output files?; etc. With that information simulations were completed in that situation.</p><p>This does not impact the normal flow of continuing simulations.</p> |

### Pseudocode
1. Deduce the name of the saveStates from cluster accounting logs and find the
   last two for each simulation that needs to be completed.
2. Find the location of the indFitness.txt file as well, and relocate it to be
   alongside the out_Muts.txt files in the `~/scratch/Output/unfinishedOutput/`
   directory.
3. Build a command-line that will call `slim` with all of the necessary
   `-d` arguments to resume the simulation. This includes:
   - a `-d` for each parameter key-value pair (e.g. `-d R=1e-07`)
   - a `-d slurmSimulationStateFile=FILE` argument, where FILE is the second-last
     save state file
   - a `-s seed` argument to restore the exact pseudo-random trajectory of the
     simulation
   - a `-d outputMutationsFile=FILE` argument
   - a `-d outputIndFitnessFile=FILE` argument

   | **⚠ Warning** |
   |:---------------|
   | This step requires modifying the SLiM model to include a condition that will set the path for the two calls of `writeFile()` and the call of `outputFull()` to the paths specified on the command-line. |

4. Create a backup of the files that will be worked on, in case of progammer error.
5. Delete the last (most recent) save state file, and trim that generation's
   output from the indFitness and out_Muts output files.
6. Call asynchronous processes for each command-line built and finish the
   simulations.

### Examples of command-lines
For the sake of example, this R form will generate the command-line arguments to
be supplied to SLiM.

```r
glue_data(
  .sep = "\n",
  .x = NULL,
  "-d R=1e-07",
  "-d muAP=0.0001",
  "-d N=10000",
  "-d m=0.001",
  "-d phi=0.1",
  "-d muCD=1e-08",
  "-d sAPValue=0",
  "-d r=0.000001",
  "-d sCD=-0.0005",
  "-d outputEveryNGenerations=5000",
  "-d outputMutationsFile='validatedOutput-2022-01-01/APCD10Cr_R=1e-07_r=0.000001_muAP=0.0001_N=10000_m=0.001_phi=0.1_sCD=-0.0005_muCD=1e-08_sAP=000_Replicate=0_1698402343150_out_Muts.txt'",
  "-d outputIndFitnessFile='validatedOutput-2022-01-01/APCD10Cr_R=1e-07_r=0.000001_muAP=0.0001_N=10000_m=0.001_phi=0.1_sCD=-0.0005_muCD=1e-08_sAP=000_Replicate=0_1698402343150_out_indFitness.txt'",
  "-d saveStateDirectory='./saveStates100ThousandGenerations'",
  "-d saveStateFilename='./saveStates100ThousandGenerations/APCD10Cr_R=1e-07_r=0.000001_muAP=0.0001_N=10000_m=0.001_phi=0.1_sCD=-0.0005_muCD=1e-08_sAP=000_Replicate=0_1698402343150_outputFull_Generation=100000.txt'",
  "-s 1698402343150"
) %>%
  str_split(pattern = "\n") %>%
  map2(.x = ., .y = paste0("params_", 1),
       ~ write_lines(x = .x, file = .y))
```

A simple, full command-line to run a simulation will take the form:
```sh
slim -l \ #Enable verbose logging to standard output
  -d R=1e-07 \
  -d muAP=0.0001 \
  -d N=10000 \
  -d m=0.001 \
  -d phi=0.1 \
  -d muCD=1e-08 \
  -d sAPValue=0 \
  -d r=0.000001 \
  -d sCD=-0.0005 \
  -d outputEveryNGenerations=5000 \
  -d outputMutationsFile='validatedOutput-2022-01-01/APCD10Cr_R=1e-07_r=0.000001_muAP=0.0001_N=10000_m=0.001_phi=0.1_sCD=-0.0005_muCD=1e-08_sAP=000_Replicate=0_1698402343150_out_Muts.txt' \
  -d outputIndFitnessFile='validatedOutput-2022-01-01/APCD10Cr_R=1e-07_r=0.000001_muAP=0.0001_N=10000_m=0.001_phi=0.1_sCD=-0.0005_muCD=1e-08_sAP=000_Replicate=0_1698402343150_out_indFitness.txt' \
  -d saveStateDirectory='./saveStates100ThousandGenerations' \
  -d saveStateFilename='./saveStates100ThousandGenerations/APCD10Cr_R=1e-07_r=0.000001_muAP=0.0001_N=10000_m=0.001_phi=0.1_sCD=-0.0005_muCD=1e-08_sAP=000_Replicate=0_1698402343150_outputFull_Generation=100000.txt' \
  -s 169840234315 \
  APCD10Cr_model_20211222.slim
```

| **⚠ Warning** |
|:--------------|
| SLiM handles command-line arguments in several ways. Sometimes a number can be taken in as a string from the command-line, and other times it cannot be. You should study the SLiM manual and be familiar with shell escape sequences and peculiarities for your shell and command environment before launching commands. |

# Data visualization
Visualizations of the data are provided in the R Shiny application:
`APCD10Cr_mutations_app.R`. The application depends on a single-file database:
`APCD10Cr_mutations_app_db_created_20211228.db`.

The database contains the analyzed information and metadata of the mutation
output files. The metadata uniquely specifies the ten replicates which compose a
parameter set. The heatmaps and sojourn density data created from the raw
mutations information are included in the database, and are retrieved from it by
the Shiny application for visualization and study. The SQLite database is stored
in the Federated Research Data Repository (FRDR) along with the raw data from
the research project this (GitHub) repository belongs to.

General procedure of the `*_mutations_analysis` workflow:
1. `APCD10Cr_mutations_analysis_job_script.sh` copies `*out_Muts.txt` files from a scratch directory to node-local SSD storage and calls an R script after loading the R module in the compute environment (Compute Canada clusters are managed with `lmod`).
2. `APCD10Cr_mutations_analysis.R` performs the analytical work on the mutations, such as estimating population statistics and stores this information in an SQLite database.
3. The database is moved to the home directory, and the node-local storage is cleared by the SLURM scheduler after the job ends.

- The application does not at this time include support for exporting the R objects it accesses from the SQLite database or downloading the plots it generates from those objects.

- As of 2022-01-06 the method for accessing the data outside of the Shiny application is through using the functions in the `APCD10Cr_mutations_analysis.R` script in an interactive R session.

# Data publication (archival)
The research data produced by the code in this repository is archived in the FRDR under the dataset title: Raw and analyzed data for: Mee, J.A., Carson, B.A., & Yeaman, S.M. (2022) The accumulation of conditionally deleterious mutational load is augmented in regions linked to adaptive loci. BioRXiv manuscript in preparation.

<div align="center">

![FRDR-DFDR logo in colour with both French and English names and a transparent background, for display over black or dark colours](FRDR-FR-EN-WHITE.png#gh-dark-mode-only)
![FRDR-DFDR logo in colour with both French and English names and a transparent background, for display over white or light colours](FRDR-FR-EN.png#gh-light-mode-only)

</div>

# Funding
We acknowledge the support of the Natural Sciences and Engineering Research Council of Canada (NSERC).

Nous remercions le Conseil de recherches en sciences naturelles et en génie du Canada (CRSNG) de son soutien.

<div align="center">

![NSERC signature in white coloured type face, with transparent background](NSERC_FIP_WHITE.png#gh-dark-mode-only)
![NSERC signature in black coloured type face, with transparent background](NSERC_FIP_BLACK.png#gh-light-mode-only)

</div>

<!-- TODO: Citation style! -->
# References
[1] Raw and analyzed data for: Mee, J.A., Carson, B.A., & Yeaman, S.M. (2022) The accumulation of conditionally deleterious mutational load is augmented in regions linked to adaptive loci. **BioRXiv** manuscript in preparation. DOI: 10.20383/102.0526.

[2] Benjamin C Haller, Philipp W Messer,  SLiM 3: Forward Genetic Simulations Beyond the Wright–Fisher Model, **Molecular Biology and Evolution**, Volume 36, Issue 3, March 2019, Pages 632–637, <a href="https://doi.org/10.1093/molbev/msy228" data-google-interstitial="false">https://doi.org/10.1093/molbev/msy228</a>


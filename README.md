<!-- # TODO: -->
<!-- 1. Finish writing the README -->
<!-- 2. Assess the need for a *simple* R6 class for simulations that ties together parameters, output files, and the continuance of that simulation from any existing save state file. -->
<!-- 3. Fully document the sub-projects in the repository (SLiM, Shiny, etc.) -->
<!-- 4. Complete the Shiny application and allow Jon to review it. -->
<div align="center">
<h3>Antagonistic Pleiotropy & Conditionally Deleterious Mutations</h3>
<h3>in Local Adaptation with Functional Genetic Redundancy</h3>
<h5>Bryce Carson</h5>
<h5>2022-04-30</h5>
</div>

<div align="center">
<details>
<summary>Why the title?</summary>
Explain the titling of this markdown document...
</details>
</div>
    
<details>
<summary>What is local adaptation?</summary>
<p>Local adaptation is genetic adaptation to a local environment; for the (sub-)population the term applies to (a locally adpated population), that population has its highest fitness in that location. If the population migrates to another location its fitness will be reduced. Some definitions also require that the (sub-)population have the highest fitness relative to any sample of individuals of the species that could migrate to that location.</p>
</details>

<a href="https://www.github.com/bryce-carson/Carson2022">The *Carson 2022* repository</a> hosts the source code and documentation of that code used in the production of data for a study of local adaptation using SLiM. It also hosts the source code of the documentation (from which this webpage is generated).

At the time of publication of the data to the Federated Research Data Repository (hereafter FRDR), the manuscript describing this research is not published and is in preparation. The researchers involved in this study are listed in the table below.

The title for the BioRXiv manuscript in preparation is: Mee, J.A., Carson, C., & Yeaman, S.M. (2022) *The accumulation of conditionally deleterious mutational load is augmented in regions linked to adaptive loci*.

<table>
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

## Contribution details
The owner of this repository, Bryce Carson, is the sole author of the data and source code for the source files in this repository, and the dataset linking to this repository from the FRDR.

# Federated Research Data Repository (FRDR)
Data published in the FRDR was created as a research output during the method of study for a forthcoming publication by the data author and others. When a manuscript is in a pre-print archive or officially published this repository will be updated to reflect that.

If you have questions related to the data published in the FRDR or GitHub repository contact Bryce Carson (<bcars268@mtroyal.ca>).

# CONTENTS
```
APCD10Cr_Carson_2022
.
├── APCD10Cr_continue_unfinished_simulations
│   ├── continue_sims_20211005_part_one.R
│   ├── continue_sims_20211005_part_two.R
│   ├── continue_sims_20220425.Rmd
│   └── continue_sims_using_gnu_parallel.sh
├── COPYING.txt
├── ACPD10Cr_data_validation
│   ├── APCD10Cr_data_validation.R
│   ├── APCD10Cr_data_validation.sh
│   └── renv.lock
├── README.md
├── APCD10Cr_mutations_analysis_generate_RSQLite3_database
│   ├── APCD10Cr_mutations_analysis.R
│   ├── APCD10Cr_mutations_analysis_job_script.sh
│   └── renv.lock
├── ACPD10Cr_sacct
│   ├── APCD10Cr_RSession?.RData
│   ├── APCD10Cr_sacct.log
│   ├── APCD10Cr_sacct.log.R
│   ├── APCD10Cr_sacct.RData
│   └── APCD10Cr_sacct.Rhistory
├── ACPD10Cr_shiny
│   ├── APCD10Cr_mutations_app.R
│   ├── APCD10Cr_mutations_db_created_20211228.db
│   └── renv.lock
└── ACPD10Cr_SLiM3
    ├── APCD10Cr_20211222.slim
    ├── APCD10Cr_generate_parameter_files.sh
    ├── APCD10Cr_job_script.sh
    └── APCD10Cr_parameters_20211218.tsv
```

There are several files related to the general workflow: `APCD10Cr-2021-12-01.slim`; `validateOutput.R`; `MeeCarsonYeaman2021.R`; and `shinyAPCD.R`. The first two R files have BASH scripts of the same name (i.e. `.sh` file extension) used for SLURM scheduling and launching the R script on Compute Canada clusters.

<div class=warning>

> *⚠ Warning:*
>
> Use `renv` to load the lockfile within each sub-directory related to R workflows. Lockfiles specify the packages (and versions thereof) and their dependencies used in the project regardless of machine or architecture. See the vignette for renv and the talk at RStudio::Conf 2020 for more information on and an introduction to renv.
 
> *⚠ Warning:*
>
> Refactoring of paths and filenames has not been undertaken. Where relevant, the variables or filenames referred to in files has been documented near the top of the file. During reproduction, editing the files may be necessary to ensure that files are found in the expected places.

</div>

---


## dataValidation/
The mutation output files for every simulation included in the SQLite database and usable with the Shiny application were validated using the `assertr` and Appsilon `data.validator` packages.

An HTML report was not generated for the full breadth of output, but was toyed with. The actual method used to monitor for file corruption or incompletion was the tryCatchLog dump, a log file, the Rout, and simple stderr or SLURM facilities.

## RSQLite/
The database contains the analyzed information and metadata of the mutation output files. The metadata uniquely specifies the ten replicates which compose a parameter set.

The heatmaps and sojourn density data are included in the database, and are retrieved from it by the Shiny application for visualization and study.

The SQLite database is stored in the Federated Research Data Repository (FRDR) along with the raw data from the research project this (GitHub) repository belongs to.

> When the FRDR submission is approved, this repository will be updated with a link to it.

1. `MeeCarsonYeaman2021.sh` copies `*out_Muts.txt` files from a scratch directory to node-local SSD storage and calls the R script after loading the R module in the compute environment.
2. <code id="meecarsonyeaman2021">MeeCarsonYeaman2021.R</code> performs the analytical work on the mutations, such as estimating population statistics and stores this information in an SQLite database.

## Shiny/ 
The application does not at this time include support for exporting the R objects it accesses from the SQLite database or downloading the plots it generates from those objects.

As of 2022-01-06 the method for accessing the data outside of the Shiny application is through using the functions in the [`MeeCarsonYeaman2021.R`](#rsqlite) script in an interactive R session.

## SLiM/
**A SLiM Model**

TODO: refer to c22pkg, not generateParameterFiles.sh, and write as if I wrote an R package, but do not make it a necessity.

The SLiM model is not particularly complex, but the supporting work files may be challenging. There are three use cases: running new simulations; continuing simulations; increasing the output frequency for existing simulations.

<details>
<summary>New simulations</summary>
The first use–case takes fewer command–line arguments than the others, it simply `--define`s the parameters of the simulation (e.g. `R=1e-8`). The command–line is generated from a BASH script that depends on a SLURM environment variable, `$SLURM_ARRAY_JOB_ID`, which will control which parameter file is read by `xargs` and used to define the simulation parameters.

Parameters are generated from a tsv file. See the `parameterSet-2021-12-18.txt` file for an example.

<div class="warning">

> *⚠ Warning*
>
> The SLiM model outputs the entire model state for save files in the same event block as the custom output is generated. This was written mostly in 2019, and as such was not changed. The implication of output being at the beginning of a generation or the end was discussed and deemed not an important distinction when the frequency of output is every five thousand generations.
> 
> This creates the following warning, but can be (and was) ignored:
>
> > `#WARNING (SLiMSim::ExecuteMethod_outputFull): outputFull() should probably not be called from an early() event in a WF model; the output will reflect state at the beginning of the generation, not the end.`

</div>
</details>

<details>
<summary>Continuing simulations</summary>
The second case is implemented with command-line arguments to SLiM defining constants which specify the random seed, the output directory where save states can be found, and the output directory where mutation and individual fitness output files can be found.

<div class="warning">

> *⚠ Warning:*
>
> The continueSimulations directory contains the scripts that were used to complete a small number of simulations that had corrupted output at later stages due to filesystem-io errors. The scripting for continuing simulations that failed due to memory or time constraints on the computing clusters were ad-hoc and used the logging from SLiM (`-l`), BASH, and some `grep`ing to collect together the necessary information: what simulations failed?; what are the parameters of the failed simulations?; where are the output files?; etc. With that information simulations were completed in that situation. The former situation, filesystem-io errors, needed a different solution because the last output generation could not be assured to be completely-output, so the last generation was deleted from the output file and the previous generation save state loaded to resimulate the generations preceeding the error and until completion.
>
> This does not impact the normal flow of continuing simulations.

</div>

Refer to the documentation under the [continueSimulations/](#continuesimulations) heading to learn about that workflow.
</details>

<details>
<summary>Changing output frequency</summary>
The third case was not actually used, but is generally implemented in the SLiM workflow by taking command-line arguments to continue simulations and also to specify the output frequency. This allows a user of the model to increase the frequency of output from 5,000 generations per output to a higher frequency to gain more insight into the population genetic dynamics during a period of time in the local adaptation of the populations.

 - Modify the SLiM command-line argument `-d outputEveryNGenerations=5000`, adjusting the integer, to change the frequency of output.
</details>

The version of SLiM that was used to generate the output on Compute Canada clusters is given below.

> <div class="justgivemeindentation"><pre><font color="#2AA1B3"><b>~/bin</b></font> <font color="#26A269"><b>❯</b></font> slim -v<br>SLiM version 3.3.2, built May 4 2020 19:43:23</pre></div>
>
> <div class="oxford-citation-text">
            <p>Benjamin C Haller, Philipp W Messer,  SLiM 3: Forward Genetic Simulations Beyond the Wright–Fisher Model, <em>Molecular Biology and Evolution</em>, Volume 36, Issue 3, March 2019, Pages 632–637, <a href="https://doi.org/10.1093/molbev/msy228" data-google-interstitial="false">https://doi.org/10.1093/molbev/msy228</a></p>
        </div>

## continueSimulations/
### Pseudocode
1. Infer the name of the saveStates and find the last two for each simulation that needs to be completed.
2. Find the location of the indFitness.txt file as well, and relocate it to be alongside the out_Muts.txt files in the `~/scratch/Output/unfinishedOutput/` directory.
3. Build a command-line that will call `slim` with all of the necessary `-d[efine]` arguments to resume the simulation. This includes:
  - a `-d` for each parameter key-value pair (e.g. `-d R=1e-07`).
  - a `-d slurmSimulationStateFile=FILE` argument, where FILE is the second-last save state file.
  - a `-s seed` argument to restore the exact pseudo-random trajectory of the simulation.
  - a `-d outputMutationsFile=FILE` argument.
  - a `-d outputIndFitnessFile=FILE` argument.

  NOTE: this step requires modifying the SLiM model to include a condition that will set the path for the two calls of `writeFile()` and the call of `outputFull()` to the paths specified on the command-line.

4. Create a backup of the files that will be worked on, just in case of a progammer error. "Only human."
5. Delete the last (most recent) save state file, and trim that generation's output from the indFitness and out_Muts output files.
6. Call asynchronous processes for each command-line built and finish the simulations.

# FRDR
These are the files published in the FRDR dataset: . Link: .

![screenshot_of_directory_structure_of_globus_dataset.png](globus.png)

TODO: get a new top-level directory listing (just the folder names and the name of the database) for the README.md.

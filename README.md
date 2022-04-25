<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/water.css@2/out/water.css">
<link href="https://fonts.googleapis.com/css2?family=Source+Code+Pro:wght@700&display=swap" rel="stylesheet">
<style>
  .oxford-citation-text {
    font-style: normal;
    padding-left: 0.5in;
    text-indent: -0.5in;
  }
  .justgivemeindentation {
      font-family: 'Roboto', monospace;
      font-weight: 700;
      font-style: normal;
  }
  h1,h2,h3 {
      font-family: 'Source Code Pro', regular;
      font-style: normal;
  }
  blockquote p {
      font-style: normal;
  }
  blockquote p em {
      color: yellow;
  }
</style>

# TODO:
1. Finish writing the README
2. Assess the need for a *simple* R6 class for simulations that ties together parameters, output files, and the continuance of that simulation from any existing save state file.
3. Fully document the sub-projects in the repository (SLiM, Shiny, etc.)
4. Complete the Shiny application and allow Jon to review it.

---

<div style="text-align: center;"><h1>Carson 2022</h1></div>

<div class="local-adaptation aside">
  <aside style="float: right; margin-right: -35%;">
    <details>
      <summary>What is local adaptation?</summary>
      <p>Local adaptation is genetic adaptation to a local environment; for the (sub-)population the term applies to (a locally adpated population), that population has its highest fitness in that location. If the population migrates to another location its fitness will be reduced. Some definitions also require that the (sub-)population have the highest fitness relative to any sample of individuals of the species that could migrate to that location.</p>
    </details>
  </aside>
</div>

<div style="margin-right: 30pt; margin-right: 30pt;">
  <a href="https://www.github.com/bryce-carson/Carson2022">The *Carson 2022* repository</a> hosts the source code and documentation of that code used in the production of data for a study of local adaptation using SLiM. It also hosts the source code of the documentation (from which this webpage is generated).

  At the time of publication of the data to the FRDR the manuscript describing this research is not published. The researchers involved are listed below (with contributing roles and affiliations in parentheses).

  <table>
    <tr><th>Contributor</th><th>ORCID iD</th><th>Contribution</th><th>Affiliation</th></tr>
    
    <tr class="table-row">
      <td class="table-column-contributors-names">Bryce Carson</td>
      <td class="table-column-contributors-orcid-id">???</td>
      <td class="table-column-contributors-affiliations">Data, code author</td>
      <td class="table-column-contributors-affiliations">Mount Royal University (Research Assistant)</td>
    </tr>

    <tr class="table-row">
      <td class="table-column-contributors-names">Jon Mee</td>
      <td class="table-column-contributors-orcid-id">???</td>
      <td class="table-column-contributors-contribution">Principle investigator</td>
      <td class="table-column-contributors-affiliation">Mount Royal University (Associate Professor)</td>
    </tr>

    <tr class="table-row">
      <td class="table-column-contributors-names">Sam Yeaman</td>
      <td class="table-column-contributors-orcid-id">???</td>
      <td class="table-column-contributors-contribution">Principle investigator</td>
      <td class="table-column-contributors-affiliation">University of Calgary (Associate Professor)</td>
    </tr>
  </table>
</div>

# Federated Research Data Repository (FRDR)
Data published in the FRDR was created as a research output during the method of study for a forthcoming publication by the data author and others. When a manuscript is in a pre-print archive or officially published this repository will be updated to reflect that.

If you have questions related to the data or GitHub repository only, contact Bryce Carson (<bcars268@mtroyal.ca>).

# CONTENTS
```
.
├── brycecarsonpaperstoprint.zip
├── continueSimulations
│   ├── continueParallel.sh
│   ├── continueSimulations-2021-10-05-partOne.R
│   ├── continueSimulations-2021-10-05-partTwo.R
│   └── continueSimulations.Rmd
├── COPYING.txt
├── dataValidation
│   ├── dataValidation.R
│   ├── dataValidation.sh
│   └── renv.lock
├── #README.html#
├── README.html
├── README.log
├── README.md
├── README.Rmd
├── README.tex
├── RSQLite
│   ├── MeeCarsonYeaman2021.R
│   ├── MeeCarsonYeaman2021.sh
│   └── renv.lock
├── sacct
│   ├── RSession?.RData
│   ├── sacct.log
│   ├── sacct.log.R
│   ├── sacct.RData
│   └── sacct.Rhistory
├── Shiny
│   ├── MeeCarsonYeaman2021-12-28T21:54.db
│   ├── renv.lock
│   └── shinyAPCD.R
└── SLiM
    ├── APCD10Cr-2021-12-22.slim
    ├── generateParameterFiles.sh
    ├── jobScript.sh
    └── parameterSet-2021-12-18.tsv

6 directories, 30 files
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

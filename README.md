This file was written to help the reader in reproducing the results contained in the present study. If you have further questions related to this project only, contact the author marked for communications.

There are several files related to the workflow: `APCD10Cr-2021-12-01.slim`; `validateOutput.R`; `MeeCarsonYeaman2021.R`; and `APCD_app.R`. The first two R files have BASH scripts of the same name (i.e. `.sh` file extension) used for SLURM scheduling and launching the R script on Compute Canada clusters.

# ! Warning
Use `renv` to load the lockfile provided with each sub-directory related to R workflows. The lockfiles specify the packages, dependencies, and versions used in the project regardless of machine or architecture.

See the vignette for renv and the talk at RStudio::Conf 2020 for more information on and an introduction to renv.

## SLiM
The SLiM model is not particularly complex, but the supporting work files may be challenging. There are three use cases: running new simulations; continuing simulations; increasing the output frequency for existing simulations.

The third case was not actually used, but is generally implemented in the SLiM workflow by taking command-line arguments to continue simulations and also to specify the output frequency. This allows a user of the model to increase the frequency of output from 5,000 generations per output to a higher frequency to gain more insight into the population genetic dynamics during a period of time in the local adaptation of the populations.

The second case is implemented with command-line arguments to SLiM defining constants which specify the random seed, the output directory where save states can be found, and the output directory where mutation and individual fitness output files can be found.

# ! WARNING
The continueSimulations directory contains the scripts that were used to complete a small number of simulations that had corrupted output at later stages due to filesystem-io errors.
The scripting for continuing simulations that failed due to memory or time constraints on the computing clusters were ad-hoc and used the logging from SLiM (`-l`), BASH, and some `grep`ing to collect together the necessary information: what simulations failed?; what are the parameters of the failed simulations?; where are the output files?; etc. With that information simulations were completed in that situation. The former situation, filesystem-io errors, needed a different solution because the last output generation could not be assured to be completely-output, so the last generation was deleted from the output file and the previous generation save state loaded to resimulate the generations preceeding the error and until completion.

The first case takes fewer command-line arguments than the others, it simply `--define`s the parameters of the simulation (e.g. `R=1e-8`). The command-line is generated from a BASH script that depends on a SLURM environment variable, `$SLURM_ARRAY_JOB_ID`, which will control which parameter file is read by `xargs` and used to define the simulation parameters.

As an example:
<pre><font color="#444444">───────┬─────────────────────────────────────────────────────────────────────────────────────────</font>
       <font color="#444444">│ </font>File: <b>jobScript.sh</b>
<font color="#444444">───────┼─────────────────────────────────────────────────────────────────────────────────────────</font>
<font color="#444444">   1</font>   <font color="#444444">│</font> <font color="#767676">#!/bin/bash</font>
<font color="#444444">   2</font>   <font color="#444444">│</font> <font color="#767676">#SBATCH --array=1-6</font>
<font color="#444444">   3</font>   <font color="#444444">│</font> <font color="#767676">#SBATCH --time=06-12:00:00</font>
<font color="#444444">   4</font>   <font color="#444444">│</font> <font color="#767676">#SBATCH --mem-per-cpu=9G</font>
<font color="#444444">   5</font>   <font color="#444444">│</font> <font color="#767676">#SBATCH --ntasks=1</font>
<font color="#444444">   6</font>   <font color="#444444">│</font> <font color="#767676">#SBATCH --no-kill</font>
<font color="#444444">   7</font>   <font color="#444444">│</font> <font color="#767676">#SBATCH --job-name=&quot;nTenThousand-MissingParams-2021-12-22.txt&quot;</font>
<font color="#444444">   8</font>   <font color="#444444">│</font> <font color="#767676">#SBATCH --mail-type=TIME_LIMIT_90,ARRAY_TASKS,FAIL</font>
<font color="#444444">   9</font>   <font color="#444444">│</font> <font color="#767676">#SBATCH --mail-user=bcars268@mtroyal.ca</font>
<font color="#444444">  10</font>   <font color="#444444">│</font> <font color="#FFFFFF">slim</font><font color="#FF8700"> -m -l</font><font color="#FFFFFF"> `xargs</font><font color="#FF8700"> -a</font><font color="#FFFFFF"> params_${SLURM_ARRAY_TASK_ID}` APCD10Cr-2021-12-22.slim</font>
<font color="#444444">  11</font>   <font color="#444444">│</font> <font color="#767676"># To have replicates, this job should merely be submitted ten times for ease.</font>
<font color="#444444">───────┴─────────────────────────────────────────────────────────────────────────────────────────</font>

</pre>

Parameters are generated from a tsv file with the following format:
<pre><font color="#444444">───────┬─────────────────────────────────────────────────────────────────────────────────────────</font>
       <font color="#444444">│ </font>File: <b>parameterSet-Missing-2021-12-18.txt</b>
<font color="#444444">───────┼─────────────────────────────────────────────────────────────────────────────────────────</font>
<font color="#444444">   1</font>   <font color="#444444">│</font> <font color="#FFFFFF">R   muAP    N   m   phi muCD    sAP r   sCD outputEveryNGenerations</font>
<font color="#444444">   2</font>   <font color="#444444">│</font> <font color="#FFFFFF">1e-7    1e-4    10000   0.001   0.5 1e-8    c(-0.0625,0,0.0625) 0.000001    (-m)    5000</font>
<font color="#444444">   3</font>   <font color="#444444">│</font> <font color="#FFFFFF">                        c(-0.0833,0,0.0833)</font>
<font color="#444444">   4</font>   <font color="#444444">│</font> <font color="#FFFFFF">                        c(-0.1,0,0.1)</font>
<font color="#444444">   5</font>   <font color="#444444">│</font> <font color="#FFFFFF">                        c(-0.1666,0,0.1666)</font>
<font color="#444444">   6</font>   <font color="#444444">│</font> <font color="#FFFFFF">                        c(-0.25,0,0.25)</font>
<font color="#444444">   7</font>   <font color="#444444">│</font> <font color="#FFFFFF">                        c(-0.5,0,0.5)</font>
<font color="#444444">───────┴─────────────────────────────────────────────────────────────────────────────────────────</font>

</pre>

# ! WARNING
The SLiM model outputs the entire model state for save files in the same event block as the custom output is generated. This was written mostly in 2019, and as such was not changed. The implication of output being at the beginning of a generation or the end was discussed and deemed not an important distinction when the frequency of output is every five thousand generations.
```
#WARNING (SLiMSim::ExecuteMethod_outputFull): outputFull() should probably not be called from an early() event in a WF model; the output will reflect state at the beginning of the generation, not the end.
```

The version of SLiM that was used to generate the output on Compute Canada clusters is given below.
<pre><font color="#A2734C"><b>bcars268</b></font> in <font color="#196C46"><b>gra-login2</b></font> in <font color="#2AA1B3"><b>~/bin</b></font> 
<font color="#26A269"><b>❯</b></font> slim -v
SLiM version 3.3.2, built May  4 2020 19:43:23</pre>

## Data Validation
The mutation output files for every simulation included in the SQLite database and usable with the Shiny application were validated using the `assertr` and Appsilon `data.validator` packages.

An HTML report was not generated for the full breadth of output, but was toyed with. The actual method used to monitor for file corruption or incompletion was the tryCatchLog dump, a log file, the Rout, and simple stderr or SLURM facilities.

## RSQLite Database
The database contains the analyzed information and metadata of the mutation output files. The metadata uniquely specifies the ten replicates which compose a parameter set.

The heatmaps and sojourn density data are included in the database, and are retrieved from it by the Shiny application for visualization and study.

## Shiny Application
The application does not at this time include support for exporting the R objects it accesses from the SQLite database or downloading the plots it generates from those objects.

As of 2022-01-06 the method for accessing the data outside of the Shiny application is through using the functions in the `MeeCarsonYeaman2021.R` script in an interactive R session.

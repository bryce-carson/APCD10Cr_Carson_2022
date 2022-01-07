This file was written to help the reader in reproducing the results contained in the present study. If you have further questions related to this project only, contact the author marked for communications.

There are several files related to the workflow: `APCD10Cr-2021-12-01.slim`; `validateOutput.R`; `MeeCarsonYeaman2021.R`; and `APCD_app.R`. The first two R files have BASH scripts of the same name (i.e. `.sh` file extension) used for SLURM scheduling and launching the R script on Compute Canada clusters.

# ! Warning
Use `renv` to load the lockfile provided with each sub-directory related to R workflows. The lockfiles specify the packages, dependencies, and versions used in the project regardless of machine or architecture.

See the vignette for renv and the talk at RStudio::Conf 2020 for more information on and an introduction to renv.

## SLiM
The SLiM model is not particularly complex, but the supporting work files may be challenging. There are three use cases: running new simulations; continuing simulations; increasing the output frequency for existing simulations.

The third case was not actually used, but is generally implemented in the SLiM workflow by taking command-line arguments to continue simulations and also to specify the output frequency. This allows a user of the model to increase the frequency of output from 5,000 generations per output to a higher frequency to gain more insight into the population genetic dynamics during a period of time in the local adaptation of the populations.

The second case is implemented with command-line arguments to SLiM defining constants which specify the random seed, the output directory where save states can be found, and the output directory where mutation and individual fitness output files can be found.

The first case takes fewer command-line arguments than the others, it simply `--define`s the parameters of the simulation (e.g. `R=1e-8`). The command-line is generated from a BASH script that depends on a SLURM environment variable, `$SLURM_ARRAY_JOB_ID`, which will control which parameter file is read by `xargs` and used to define the simulation parameters.

As an example:
```sh
#!/usr/bin/env bash
#SBATCH
#SBATCH
```

## Data Validation
The mutation output files for every simulation included in the SQLite database and usable with the Shiny application were validated using the `assertr` and Appsilon `data.validator` packages.

An HTML report was not generated for the full breadth of output, but was toyed with. The actual method used to monitor for file corruption or incompletion was the tryCatchLog dump, a log file, the Rout, and simple stderr or SLURM facilities.

## RSQLite Database
The database contains the analyzed information and metadata of the mutation output files. The metadata uniquely specifies the ten replicates which compose a parameter set.

The heatmaps and sojourn density data are included in the database, and are retrieved from it by the Shiny application for visualization and study.

## Shiny Application
The application does not at this time include support for exporting the R objects it accesses from the SQLite database or downloading the plots it generates from those objects.

As of 2022-01-06 the method for accessing the data outside of the Shiny application is through using the functions in the `MeeCarsonYeaman2021.R` script in an interactive R session.
library(data.table)
library(tidyverse)
library(lubridate)
library(parseSlurmDuration) # devtools::install_github("bryce-carson/parseSlurmDuration")
library(magrittr)
library(ggextra)

sacct.log <-
  read_fwf(
    "sacct.log",
    skip = 2,
    col_positions = fwf_widths(
      cols_widths + 1,
      col_names = c(
        "JobName",
        "JobID",
        "State",
        "Submit",
        "Start",
        "End",
        "Timelimit",
        "Elapsed",
        "CPUTime",
        "ReqMem",
        "MaxVMSize",
        "ExitCode",
        "DerivedExitCode"
      )
    )
  )
sacct.log %<>% map_at("Timelimit", "parseSlurmDuration")

sacct.log %>% filter(State == "COMPLETED",
                     !JobName %like% "batch",
                     !JobName %like% "extern") %>%
  summarize(uniqJobNames = unique(JobName))


# !JobName %like% "batch",
# !JobName %like% "extern"


sacct.log %>% filter(State == "COMPLETED",
                     !State %like% "batch",
                     State %like% "extern",
                     !JobName %like% "rsync",
                     !JobName %like% "interactive",
                     !JobName %like% "generateDB",
                     !JobName %like% "hostname",
                     !JobName %like% "organize",
                     !JobName %like% "dataValidation",
                     !JobName %like% "debugging") %>%
  mutate(MaxVMSize = MaxVMSize %>% str_extract("^([[:digit:]]*?)(?=[[:alpha:]])") %>% as.integer()) %>%
  mutate(JobID = JobID %>% str_extract("^([[:digit:]]*?)(?=_)") %>% as.integer()) %>%
  group_by(JobID) %>%
  summarize(MaxVMSize = sum(MaxVMSize))


  mutate(Elapsed = map(Elapsed, parseSlurmDuration))
  mutate(Elapsed = as.duration(Elapsed)) %>%
  ggplot() +
    geom_boxplot(mapping = aes(x = MaxVMSize, y = Elapsed, group = JobName))

# Copyright 2022 Bryce Carson
# Author: Bryce Carson <bcars268@mtroyal.ca>
# URL: https://github.com/bryce-carson/APCD10Cr_Carson_2022
#
# APCD_app.R is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# APCD_app.R is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.

library(ComplexHeatmap)
library(DBI)
library(DT)
library(RSQLite)
library(circlize)
library(shiny)
library(shinyWidgets)
library(tidyverse)
library(glue)
library(waiter)

options(shiny.reactlog = TRUE)
ht_opt$message <- FALSE

## TODO: document _for the people that didn't already read it twice_ that the database is a hard requirement!
## E.g.: ensure the database is fully downloaded before launching the app, and ensure that the db is in the same working directory as the *app.R file.
db <- dbConnect(RSQLite::SQLite(), "APCD10Cr_mutations_app_db_created_20211228.db")
metadata <- dbReadTable(db, "metadata")
# DataTable cannot render blob objects, so we need to ensure that we deselect
# them before rendering.
metadata_pretty <- metadata %>%
  select(
    -filenameList,
    -replicates
  )

makeAComplexHeatmap <- function(matrix, windowSize = 1) {
  offset <- 1e-8
  ## NOTE: the maximum value from the range of rows containing conditionally
  ## deleterious mutations only.
  cdrange <- sort(
    c(1, max(range(
      if (windowSize == 1) {
        matrix[-seq(50, 950, length = 10), ]
      } else {
        matrix[-seq(5, 95, length = 10), ]
      }
    )))
  )
  aprange <- c(-0.025, 0, 0.025)
  breaks <- sort(c(aprange, (max(aprange) + offset), 1, max(cdrange)))
  colors <- c("Purple", "White", "Orange", "White", "White", "Black")
  matrixColours <- circlize::colorRamp2(breaks, colors)
  splitChromosomes <- if (windowSize == 1) {
    rep(paste0("Chr ", letters[1:10]), 100) %>% sort()
  } else {
    rep(paste0("Chr ", letters[1:10]), 10) %>% sort()
  }
  return(Heatmap(matrix,
                 height = unit(24, "cm"),
    cluster_columns = FALSE, cluster_rows = FALSE, col = matrixColours, show_heatmap_legend = TRUE, show_column_names = TRUE, use_raster = TRUE, split = splitChromosomes, gap = unit(3, "mm"), border = TRUE,
    heatmap_legend_param = list(
      at = breaks,
      labels = c(min(aprange), "0", max(aprange), "NIL", "1", as.character(max(cdrange)))
    )
  ))
}

server <- function(input, output, session) {
  ## Hide the initial loading waiter when the server idles for the first time
  ## after load.
  waiter::waiter_preloader(html = spin_1(),
                           color = "#333e48",
                           image = "",
                           fadeout = TRUE,
                           logo = "")
  fullApp_loadingScreen <- waiter::Waiter$new(
    id = c("sojournDensityPlot",
           "heatmapPopulationOne",
           "heatmapPopulationTwo"),
    hide_on_render = TRUE
  )
  
  ##### OUTPUTS
  ## NOTE: the currently selected row is accessed with the
  ## `input$metadata_pretty_rows_selected` variable.
  output$metadata_pretty <- DT::renderDataTable(metadata_pretty,
    selection = "single",
    options = list(
      rownames = FALSE,
      searchHighlight = TRUE
    ),
    server = FALSE
  )

  output$sojournDensityPlot <- renderPlot({
    req(input$metadata_pretty_rows_selected)

    if (is.list(sojournDensityList()) != TRUE) {
      print("sojournDensityList() is not a list. Check the reactive function, ensure the database is clean, etc.")
    } else {
      # print(class(sojournDensityList()))
      # print(sojournDensityList())
      base <- ggplot()
      base <- base +
        geom_point(
          data = sojournDensityList(),
          mapping = aes(x = position, y = meanDensity)
        ) +
        geom_vline(xintercept = seq(50, 950, length = 10) * 1000, size = 0.5)
      return(base)
    }
  })

  output$heatmapPopulationOne <- renderPlot({
    req(input$metadata_pretty_rows_selected)
    return(heatmapList()[[1]] %>% makeAComplexHeatmap())
  })
  output$heatmapPopulationTwo <- renderPlot({
    req(input$metadata_pretty_rows_selected)
    return(heatmapList()[[2]] %>% makeAComplexHeatmap())
  })


  ##### REACTIVES
  sojournDensityList <- reactive({
    req(input$metadata_pretty_rows_selected)

    sojournDensityList_rawCxn <- dbGetQuery(db, "SELECT sojournDensityList FROM sojournDensities WHERE rowid = :selected_row_id",
      params = list(selected_row_id = input$metadata_pretty_rows_selected)
    )$sojournDensityList %>% unlist()

    if (is.raw(sojournDensityList_rawCxn) == TRUE) {
      sojournDensityList_deblobbed <- sojournDensityList_rawCxn %>% unserialize()
      return(sojournDensityList_deblobbed)
    } else {
      print("Returned value from database query is not a raw / connection that can be unserialized.")
      print(glue("Class of sojournDensityList_rawCxn: {class(sojournDensityList_rawCxn)}"))
    }
  })

  heatmapList <- reactive({
    # Requirements
    req(input$replicate_selection)
    req(input$metadata_pretty_rows_selected)

    # SQLite query
    # Must be a single filename
    heatmap_List <- dbGetQuery(db, "SELECT heatmapList FROM heatmaps WHERE filename IS :filename",
      params = list(filename = input$replicate_selection)
    )$heatmapList[[1]] %>% unserialize()
    return(heatmap_List)
  })

  ##### EVENT OBSERVATIONS
  observeEvent(input$metadata_pretty_rows_selected,
    {
      if (!is.null(input$metadata_pretty_rows_selected)) {
        fullApp_loadingScreen$show()
        
        ## The filenames, as a named list.
        parameter_set_filenames <- dplyr::slice(metadata, input$metadata_pretty_rows_selected) %>%
          pull(filenameList) %>%
          chuck(1) %>%
          unserialize() %>%
          unlist() %>%
          as.character() %>%
          as.list()
        names(parameter_set_filenames) <- letters[1:10]

        ## The random seed extracted from the filename.
        parameter_set_seeds <- parameter_set_filenames %>%
          str_extract("\\d{13}") %>%
          as.list()

        freezeReactiveValue(input, "replicate_selection")
        updatePickerInput(session = session,
                          inputId = "replicate_selection",
                          choices = parameter_set_filenames,
                          choicesOpt = list(
                            subtext = paste(
                              "Random seed:",
                              parameter_set_seeds
                            )
                          ),
                          options = pickerOptions(showSubtext = TRUE)
        )
        
        updateTabsetPanel(
          inputId = "conditional_display",
          selected = "sojourn_density"
        )
      } else {
        updateTabsetPanel(
          inputId = "conditional_display",
          selected = "user_instruction"
        )
      }
    },
    ignoreNULL = FALSE
  )
}

ui <- fluidPage(
  ## Use Waiter
  waiter::useWaiter(),
  
  ## Application title
  titlePanel("Antagonistic Pleiotropy (w/ Conditionally Deleterious Mutations)"),

  # Data Table
  fluidRow(column(12,
                  DT::dataTableOutput("metadata_pretty"))),

  # Plots
  ## Sojourn Density Plot
  fluidRow(column(12,
                  tabsetPanel(
        id = "conditional_display",
        type = "hidden",
        tabPanelBody(
          "user_instruction",
          paste(
            "Select a row of the metadata to view the",
            "sojourn density for the selected parameter set,",
            "and the heatmaps for a subsequently selected",
            "replicate within that parameter set."
          )
        ),
        tabPanelBody(
          "sojourn_density",
          pickerInput(
            inputId = "replicate_selection",
            label = "Replicate",
            choices = NULL
          ),
          plotOutput("sojournDensityPlot"),
          plotOutput("heatmapPopulationOne"),
          plotOutput("heatmapPopulationTwo")
        )
      )))
)

shinyApp(ui, server)

library(ComplexHeatmap)
library(DBI)
library(DT)
library(RSQLite)
library(circlize)
library(shiny)
library(shinyWidgets)
library(tidyverse)

options(shiny.reactlog = TRUE)
ht_opt$message <- FALSE

db <- dbConnect(RSQLite::SQLite(), "/run/media/brycecarson/Data/APCD/MeeCarsonYeaman2021-12-28T21:54.db")
metadata <- dbReadTable(db, "metadata")
# DataTable cannot render blob objects, so we need to ensure that we deselect
# them before rendering.
metadata_pretty <- metadata %>% select(
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
  aprange <- c(-0.5, 0, 0.5)
  breaks <- sort(c(aprange, (max(aprange) + offset), 1, max(cdrange)))
  colors <- c("Purple", "White", "Orange", "White", "White", "Black")
  matrixColours <- circlize::colorRamp2(breaks, colors)
  splitChromosomes <- if (windowSize == 1) {
    rep(paste0("Chr ", letters[1:10]), 100) %>% sort()
  } else {
    rep(paste0("Chr ", letters[1:10]), 10) %>% sort()
  }
  return(Heatmap(matrix,
    cluster_columns = FALSE, cluster_rows = FALSE, col = matrixColours, show_heatmap_legend = TRUE, show_column_names = TRUE, use_raster = TRUE, split = splitChromosomes, gap = unit(3, "mm"), border = TRUE,
    heatmap_legend_param = list(
      at = breaks,
      labels = c("-0.5", "0", "0.5", "NIL", "1", as.character(max(cdrange)))
    )
  ))
}

server <- function(input, output, session) {
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
      base
    }
  })

  output$heatmapPopulationOne <- renderPlot({
    return(heatmapList()[[1]] %>% makeAComplexHeatmap())
  })
  output$heatmapPopulationTwo <- renderPlot({
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
      ## print("Returned value from database query is not a raw / connection that can be unserialized.")
      ## print(glue("Class of sojournDensityList_rawCxn: {class(sojournDensityList_rawCxn)}"))
    }
  })

  heatmapList <- reactive({
    # Requirements
    req(input$replicate_selection)

    # SQLite query
    # Must be a single filename
    heatmap_List <- dbGetQuery(db, "SELECT heatmapList FROM heatmaps WHERE filename IS :filename",
      params = list(filename = input$replicate_selection)
    )$heatmapList[[1]] %>% unserialize()
    return(heatmap_List)
  })

  ##### RENDERED UI
  output$replicate_selection_rendered <- renderUI({
    tagList(
      pickerInput(
        inputId = "replicate_selection",
        label = "Replicate",
        choices = NULL
      )
    )
  })

  ##### EVENT OBSERVATIONS
  ## FIXME: the first row selection does not properly update the
  ## replicate_selection input widget, and it remains empty until a second
  ## selection is made.
  ## NOTE: non-solution: This might be fixed by using a freezeReactiveValue call on the widget so
  ## that it is properly invalidated whenever a row selection event is detected,
  ## including the first.
  observeEvent(input$metadata_pretty_rows_selected,
    {
      if (!is.null(input$metadata_pretty_rows_selected)) {

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

        updateTabsetPanel(
          inputId = "conditional_display",
          selected = "sojourn_density"
        )
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
          plotOutput("sojournDensityPlot"),
          uiOutput("replicate_selection_rendered"),
          column(6, plotOutput("heatmapPopulationOne")),
          column(6, plotOutput("heatmapPopulationTwo"))
        )
      )))
)

shinyApp(ui, server)

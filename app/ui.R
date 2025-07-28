# Define UI for application

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  theme = shinytheme("flatly"),

  navbarPage(
    title = "FunBioDiv dataset explorer",
    collapsible = TRUE,
    fluid = TRUE,

    tabPanel(
      title = "Dataset",

      sidebarLayout(
        sidebarPanel = sidebarPanel(
          selectInput(
            "filter1",
            "Filter 1:",
            choices = names(choices),
            selected = "none"
          ),
          uiOutput('inSub1'),
          uiOutput('inFilter2'),
          uiOutput('inSub2'),
          uiOutput('inFilter3'),
          uiOutput('inSub3')
        ),

        mainPanel = mainPanel(
          leafletOutput("mapMeta"),
          h5(
            "Locations of fields are approximated to the nearest 0.1 degree and jittered to safeguard privacy."
          ),
          DT::DTOutput('tableMeta'),
        )
      ),
    ),
    tabPanel(
      title = "About",
      htmltools::includeMarkdown("about.md"),
    ),
  )
))

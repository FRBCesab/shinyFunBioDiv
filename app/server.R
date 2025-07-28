shinyServer(function(input, output, session) {
  #close the session when the app closes
  session$onSessionEnded(stopApp)

  # DATASET : Sidebar filters
  output$inSub1 <- renderUI({
    req(input$filter1)
    if (input$filter1 != "none") {
      list1 <- choices[[input$filter1]]
      if (grepl("Resp_", input$filter1)) {
        list1 <- c("any", list1)
      }
      selectInput('sub1', input$filter1, list1)
    }
  })

  output$inFilter2 <- renderUI({
    req(input$filter1)
    if (input$filter1 != "none") {
      selectInput('filter2', "Filter 2:", names(choices), selected = "none")
    }
  })

  output$inSub2 <- renderUI({
    req(input$filter2)
    if (input$filter2 != "none") {
      list2 <- choices[[input$filter2]]
      # remove already chosen options
      list2 <- list2[list2 != input$sub1 | list2 %in% covchoices]
      # add any for Resp variables
      if (grepl("Resp_", input$filter2)) {
        list2 <- c("any", list2)
      }
      selectInput('sub2', input$filter2, list2)
    }
  })

  output$inFilter3 <- renderUI({
    req(input$filter2)
    if (input$filter2 != "none") {
      selectInput('filter3', "Filter 3:", names(choices), selected = "none")
    }
  })

  output$inSub3 <- renderUI({
    req(input$filter3)
    if (input$filter3 != "none") {
      list3 <- choices[[input$filter3]]
      # remove already chosen options
      list3 <- list3[
        !list3 %in% c(input$sub1, input$sub2) | list3 %in% covchoices
      ]
      # add any for Resp variables
      if (grepl("Resp_", input$filter3)) {
        list3 <- c("any", list3)
      }
      selectInput('sub3', input$filter3, list3)
    }
  })

  # FILTER DATA
  metaInput <- reactive({
    sel <- rep(TRUE, nrow(meta))
    if (input$filter1 != "none" & !is.null(input$sub1)) {
      if (input$sub1 == "any") {
        sel1 <- meta[, input$filter1] != ""
      } else {
        sel1 <- grepl(input$sub1, meta[, input$filter1])
      }
      sel <- sel & sel1

      if (input$filter2 != "none" & !is.null(input$sub2)) {
        if (input$sub2 == "any") {
          sel2 <- meta[, input$filter2] != ""
        } else {
          sel2 <- grepl(input$sub2, meta[, input$filter2])
        }
        sel <- sel & sel2

        if (input$filter3 != "none" & !is.null(input$sub3)) {
          if (input$sub3 == "any") {
            sel3 <- meta[, input$filter3] != ""
          } else {
            sel3 <- grepl(input$sub3, meta[, input$filter3])
          }
          sel <- sel & sel3
        }
      }
    }
    return(meta[sel, ])
  })

  # DATASET : Main panel
  output$tableMeta <- DT::renderDT({
    DT::datatable(
      metaInput(),
      rownames = FALSE
    )
  })

  output$mapMeta <- renderLeaflet({
    leaflet() |>
      addTiles(
        options = providerTileOptions(minZoom = 3, maxZoom = 10)
      ) |>
      setView(
        mean(bounds[c(1, 3)]),
        mean(bounds[c(2, 4)]),
        zoom = 5
      )
  })

  observe({
    # in_shp <- shpInput()
    selected <- metaInput()
    in_shp <- shp[shp$Study_ID %in% selected$Study_ID, ]

    #if (nrow(in_shp)) {
    # set text for the clickable popup labels
    shp_popup <- paste0(
      "<strong>Study_ID: ",
      in_shp$Study_ID,
      "</strong><br>Type: ",
      in_shp$Type,
      "<br> Diversification: ",
      in_shp$Diversif,
      "<br> Resp. pest: ",
      in_shp$Resp_pest,
      "<br> Resp. NE: ",
      in_shp$Resp_NE,
      "<br> Crop type: ",
      in_shp$Crop_type
    )

    leafletProxy("mapMeta", data = in_shp) |>
      clearMarkers() |>
      clearControls() |>
      addCircleMarkers(
        data = in_shp,
        fillColor = ~ stablePal(Study_ID),
        fillOpacity = 0.8,
        color = ~ stablePal(Study_ID),
        weight = 1,
        popup = shp_popup
      ) |>
      addLegend(
        labels = sort(unique(in_shp$Study_ID)),
        position = "bottomleft",
        color = stablePal(sort(unique(in_shp$Study_ID)))
      )
    #addLegend(pal = pal, values = ~Study_ID, position = "bottomleft")

    #clearShapes() %>%
    #}
  })
})

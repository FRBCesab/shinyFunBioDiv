shinyServer(function(input, output, session) {
  #close the session when the app closes
  session$onSessionEnded(stopApp)

  # DATASET : Sidebar filters
  output$inSub1 <- renderUI({
    req(input$filter1)
    if (input$filter1 != "none") {
      if (input$filter1 == "Ag_practices") {
        list1 <- ag_choices
      } else {
        list1 <- var_choices
      }
      selectInput('sub1', input$filter1, list1)
    }
  })

  output$inFilter2 <- renderUI({
    req(input$filter1)
    if (input$filter1 != "none") {
      selectInput('filter2', "Filter 2:", choices = choices, selected = "none")
    }
  })

  output$inSub2 <- renderUI({
    req(input$filter2)
    if (input$filter2 != "none") {
      if (input$filter2 == "Ag_practices") {
        list2 <- ag_choices
      } else {
        list2 <- var_choices
      }
      # remove already chosen options
      list2 <- list2[list2 != input$sub1]
      selectInput('sub2', input$filter2, list2)
    }
  })

  output$inFilter3 <- renderUI({
    req(input$filter2)
    if (input$filter2 != "none") {
      selectInput('filter3', "Filter 3:", choices = choices, selected = "none")
    }
  })

  output$inSub3 <- renderUI({
    req(input$filter3)
    if (input$filter3 != "none") {
      if (input$filter3 == "Ag_practices") {
        list3 <- ag_choices
      } else {
        list3 <- var_choices
      }
      # remove already chosen options
      list3 <- list3[!list3 %in% c(input$sub1, input$sub2)]
      selectInput('sub3', input$filter3, list3)
    }
  })

  # FILTER DATA
  metaInput <- reactive({
    sel <- rep(TRUE, nrow(meta))
    if (input$filter1 != "none" & !is.null(input$sub1)) {
      sel1 <- grepl(input$sub1, meta[, input$filter1])
      sel <- sel & sel1

      if (input$filter2 != "none" & !is.null(input$sub2)) {
        sel2 <- grepl(input$sub2, meta[, input$filter2])
        sel <- sel & sel2

        if (input$filter3 != "none" & !is.null(input$sub3)) {
          sel3 <- grepl(input$sub3, meta[, input$filter3])
          sel <- sel & sel3
        }
      }
    }
    return(meta[sel, ])
  })

  # DATASET : Main panel
  output$tableMeta <- renderDT({
    DT::datatable(
      metaInput(),
      rownames = FALSE
    )
  })

  output$mapMeta <- renderLeaflet({
    leaflet() |>
      addTiles() |>
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
      "<br> Resp. variables: ",
      in_shp$Resp_var,
      "<br> Ag. Practices: ",
      in_shp$Practice
    )

    leafletProxy("mapMeta", data = in_shp) %>%
      clearShapes() %>%
      addPolygons(
        data = in_shp,
        fillColor = ~ pal(Study_ID),
        fillOpacity = 0.8,
        color = "#BDBDC3",
        weight = 2,
        popup = shp_popup
      )
    #}
  })
})

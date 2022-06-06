
mapPage_Server <- function(id) {
    
    
    moduleServer(
        id, 
        function(input, output, session) {
            
            ns <- session$ns
            
            # Reactives ---------------------------------------------------------------
            
            currentLocationIndex <- reactiveVal(g_startingIndex)
            
            isFirstLocation <- reactive({
                return(currentLocationIndex() == 1)
            })
            
            isLastLocation <- reactive({
                return(currentLocationIndex() == nrow(locationData()))
            })
            
            
            locationData <- reactive({
                data <- g_Locations
                
                colnames(data) <- c("Name", "Lat", "Long", "Description", "Image", "Sort.Order")
                
                data <- data %>%
                    arrange(Sort.Order)
                
                return(data)
            })
            
            currentLocationData <- reactive({
                req(locationData())
                
                dat <- locationData() %>%
                    filter(Sort.Order == currentLocationIndex())
                
                return(dat)
            })
            
            
            currentPostcard <- reactive({
                req(currentLocationData())
                
                image <- currentLocationData()$Image
                return(image)        
            })
            
            
            currentDescription <- reactive({
                req(currentLocationData())
                
                desc <- currentLocationData()$Description
                return(desc)
            })
            
            
            # UI Controls -------------------------------------------------------------
            
            
            output$page <- renderUI({
                div(class = "page-content-container", 
                    fluidRow(
                        div(class = "col-12 col-xl-7",
                            div(class = "map-container",
                                leafletOutput(ns("map"), height = "100%")
                            )  
                        ),
                        div(class = "col-12 col-xl-5",
                            uiOutput(ns("postcards"))    
                        )
                    )    
                )
            })
            
            
            output$postcards <- renderUI({
                div(class = "postcard-container",
                    div(
                      uiOutput(ns("postcardFront")),
                      uiOutput(ns("postcardBack")),
                      div(id = "scrollLocator", class = "map-scroll-locator")
                    ),
                    uiOutput(ns("mapControls"))
                )
            })
            
            
            output$postcardFront <- renderUI({
                div(class = "postcard-front",
                    div(class = "postcard-sizing", style = paste0("background-image: URL('img/postcards/", currentPostcard(), "');") 
                    )
                )
            })
            
            output$postcardBack <- renderUI({
                
                div(class = "postcard-back",
                    div(class = "postcard-sizing",
                        fluidRow(
                            div(class = "col-12 col-xl-8",
                                div(class = "postcard-text",
                                    HTML(paste0("<div>", currentDescription(), "</div>"))    
                                )    
                            ),
                            div(class = "col-12 col-xl-4",
                                div(class = "postcard-details",
                                    tags$img(src = "img/stamp_SVG.svg"),
                                    div(class = "postcard-lines")
                                )    
                            )
                        )
                    )
                )
            })
            
            output$mapControls <- renderUI({
                
                div(class = "map-controls-container",
                    uiOutput(ns("mapControlPrev")),
                    uiOutput(ns("mapControlNext"))
                )
            })
            
            output$mapControlPrev <- renderUI({
                actionLink(class = 'map-control-link prev hide', ns("back"), 
                           tags$img(src = "img/back.png")
                )
            })
            
            output$mapControlNext <- renderUI({
                actionLink(class = 'map-control-link next', ns("forward"), 
                           tags$img(src = "img/next.png")
                )
            })
            
            output$mapControlRestart <- renderUI({
                actionLink(class = 'map-control-link restart', ns("restart"), 
                           tags$span(
                               tags$img(src = "img/restart.png"),
                               tags$text("Restart")
                           )
                )
            })
            

            
            # Map logic ---------------------------------------------------------------
            
            
            output$map <- renderLeaflet({
                req(locationData())
                
                current <- isolate(currentLocationData())
                
                initString <- "true"
                positionString <- paste0("[", current$Lat, ", ", current$Long, "]")
                jsString <- paste0("updateCarPosition(", initString, ", ", positionString, ", ", g_carSpeedMS, ");")
                
                map <- leaflet(
                    options = leafletOptions(
                        minZoom = 5,
                        maxZoom = 8,
                        dragging = F
                    )
                ) %>%
                  setView(lng = current$Long, lat = current$Lat, zoom = 6) %>%
                    addTiles() %>%
                    registerPlugin(g_movingMarkerPlugin) %>%
                    addMarkers(group = "locations", data = locationData(), 
                               lat = ~Lat, lng = ~Long, icon = g_locationIcon,
                               options = list(zIndexOffset = 0, interactive = F)) %>%
                    addPolylines(
                        group = "routes",
                        data = locationData(),
                        lat = ~Lat,
                        lng = ~Long,
                        color = "#444",
                        opacity = 1,
                        weight = 2,
                        options = list(
                            dashArray = '10, 10'
                        )
                    ) %>%
                    onRender(
                        # Set a JS variable for later access
                        paste0(
                            "function(el, x) {
                        map = this;",
                        jsString, 
                        "}" 
                        )
                    )
                
                return(map)
            })
            
            
            
            observeEvent(input$back, {
                
                if(isLastLocation()) {
                    removeUI(paste0("#", ns("mapControlRestart")))
                    insertUI(
                        selector = ".map-controls-container",
                        where = "beforeEnd",
                        uiOutput(ns("mapControlNext"))
                    )
                }
                
                if(currentLocationIndex() > 1) {
                    
                    nextIndex <- currentLocationIndex() - 1
                    
                    currentLng <- locationData()[currentLocationIndex(), ]$Long
                    nextLng <- locationData()[nextIndex, ]$Long
                    
                    direction <- ifelse(currentLng > nextLng, "left", "right")
                    
                    currentLocationIndex(nextIndex)
                    
                    updateStaticCarPosition(F, isolate(currentLocationData()), g_carSpeedMS, direction)
                }
            })
            
            observeEvent(input$forward, {
                if(currentLocationIndex() < nrow(locationData())) {
                    
                    nextIndex <- currentLocationIndex() + 1
                    
                    currentLng <- locationData()[currentLocationIndex(), ]$Long
                    nextLng <- locationData()[nextIndex, ]$Long
                    
                    direction <- ifelse(currentLng > nextLng, "left", "right")
                    
                    currentLocationIndex(nextIndex)
                    
                    updateStaticCarPosition(F, isolate(currentLocationData()), g_carSpeedMS, direction)
                }
            })
            
            
            observeEvent(isFirstLocation(), {
                
                selector <- paste0("$('.map-control-link.prev')")
                if(isFirstLocation()) {
                    shinyjs::runjs(paste0(selector, ".addClass('hide');"))
                }
                else {
                    shinyjs::runjs(paste0(selector, ".removeClass('hide');"))
                }
            }, ignoreInit = T, ignoreNULL = T)
            
            
            
            observeEvent(isLastLocation(), {
                
                if(isLastLocation()) {
                    removeUI(paste0("#", ns("mapControlNext")))
                    insertUI(
                        selector = ".map-controls-container",
                        where = "beforeEnd",
                        uiOutput(ns("mapControlRestart"))
                    )
                }
            }, ignoreInit = T, ignoreNULL = T)
            
            
            
            observeEvent(input$restart, {
              if(currentLocationIndex() != 1) {
                nextIndex <- 1
                
                currentLng <- locationData()[currentLocationIndex(), ]$Long
                nextLng <- locationData()[nextIndex, ]$Long
                
                direction <- "left"
                
                currentLocationIndex(nextIndex)
                
                updateStaticCarPosition(F, isolate(currentLocationData()), 0, direction)
                
                removeUI(paste0("#", ns("mapControlRestart")))
                insertUI(
                    selector = ".map-controls-container",
                    where = "beforeEnd",
                    uiOutput(ns("mapControlNext"))
                )
              }
            })
            
            updateStaticCarPosition <- function(init = F, current, speed, direction) {
                
                initString <- ifelse(init, "true", "false")
                positionString <- paste0("[", current$Lat, ", ", current$Long, "]")
                jsString <- paste0("updateCarPosition(", initString, ", ", positionString, ", ", speed, ", '", direction, "');")
                
                shinyjs::runjs(jsString)
            }
        }
    )
}
    
    
    
    
    
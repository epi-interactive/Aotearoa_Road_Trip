

# Load required libraries -------------------------------------------------


library(shiny)
library(shinyjs)
library(shiny.router)
library(leaflet)
library(htmltools)
library(htmlwidgets)
library(dplyr)

# Source page UI / server logic -------------------------------------------


source("source/pages/splashPage_UI.R")
source("source/pages/splashPage_Server.R")
source("source/pages/mapPage_UI.R")
source("source/pages/mapPage_Server.R")


# Register leaflet plugin for moving markers ------------------------------


registerPlugin <- function(map, plugin) {
    map$dependencies <- c(map$dependencies, list(plugin))
    return(map)
}

g_movingMarkerPlugin <- htmlDependency(
    "Leaflet.MovingMarker", "1.0.0",
    src = normalizePath("./www/js"),
    script = "MovingMarker.js"
)


# Load location data from CSV ---------------------------------------------


g_Locations <- read.csv("data/locations.csv",
                        encoding = "UTF-8"
                )


# Constant global values --------------------------------------------------


g_locationIcon <- makeIcon(
    iconUrl = "img/cross.png",
    class = "map-cross",
    # iconAnchorX = 12, 
    # iconAnchorY = 10
)

g_carSpeedMS <- 1500

g_carIcon <- makeIcon(
    iconUrl = "img/car.png",
    iconWidth = 50
)

# Starting position of the car on the map
g_startingIndex <- 1


# UI Elements / app structure ---------------------------------------------


g_header <- function() {
    tags$header(
        div(class = "header-bar top"),
        div(class = "header-content-container ",
            div(class = "header-item",
                tags$span(class = "header-tag", "Summer 2021/22")
            ),
            div(class = "header-item",
                tags$a(href=route_link("home"),
                  tags$img(id = "title", src = "img/aotearoa-road-trip.png")
                )
            ),
            div(class = "header-item",
                tags$a(href = "https://www.epi-interactive.com/", target="_blank",
                  tags$img(id = "epi-logo", src = "img/Epi_Logo_HZ_Solid_RGB.svg")
                )
            )
        ),
        div(class = "header-bar btm")
    )
}

routes <- c(
    route("home", splashPage_UI("splash")),
    route("map", mapPage_UI("map"))
)

router <- make_router(routes)


# -------------------------------------------------------------------------





server <- function(input, output, session) {
    
    splashPage_Server("splash")
    mapPage_Server("map")

    
    observeEvent(get_page(), {
        shinyjs::runjs('window.scrollTo(0,0);')
    })
    
        
    router$server(input, output, session)
}
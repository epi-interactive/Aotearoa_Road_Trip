splashPage_Server <- function(id) {
  
    splashHeader <- "Join us on a road trip across New Zealand!"
    splashText <- "We'll start off at the bottom of the South Island and explore our beautiful islands from there."
    splashInstructions <- "Simply click on the yellow arrows to move around and make your way up north.<br><br><i>Kia pai te haere</i>, have a good journey"
  
    
    splashButton <- renderUI({
      div(class = "splash-route-container",
          tags$a(href=route_link("map"),
                 tags$img(src = "img/start-button.png")
          ),
      )
    })
  
    moduleServer(
        id,
        function(input, output, session) {
            
            ns <- session$ns
            
            
            output$page <- renderUI({
              
                div(class = "page-content-container", 
                  fluidRow(
                        div(class = "col-12 offset-md-2 col-md-8 offset-xl-0 col-xl-6",
                            
                            div(class = "splash-container",
                              
                                # Header
                              h1(
                                class = "splash-header",
                                HTML(splashHeader)
                              ),
                              
                              # Text
                              div(
                                class = "splash-text",
                                HTML(splashText)
                              ), 
                              br(),
                              
                              # Instructions
                              div(
                                class = "splash-text",
                                HTML(splashInstructions) 
                              ),
                              
                              # Button
                              div(
                                class = "splash-button-wrap",
                                splashButton                                
                              )

                              
                              
                              
                            )
                        )
                      )
                )
              
            })
            
        }
    )
}
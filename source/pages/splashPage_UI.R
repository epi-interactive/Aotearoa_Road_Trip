
splashPage_UI <- function(id) {
    
    ns <- NS(id)
    
    bootstrapPage(
        div(class = "page-container",
            div(class = "background-container",
                div(class="animation-container"),
                div(class = "splash-background-additions"),
                div(class = "splash-background-car-mobile"),
                div(class = "content-container",
                    g_header(),
                    HTML("<main>"),
                    uiOutput(ns("page")),
                    HTML("</main>")
                ) 
            )
        )
    )
}
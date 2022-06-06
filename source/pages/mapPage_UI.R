
mapPage_UI <- function(id) {
    ns <- NS(id)
        div(class = "page-container",
            div(class= "background-container",
                div(class="animation-container"),
                div(class = "content-container",
                    g_header(),
                    HTML("<main>"),
                    uiOutput(ns("page")),
                    HTML("</main>")
                ) 
            )
        
        )
}
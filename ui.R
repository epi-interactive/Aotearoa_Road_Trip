
bootstrapPage(
    theme = bslib::bs_theme(version = 4),
    tagList(
        tags$head(
            useShinyjs(),
            tags$title("Aotearoa Road Trip"),
            tags$link(rel = "shortcut icon", href = "img/favicon.ico"),
            tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Cabin:ital,wght@0,400;0,500;0,600;0,700;1,400;1,600;1,700&display=swap"),
            HTML(
              '<link rel="stylesheet" href="https://use.typekit.net/gco7mrk.css">'             
            ),
            HTML(
                '<link href="https://fonts.googleapis.com/css2?family=Cabin:ital,wght@0,400;0,500;0,600;0,700;1,400;1,600;1,700&display=swap" rel="stylesheet">'
            ),
            tags$link(rel = "stylesheet", type = "text/css", href = "css/main.css"),
            tags$link(rel = "stylesheet", type = "text/css", href = "css/responsive.css"),
            tags$script(src = "js/main.js")
        )
    ),
    router$ui
)
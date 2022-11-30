#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)
library(htmltools)
source("jscode.R")

# Define UI for application that draws a histogram
ui <- fluidPage(

  #Use JS
  useShinyjs(),
  #Load functions from jscode
  extendShinyjs(text = jscode,
                functions = c("cert","sendBtn")),
  #UI
  titlePanel("Reprex"),
  actionButton("cert","Sign In"),
  textInput("to","To","0xe0ab6916048ee208154bd76f1343d84b726fa62a"),
  textInput("value","Value","0"),
  textInput("data","Data","0x06fdde03"),
  actionButton("sendBtn","Send Transaction"),

  #Add Connex Dependency
  htmltools::htmlDependency(
    name = "connex",
    version = "2.0.11",
    src = c(file = "connex.min.js",
            href = "https://unpkg.com/@vechain/connex@2.0.11/dist/"),
    package = "connex",
    script = "connex.min.js",
    all_files = TRUE
  )

)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  #Observe action button for sign-in
  observeEvent(input$cert, {
    #cert function from jscode
    js$cert()
  })

  #Observe action button for sendBtn
  observeEvent(input$sendBtn,{

    #Build transaction
    df<-
      data.frame(
        to= input$to,
        value= input$value,
        data= input$data
      )
    #Send transaction to JS
    session$sendCustomMessage(type='myCallbackHandler', jsonlite::toJSON(df))
    #Send Comments to JS
    session$sendCustomMessage(type='myCallbackHandler_comments', "Reprex")
    # Fire Wallet
    js$sendBtn()
  })

}

# Run the application
shinyApp(ui = ui, server = server)

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
library(tidyverse)
library(httr2)
source("jscode.R")

# Function to get Tx Receipt
confirmTxID<-function(txid){

  request(paste0("https://node.vechain.energy/transactions/",txid,"/receipt")) %>%
    req_method("GET") %>%
    req_perform() %>%
    resp_body_json(simplifyVector = T) %>%
    pluck("reverted")

}

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
  textOutput("user_address"),
  textInput("to","To","0xe0ab6916048ee208154bd76f1343d84b726fa62a"),
  textInput("value","Value","0"),
  textInput("data","Data","0x06fdde03"),
  actionButton("sendBtn","Send Transaction"),
  textOutput("tx_receipt"),


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
    js$cert('Please identify yourself')

  })

  # Get user address from JS
  observeEvent(input$r_address, {

    output$user_address<-renderText(paste0("Signed as ", input$r_address))
   })

  
  observeEvent(input$sendBtn,{

    #Build transaction
    df<-
      data.frame(
        to= input$to,
        value= input$value,
        data= input$data,
        comment= "optional clause comment"
      )

    # send transaction
    js$sendBtn(jsonlite::toJSON(df))
  })

# Loop to get Tx Receipt when no longer NULL or quit after time limit
  observeEvent(input$r_result,{

    receipt<-NULL
    i=0

      while((is.null(receipt)) && (i<20)){
        
        Sys.sleep(1)
        receipt<- confirmTxID(input$r_result$txid)
        i=i+1
       
      }

    output$tx_receipt<-renderText(input$r_result$txid)

  })

}

# Run the application
shinyApp(ui = ui, server = server)

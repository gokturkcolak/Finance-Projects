# Load required libraries
library(shiny)
library(tidyverse)
library(dplyr)
library(readr)
library(TTR)

# Define the UI
ui <- fluidPage(
  titlePanel("Cryptocurrency Data Analysis"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload CSV File", accept = ".csv"),
      actionButton("analyze", "Analyze Data")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Adjusted Close", plotOutput("adjusted_close_plot")),
        tabPanel("Daily Returns", plotOutput("daily_returns_plot")),
        tabPanel("Moving Averages", plotOutput("moving_avg_plot")),
        tabPanel("Volume", plotOutput("volume_plot")),
        tabPanel("Rolling Volatility", plotOutput("rolling_volatility_plot")),
        tabPanel("Combined Indicators", plotOutput("combined_plot"))
      )
    )
  )
)

# Define the server logic
server <- function(input, output) {
  observeEvent(input$analyze, {
    req(input$file)
    
    # Read uploaded CSV file
    data <- tryCatch({
      read.csv(input$file$datapath, skip = 2)
    }, error = function(e) {
      stop("Error reading the file. Ensure it is a valid CSV file.")
    })
    
    # Ensure the correct column names
    colnames(data) <- c("Date", "Adj_Close", "Close", "High", "Low", "Open", "Volume")
    
    # Convert Date column to Date type
    data$Date <- as.Date(data$Date, format = "%Y-%m-%d")
    
    # Verify the structure of the data
    str(data)
    head(data)
    
    # Check for Missing Data
    summary(data)
    
    # Adjusted Closing Prices Over Time
    output$adjusted_close_plot <- renderPlot({
      ggplot(data, aes(x = Date, y = Adj_Close)) +
        geom_line(color = "blue", size = 1) +
        labs(
          title = "Adjusted Closing Prices",
          x = "Date",
          y = "Adjusted Close Price (USD)"
        ) +
        theme_minimal()
    })
    
    # Calculate and Plot Daily Log Returns
    data$Daily_Return <- c(NA, diff(log(data$Adj_Close)))
    output$daily_returns_plot <- renderPlot({
      ggplot(data[-1, ], aes(x = Date, y = Daily_Return)) +
        geom_line(color = "green", size = 1) +
        labs(
          title = "Daily Returns (Log)",
          x = "Date",
          y = "Log Return"
        ) +
        theme_minimal()
    })
    
    # Calculate Moving Averages
    data$SMA_50 <- SMA(data$Adj_Close, n = 50)
    data$SMA_200 <- SMA(data$Adj_Close, n = 200)
    output$moving_avg_plot <- renderPlot({
      ggplot(data, aes(x = Date)) +
        geom_line(aes(y = Adj_Close, color = "Adjusted Close"), size = 1) +
        geom_line(aes(y = SMA_50, color = "50-Day SMA"), size = 1, linetype = "dashed") +
        geom_line(aes(y = SMA_200, color = "200-Day SMA"), size = 1, linetype = "dotted") +
        labs(
          title = "Price with Moving Averages",
          x = "Date",
          y = "Price (USD)"
        ) +
        scale_color_manual(
          values = c("Adjusted Close" = "blue", "50-Day SMA" = "orange", "200-Day SMA" = "red")
        ) +
        theme_minimal()
    })
    
    # Plot Volume
    output$volume_plot <- renderPlot({
      ggplot(data, aes(x = Date, y = Volume)) +
        geom_bar(stat = "identity", fill = "steelblue") +
        labs(
          title = "Trading Volume",
          x = "Date",
          y = "Volume"
        ) +
        theme_minimal()
    })
    
    # Calculate and Plot Rolling Volatility
    data$Rolling_Volatility <- runSD(data$Adj_Close, n = 30)
    output$rolling_volatility_plot <- renderPlot({
      ggplot(data, aes(x = Date, y = Rolling_Volatility)) +
        geom_line(color = "purple", size = 1) +
        labs(
          title = "30-Day Rolling Volatility",
          x = "Date",
          y = "Volatility"
        ) +
        theme_minimal()
    })
    
    # Combine Multiple Indicators
    output$combined_plot <- renderPlot({
      ggplot(data, aes(x = Date)) +
        geom_line(aes(y = Adj_Close, color = "Adjusted Close"), size = 1) +
        geom_line(aes(y = SMA_50, color = "50-Day SMA"), linetype = "dashed") +
        geom_line(aes(y = SMA_200, color = "200-Day SMA"), linetype = "dotted") +
        geom_bar(aes(y = Volume / max(Volume) * max(Adj_Close), fill = "Volume"), stat = "identity", alpha = 0.3) +
        geom_line(aes(y = Rolling_Volatility * 10, color = "30-Day Rolling Volatility"), size = 1, linetype = "solid") +
        labs(
          title = "Price, Moving Averages, Volume, and Volatility",
          x = "Date",
          y = "Price (USD)"
        ) +
        scale_color_manual(
          values = c("Adjusted Close" = "blue", 
                     "50-Day SMA" = "orange", 
                     "200-Day SMA" = "red", 
                     "30-Day Rolling Volatility" = "purple")
        ) +
        scale_fill_manual(values = c("Volume" = "steelblue")) +
        theme_minimal() +
        theme(legend.position = "top")
    })
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)

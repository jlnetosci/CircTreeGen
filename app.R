library(shiny)
library(ggplot2)
library(ggforce)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectInput("n", "Select number of circles:", choices = 2:20, selected = 5),
      downloadButton("downloadPDF", "Save as PDF"),
      downloadButton("downloadSVG", "Save as SVG"),
      selectInput("size", "Select plot size:",
                  choices = c("Square" = "square", "A4" = "a4", "Letter" = "letter"))
      
    ),
    mainPanel(
      tags$div(style = "display: flex; align-items: center; justify-content: center; height: 600px;", plotOutput("plot", width = "600px", height = "600px"))
    )
  )
)

server <- function(input, output) {
  
  get_segments <- function(n) {
    segments_list <- list()
    for (i in 2:n) {
      if (i==2) {
        theta <- seq(0, 2*pi, length.out = 3)[-1]
      } else {
        theta <- seq(0, 2*pi, length.out = 2^(i-1)+1)[-1]
      }
      df_segment <- data.frame(x = (i-1)*cos(theta), y = (i-1)*sin(theta), xend = i*cos(theta), yend = i*sin(theta), r = rep(i,2^(i-2)))
      segments_list[[i-1]] <- df_segment
    }
    return(segments_list)
  }
  
  output$plot <- renderPlot({
    n <- input$n
    segments_list <- get_segments(n)
    df_circles <- data.frame(x = rep(0,n), y = rep(0,n), r = 1:n)
    df_segments <- do.call(rbind,segments_list)
    ggplot() +
      geom_circle(data = df_circles, aes(x0 = x, y0 = y, r = r), color = "black") +
      geom_segment(data = df_segments, aes(x = x, y = y, xend = xend, yend = yend)) +
      coord_equal() +
      theme_void()
    
  })
  
  output$downloadPDF <- downloadHandler(
    filename = "plot.pdf",
    content = function(file) {
      if (input$size == "square") {
        ggsave(file, plot = last_plot(), width = 20, height = 20, units = "cm", device = "pdf")
      }
      if (input$size == "a4") {
        ggsave(file, plot = last_plot(), width = 21, height = 29.7, units = "cm", device = "pdf")
      }
      if (input$size == "letter") {
        ggsave(file, plot = last_plot(), width = 21.6, height = 27.9, units = "cm", device = "pdf")
      }
    }
  )
  
  output$downloadSVG <- downloadHandler(
    filename = "plot.svg",
    content = function(file) {
      if (input$size == "square") {
        ggsave(file, plot = last_plot(), width = 20, height = 20, units = "cm", device = "svg")
      }
      if (input$size == "a4") {
        ggsave(file, plot = last_plot(), width = 21, height = 29.7, units = "cm", device = "svg")
      }
      if (input$size == "letter") {
        ggsave(file, plot = last_plot(), width = 21.6, height = 27.9, units = "cm", device = "svg")
      }
    }
  )
}

shinyApp(ui, server)

library(shiny)
library(ggplot2)
library(ggforce)

#### FUNCTIONS ####
get_circles <- function(n) {
  if (n<=3) {
    df_circles <- data.frame(x = rep(0,n), y = rep(0,n), r = c(1:n))
  } else {
    df_circles <- data.frame(x = rep(0,n), y = rep(0,n), r = c(1, 2, 3, sqrt(1.8)^((5:(as.numeric(n)+1)))))
  }
  return(df_circles)
}

get_segments <- function(n) {
  df_circles <- get_circles(n)
  segments_list <- list()
  for (i in 2:n) {
    if (i==2) {
      theta <- seq(0, 2*pi, length.out = 3)[-1]
    } else {
      theta <- seq(0, 2*pi, length.out = 2^(i-1)+1)[-1]
    }
    df_segment <- data.frame(x = (df_circles$r[i-1])*cos(theta), y = (df_circles$r[i-1])*sin(theta), xend = (df_circles$r[i])*cos(theta), yend = (df_circles$r[i])*sin(theta), r = rep(i,2^(i-2)))
    segments_list[[i-1]] <- df_segment
  }
  return(segments_list)
}

#### UI ####
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectInput("n", "Select number of circles:", choices = 2:15, selected = 5),
      selectInput("size", "Select plot size:",
                  choices = c("Square" = "square", "A4" = "a4", "Letter" = "letter")),
      downloadButton("downloadPDF", "Save as PDF"),
      downloadButton("downloadSVG", "Save as SVG")
    ),
    mainPanel(
      tags$div(style = "display: flex; align-items: center; justify-content: center; height: 600px;", plotOutput("plot", width = "600px", height = "600px"))
    )
  )
)

#### SERVER ####
server <- function(input, output) {
  
  output$plot <- renderPlot({
    n <- input$n
    df_circles <- get_circles(n)
    segments_list <- get_segments(n)
    df_segments <- do.call(rbind,segments_list)
    ggplot() +
      geom_circle(data = df_circles, aes(x0 = x, y0 = y, r = r), color = "black") +
      geom_segment(data = df_segments, aes(x = x, y = y, xend = xend, yend = yend)) +
      scale_x_continuous(expand = c(0, 0)) +
      scale_y_continuous(expand = c(0, 0)) +
      coord_equal() +
      theme_classic()
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
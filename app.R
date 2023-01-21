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
  h3("Circular Family Tree"),
  h4("Printable Template Generator"),
  sidebarLayout(
    sidebarPanel(
      selectInput("n", "Number of generations:", choices = 2:15, selected = 5),
      selectInput("display", "Display:", choices = c("Circle" = "circle", "Half circle" = "half", "Quarter circle" = "quarter"), selected = "circle"),
      selectInput("size", "Export size:",
                  choices = c("Square (100 × 100 cm)" = "square", "A4 landscape (29.7 × 21 cm)" = "a4", "Letter landscape (27.9 × 21.6 cm)" = "letter")),
      downloadButton("downloadPDF", "Save as PDF"),
      downloadButton("downloadSVG", "Save as SVG"),
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
    
    if (input$display == "circle") {
      ggplot() +
        geom_circle(data = df_circles, aes(x0 = x, y0 = y, r = r), color = "black") +
        geom_segment(data = df_segments, aes(x = x, y = y, xend = xend, yend = yend)) +
        scale_x_continuous(expand = c(0, 0)) +
        scale_y_continuous(expand = c(0, 0)) +
        coord_equal() +
        theme_void()
    } else if (input$display == "half") {
      ggplot() +
        geom_circle(data = df_circles, aes(x0 = x, y0 = y, r = r), color = "black") +
        geom_segment(data = df_segments, aes(x = x, y = y, xend = xend, yend = yend)) +
        scale_x_continuous(expand = c(0, 0)) +
        scale_y_continuous(expand = c(0, 0)) +
        coord_fixed(ylim = c(-0, max(df_segments$yend))) +
        #coord_equal() +
        #geom_hline(yintercept = 0, linetype = "dotted") +
        theme_void()
    } else if (input$display == "quarter") {
      ggplot() +
        geom_circle(data = df_circles, aes(x0 = x, y0 = y, r = r), color = "black") +
        geom_segment(data = df_segments, aes(x = x, y = y, xend = xend, yend = yend)) +
        scale_x_continuous(expand = c(0, 0)) +
        scale_y_continuous(expand = c(0, 0)) +
        coord_fixed(xlim = c(0, max(df_segments$xend)), ylim = c(0, max(df_segments$yend))) +
        #coord_equal() +
        #geom_hline(yintercept = 0, linetype = "dotted") +
        theme_void()
    }
  })
  
  output$downloadPDF <- downloadHandler(
    filename = "plot.pdf",
    content = function(file) {
      if (input$size == "square") {
        ggsave(file, plot = last_plot(), width = 100, height = 100, units = "cm", device = "pdf")
      }
      if (input$size == "a4") {
        ggsave(file, plot = last_plot(), width = 29.7, height = 21, units = "cm", device = "pdf")
      }
      if (input$size == "letter") {
        ggsave(file, plot = last_plot(), width = 27.9, height = 21.6, units = "cm", device = "pdf")
      }
    }
  )
  
  output$downloadSVG <- downloadHandler(
    filename = "plot.svg",
    content = function(file) {
      if (input$size == "square") {
        ggsave(file, plot = last_plot(), width = 100, height = 100, units = "cm", device = "svg")
      }
      if (input$size == "a4") {
        ggsave(file, plot = last_plot(), width = 29.7, height = 21, units = "cm", device = "svg")
      }
      if (input$size == "letter") {
        ggsave(file, plot = last_plot(), width = 27.9, height = 21.6, units = "cm", device = "svg")
      }
    }
  )
}

shinyApp(ui, server)

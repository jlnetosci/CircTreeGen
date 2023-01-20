library(ggplot2)
library(ggforce)

get_circles <- function(n) {
  df_circles <- data.frame(x = rep(0,n), y = rep(0,n), r = rep(1:n))
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

df_circles <- get_circles(10)
segments_list <- get_segments(10)
df_segments <- do.call(rbind,segments_list)

ggplot() +
  geom_circle(data = df_circles, aes(x0 = x, y0 = y, r = r), color = "black") +
  geom_segment(data = df_segments, aes(x = x, y = y, xend = xend, yend = yend)) +
  theme_void()

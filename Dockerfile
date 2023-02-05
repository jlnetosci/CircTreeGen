FROM rocker/shiny-verse:4.1.1
COPY app.R /app/
RUN R -e "install.packages('ggforce')"
EXPOSE 3838
CMD ["R", "-e", "shiny::runApp('/app/app.R', port=3838, host='0.0.0.0')"]
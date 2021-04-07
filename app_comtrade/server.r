library('shiny')
library('dplyr')
library('data.table')
library('RCurl')
library('ggplot2')
library('lattice')
library('zoo')
library('lubridate')

df <- read.csv('data.csv', header = T, sep = ',')

df <- data.table(df)
df <- df[df$Netweight..kg. < 200000, ]

shinyServer(function(input, output){
  DT <- reactive({
    DT <- df[between(Year, input$year.range[1], input$year.range[2]) &
               Commodity.Code == input$sp.to.plot & Trade.Flow == input$trade.to.plot, ]
    DT <- data.table(DT)
  })
  output$sp.ggplot <- renderPlot({
    ggplot(data = DT(), aes(x = Countries, y = Netweight..kg., group = Countries, color = Countries)) +
      geom_boxplot() +
      scale_color_manual(values = c('red', 'blue', 'green', 'yellow'),
                         name = 'Группы стран-поставщиков:')+
      labs(title = 'Коробчатые диаграммы суммарной массы поставок',
           x = 'Страны', y = 'Масса')
  })
})
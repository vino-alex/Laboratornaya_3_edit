library('shiny')
library('RCurl')

df <- read.csv('./data.csv', header = TRUE, sep = ',')

filter.trade.flow <- as.character(unique(df$Trade.Flow))
names(filter.trade.flow) <- filter.trade.flow
filter.trade.flow <- as.list(filter.trade.flow)

shinyUI(
  pageWithSidebar(
    headerPanel("График разброса Netweight..kg. относительно Trade.Value..US.."),
    sidebarPanel(
      # Выбор кода продукции
      selectInput('sp.to.plot',
                  'Выберите код продукта',
                  list('Рыба; живая (0301)' = '301',
                       'Рыба; свежая, охлажденная (0302)' = '302',
                       'Рыба; замороженная (0303)' = '303',
                       'Рыбное филе и прочая рыба (0304)' = '304',
                       'Рыба; сушеная, соленая, копченая (0305)' = '305'),
                  selected = '301'),
      # Выбор экпорт/импорт
      selectInput('trade.to.plot',
                  'Выберите товарный поток:',
                  filter.trade.flow),
      # Период, по годам
      sliderInput('year.range', 'Период, по годам:',
                  min = 2010, max = 2020, value = c(2010, 2020),
                  width = '100%', sep = '')
    ),
    mainPanel(
      plotOutput('sp.ggplot')
    )
  )
)
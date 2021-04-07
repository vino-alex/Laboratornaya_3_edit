library('shiny')               # создание интерактивных приложений
library('lattice')             # графики lattice
library('data.table')          # работаем с объектами "таблица данных"
library('ggplot2')             # графики ggplot2
library('dplyr')               # трансформации данных
library('lubridate')           # работа с датами, ceiling_date()
library('zoo')                 # работа с датами, as.yearmon()

# функция, реализующая API (источник: UN COMTRADE)
source("https://raw.githubusercontent.com/aksyuk/R-data/master/API/comtrade_API.R")

# Получаем данные с UN COMTRADE за период 2010-2020 года, по 03 коду
products_code = c('0301', '0302', '0303', '0304', '0305')
df = data.frame()
for (code in products_code){
  print(code)
  for (year in 2010:2020){
    Sys.sleep(5)
    s1 <- get.Comtrade(r = 'all', p = 643,
                       ps = as.character(year), freq = "M",
                       cc = code, fmt = 'csv')
    df <- rbind(df, s1$data)
    print(year)
  }
}

data.dir <- './data'

# Создаем директорию для данных
if (!file.exists(data.dir)) {
  dir.create(data.dir)
}

# Сохраняем данные в csv файл
file.name <- paste('./data/un_comtrade.csv', sep = '')
write.csv(df, file.name, row.names = FALSE)

write(paste('Файл',
            paste('un_comtrade.csv', sep = ''),
            'загружен', Sys.time()), file = './data/download.log', append=TRUE)


df <- read.csv('./data/un_comtrade.csv', header = T, sep = ',')
df <- df[, c(2, 4, 8, 10, 22, 30, 32)]

df <- df[!is.na(df$Netweight..kg.) & !is.na(df$Trade.Value..US..), ]
df

usa <- 'United States of America'
eu <- 'EU-28'
latin_america <- c('Argentina', 'Brazil', 'Bolivia', 'Belize', 'Venezuela', 'Haiti', 
                   'Guatemala', 'Honduras', 'Dominica', 'Dominican Rep.', 'Colombia',
                   'Costa Rica', 'Cuba', 'Mexico', 'Nicaragua', 'Panama', 'Paraguay',
                   'Peru', 'EI Salvador', 'Uruguay', 'Chile', 'Ecuador')

new.df <- data.frame()
new.df <- rbind(new.df, cbind(df[df$Reporter == usa, ], data.frame(Countries = 'USA')))
new.df <- rbind(new.df, cbind(df[df$Reporter == eu, ], data.frame(Countries = 'EU')))
new.df <- rbind(new.df, cbind(df[df$Reporter %in% latin_america, ], data.frame(Countries = 'Latin America')))
new.df <- rbind(new.df, cbind(df[!(df$Reporter == usa) & !(df$Reporter == eu) & !(df$Reporter %in% latin_america), ],
                              data.frame(Countries = 'Other countries')))
new.df

# Код продукции
filter.code <- as.character(unique(df$Commodity.Code))
names(filter.code) <- filter.code
filter.code <- as.list(filter.code)
filter.code

# Товарный поток
filter.trade.flow <- as.character(unique(df$Trade.Flow))
names(filter.trade.flow) <- filter.trade.flow
filter.trade.flow <- as.list(filter.trade.flow)
filter.trade.flow

file.name <- paste('./data/data.csv', sep = '')
write.csv(new.df, file.name, row.names = FALSE)

df <- read.csv('./data/data.csv', header = T, sep = ',')
df

df.filter <- df[df$Commodity.Code == filter.code[1] & df$Trade.Flow == filter.trade.flow[1], ]
df.filter

df.filter <- df.filter[df.filter$Netweight..kg. < 6000000, ]

ggplot(data = df.filter, aes(x = Countries, y = Netweight..kg., group = Countries, color = Countries)) +
  geom_boxplot() +
  scale_color_manual(values = c('red', 'blue', 'green', 'yellow'),
                     name = 'Группы стран-поставщиков:')+
  labs(title = 'Коробчатые диаграммы суммарной массы поставок',
       x = 'Страны', y = 'Масса')

# Запуск приложения
runApp('./app_comtrade', launch.browser = TRUE,
       display.mode = 'showcase')

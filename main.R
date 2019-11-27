install.packages('httr')
library(httr)
install.packages('rjson')
library(rjson)
ACCESS_TOKEN <- '517eaca4517eaca4517eaca4d55110931f5517e517eaca40ca01e7693ef4566435f380a'


datasets_url <- 'https://api.vk.com/method/database.getCities?country_id=RU&need_all=1&count=1000&access_token=ACCESS_TOKEN&v=V'
datasets_url <- paste0(datasets_url, ACCESS_TOKEN)
response <- GET(datasets_url)



library(vkR)
library(httr)
library(rjson)
library(tidyr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(lintr)

#Авторизация для получения API key
vkOAuth(7225265, "photos")

#Полученный ключ нужно вставить ниже
api_key <- ""

#Создание базы для функционирования тела проекта
#В первой строке можно добавить другие паблики
#Код написан для любого количества пабликов
domains <- c("ru9gag", "fckbrain", "dank_memes_ayylmao")
publics <- c(1:length(domains))
publics <- rbind(publics, domains)
publics <- t(publics)
colnames(publics)[1] <- ("Number")
colnames(publics)[2] <- ("Domain")
table_final <- data.frame(matrix(ncol = 7, nrow = 0))
colnames(table_final) <- c("public_name", "owner_id", "id_num", "likes_num", "reposts_num", "views_num", "members")
urls <- data.frame(matrix(ncol = 1, nrow = 0))
colnames(urls) <- c("Url")
members <- data.frame(matrix(ncol = 1, nrow = 0))
colnames(members) <- c("Members")

#Первый запрос к API для получения количества подписчиков по группам
for (row in 1:nrow(publics)) {
  adress <- publics[row, 2]
  ssilka1 <- "https://api.vk.com/method/groups.getById?group_id="
  ssilka2 <- "&fields=members_count&v=5.103&access_token="
  ssilka <- as.data.frame(paste0("https://vk.com/", ssilka1, "?w=wall", ssilka2, "_", api_key))
  api_call_for_members <- paste0(ssilka1, adress, ssilka2, api_key)
  response_members <- GET(url = api_call_for_members)
  parsed_con_members <- response_members[6]
  parsed_members2 <- content(response_members, as = "text")
  parsed_final_members <- fromJSON(parsed_members2)
  members_num <- as.data.frame(parsed_final_members$response$members_count)
  members <- rbind(members, members_num)
}
colnames(members) <- c("Members")



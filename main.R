library(vkR)
library(httr)
library(rjson)
library(tidyr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(lintr)

#Avtorizacia dlya poluchenia API key
vkOAuth(7225265, "photos")

#Poluchenniy kluch nuzhno vstavit nizhe
api_key <- ""

#Sozdanie bazi dlya raboti ciklov
#V pervoy stroke mozhno dobavit novie publiki ili zamenit starie
#Kod napisal dlya lubogo kolichestva publikov
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

#Perviy zapros k API dlya poluchenia kolichestva podpischikov
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

#Vtoroy zapros k API dly poluchenia postov i informacii po nim
for (row in 1:nrow(publics)) {
  adress <- publics[row, 2]
  members <- members[row, 1]
  api_call <- "https://api.vk.com/method/wall.get?domain="
  api_call_2 <- "&extended=1&count=25&v=5.103&access_token="
  api_call <- paste0(api_call, adress, api_call_2, api_key)
  response <- GET(url = api_call)
  parsed_con <- response[[6]]
  parsed2 <- content(response, as = 'text')
  parsed_final <- fromJSON(parsed2)
  likes <- as.data.frame(parsed_final$response$items$likes$count)
  reposts <- as.data.frame(parsed_final$response$items$reposts$count)
  views <- as.data.frame(parsed_final$response$items$views)
  id <- as.data.frame(parsed_final$response$items$id)
  owner_id <- as.data.frame((parsed_final$response$items$owner_id))
  public_name <- as.data.frame(replicate(25, adress))
  members_count <- as.data.frame(replicate(25, members))
  table_final_pr <- bind_cols(public_name, owner_id, id, likes, reposts, views, members_count)
  table_final <- rbind.data.frame(table_final, table_final_pr)
}
colnames(table_final) <- c("public_name", "owner_id", "id_num", "likes_num", "reposts_num", "views_num", "members")

#Sozdanie ssilok na posti
for (row in 1:nrow(table_final)) {
  ssilka1 <- table_final[row, 1]
  ssilka2 <- table_final[row, 2]
  ssilka3 <- table_final[row, 3]
  ssilka <- as.data.frame(paste0("https://vk.com/", ssilka1, "?w=wall", ssilka2, "_", ssilka3))
  urls <- rbind.data.frame(urls, ssilka)
}
colnames(urls) <- c("Url") 
AHAHAMEMES <- bind_cols(table_final, urls)

#10 naibolee zalaikanih postov
Memes_Likes <- arrange(AHAHAMEMES, desc(AHAHAMEMES$likes_num))
Memes_Likes <- head(Memes_Likes, 10)         

#10 postov kotorimi delilis chashe vsego
Memes_Reposts <- arrange(AHAHAMEMES, desc(AHAHAMEMES$reposts_num))
Memes_Reposts <- head(Memes_Reposts, 10)

#10 luchshih postov po sootnosheniu laiki/kov-vo podpischikov
dushi <- within(AHAHAMEMES, podush <- likes_num / members)
dushi <- arrange(dushi, desc(dushi$podush))
dushi <- head(dushi, 10)

#10 luchshih postov po sootnosheniu laiki/prosmotri
prosm <- within(AHAHAMEMES, poprosm <- likes_num / views_num)
prosm <- arrange(prosm, desc(prosm$poprosm))
prosm <- head(prosm, 10)

#Visualization 1
ggplot(AHAHAMEMES, aes(x = public_name, y = likes_num, col = reposts_num)) +
  geom_point() + geom_jitter(width = 0.15, height = 0) + 
  labs(title = "Суммарная статистика постов по пабликам")

#Vizualization 2
ggplot(mapping = aes(x = likes_num, y = views_num, col = public_name)) + 
  geom_point(data = AHAHAMEMES) + 
  labs(title = "Соотношение просмотров и лайков для разных пабликов")
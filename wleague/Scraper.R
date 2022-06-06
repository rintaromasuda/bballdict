library(dplyr)
library(stringr)
library(rvest)
library(tidyverse)

df_result <- data.frame()

htmlRoot <- "https://www.wjbl.org"
teamListUrl <- "https://www.wjbl.org/team/list_html/"
teamListHtml <- read_html(teamListUrl)

teamHrefs <- teamListHtml %>%
  rvest::html_nodes("#team_list > div > div > div.function_button.c > ul.clear > li:nth-child(1) > a") %>%
  rvest::html_attr("href")

for(teamHref in teamHrefs) {
  teamUrl <- paste0(htmlRoot, teamHref)

  print(paste("Team URL ->", teamUrl))

  teamHtml <- read_html(teamUrl)

  playerHrefs <- teamHtml %>%
    rvest::html_nodes("#team-roster_contents > div:nth-child(2) > div.team-color-table > table > tr > td:nth-child(2) > a") %>%
    rvest::html_attr("href")

  for(playerHref in playerHrefs) {
    playerUrl <- paste0(htmlRoot, playerHref)

    print(paste("Player URL ->", playerUrl))

    playerHtml <- read_html(playerUrl)

    playerNameElement <- playerHtml %>%
      rvest::html_nodes("#player_details > div > div > div.player_name > h3 > em:nth-child(1)") %>%
      rvest::html_text()

    playerNameElement <- str_replace_all(playerNameElement, " ", "")
    playerNameElement <- str_replace_all(playerNameElement, "　", "")

    playerName <- stringr::str_split(playerNameElement, "\n")

    print(paste0(playerName[[1]][1],":", playerName[[1]][2]))

    df_row <- data.frame(
      Reading = playerName[[1]][2],
      Word = playerName[[1]][1]
    )

    df_result <- rbind(df_result, df_row)
  }
}

write.table(df_result, file = "WLeaguePlayerNameDict_202122_CSV_UTF8_RawData.csv", quote = FALSE, row.names = FALSE, col.names = FALSE, sep = ",", fileEncoding = "UTF-8")

df_tsv <- df_result
df_tsv$PoS <- "人名"

write.table(df_tsv, file = "WLeaguePlayerNameDict_202122_TSV_UTF8.csv", quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t", fileEncoding = "UTF-8")


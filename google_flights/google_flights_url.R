#!/usr/bin/env Rscript

# library(RSelenium)
# library(dplyr)

# args <- commandArgs(trailingOnly = TRUE)
# # args <- c("São Paulo", "Natal")
# 
# if (length(args) != 2) {
#     stop(
#         "\n\nDigite o local de partida e o destino.\n",
#         "\t\t Ex: Rscript google_flights.R \"São Paulo\"",
#         " \"Natal\" \n\n"
#         )
# }
# 
# remDr <- remoteDriver(
#     remoteServerAddr = "localhost",
#     port = 4445L,
#     browserName = "firefox"
# )
# # remDr$closeall()
# 
# remDr$open()
# 
# # não está funcionando! Porque?
# # remDr$setImplicitWaitTimeout(milliseconds = 10000)
# # remDr$setTimeout(milliseconds = 10000)
# 
# remDr$navigate("https://www.google.com/flights/")
# # remDr$close()
# 
# # De ---------------------------------------------------------
# webDe <- remDr$findElement("xpath", "//span[@class='gws-flights-form__location-list']")
# # webDe$highlightElement()
# webDe$clickElement()
# 
# webDe <- remDr$findElement("xpath", "//div[@id='sb_ifc50']/input")
# # webDe$highlightElement()
# webDe$clearElement()
# webDe$sendKeysToElement(list(args[1]))
# webDe$sendKeysToElement(list(key = "enter"))
# 
# Sys.sleep(1)
# 
# # Para -------------------------------------------------------
# webPara <- remDr$findElement("xpath", "//span[@class='gws-flights-form__location-icon']")
# # webPara$highlightElement()
# webPara <- webPara$clickElement()
# 
# webPara <- remDr$findElement("xpath", "//div[@id='sb_ifc50']/input")
# # webPara$highlightElement()
# webPara$clearElement()
# webPara$sendKeysToElement(list(args[2]))
# webPara$sendKeysToElement(list(key = "enter"))
# 
# Sys.sleep(1)
# 
# # Ida-Volta --------------------------------------------------
# webIdaVolta <- remDr$findElement("xpath", "//span[@class='gws-flights-form__menu-label']")
# # webIdaVolta$highlightElement()
# webIdaVolta$clickElement()
# 
# webIdaVoltaMenu <- remDr$findElement("xpath", "//menu-item[@class='mSPnZKpnf91__menu-item flt-subhead2']")
# # webIdaVoltaMenu$highlightElement()
# webIdaVoltaMenu$clickElement()
# 
# Sys.sleep(1)
# 
# # Pesquisa ---------------------------------------------------
# webClick <- remDr$findElement("xpath", "//span[@class='gws-flights-fab__text']")
# # webClick$highlightElement()
# webClick$clickElement()
# 
# Sys.sleep(1)
# 
# # URL --------------------------------------------------------
# url <- remDr$getCurrentUrl()[[1]]

if (!dir.exists("~/databases")) {
    dir.create("~/databases")
}
setwd("~/databases")

if (!dir.exists("google_flights")) {
    dir.create("google_flights")
}
setwd("google_flights")

url <- data.frame(matrix(ncol = 6, nrow = 0), stringsAsFactors = FALSE)
colnames(url) <- c("id", "de", "para", "di", "df", "url")
write.csv2(url, row.names = FALSE, file = "url.csv")

# url <- gsub("[0-9]{4}-[0-9]{2}-[0-9]{2}", "9999-99-99", url)

# if (file.exists("urls.rds")) {
#     urls <- readRDS("urls.rds")
#     url <- unique(c(url, urls)) ## Add new url
# }

# saveRDS(url, "urls.rds")

# remDr$closeall()

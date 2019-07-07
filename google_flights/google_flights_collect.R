#!/usr/bin/env Rscript

library(RSelenium)
library(lubridate)

remDr <- remoteDriver(
    remoteServerAddr = "localhost",
    port = 4445L,
    browserName = "firefox"
)
# remDr$closeall()
remDr$open()

setwd("~/databases/google_flights")

# TODO
# Escolher local de PARTIDA e o DESTINO
setwd("saopaulo_natalnat")

url <- readRDS("url.rds")

hoje <- gsub("-", "_", Sys.Date())
dir.create(hoje)
setwd(hoje)

# TODO
# Flexibilizar o intervalo de compra das passagens
to <- seq.Date(as.Date("2019-10-05"), as.Date("2019-10-15"), by = 1)
url <- sapply(to, function(x) gsub("[0-9]{4}-[0-9]{2}-[0-9]{2}", x, url))

for (i in 1:length(url)) {
    remDr$navigate(url[i])
    Sys.sleep(1)
    h <- XML::htmlParse(remDr$getPageSource()[[1]])
    XML::saveXML(h, file = paste0(gsub("-", "_", to[i]), ".html"))
}
remDr$closeall()

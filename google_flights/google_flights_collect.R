#!/usr/bin/env Rscript

library(RSelenium)

remDr <- remoteDriver(
    remoteServerAddr = "localhost",
    port = 4445L,
    browserName = "firefox"
)

# remDr$closeall()
remDr$open()

setwd("~/databases/google_flights")

voo <- read.csv2("url.csv", stringsAsFactors = FALSE)

if (nrow(voo) == 0) stop("Sem informações de coleta, parando...")

hoje <- gsub("-", "_", Sys.Date())
dir.create(hoje)
setwd(hoje)

for (i in 1:nrow(voo)) {
    to <- seq.Date(as.Date(voo$di[i]), as.Date(voo$df[i]), by = 1)
    url <- sapply(to, function(x) gsub("[0-9]{4}-[0-9]{2}-[0-9]{2}", x, voo$url[i]))

    for (w in 1:length(url)) {
        remDr$navigate(url[w])
        Sys.sleep(1)
        h <- XML::htmlParse(remDr$getPageSource()[[1]])
        file <- paste0(gsub("-", "_", to[w]), "_", voo$id[i], ".html")
        XML::saveXML(h, file = file)
    }
}

remDr$closeall()

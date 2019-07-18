#!/usr/bin/env Rscript

library(tidyverse)

library(XML)
library(RSelenium)

library(RMySQL)

remDr <- remoteDriver(
    remoteServerAddr = "localhost",
    port = 4445L,
    browserName = "firefox"
)

# Abre um navegador
remDr$open()

url <- "https://www.superbid.net"

remDr$navigate(url)

# Parse da página
h <- htmlParse(remDr$getPageSource()[[1]], encoding = "utf-8")

h.cat <- getNodeSet(h, "//ul[@id='menuProdutoTipo']/li")

# Coleta cada URL de cada categoria/subcategoria
out <- lapply(h.cat, function(x) {
    h.sub.cat <- xmlDoc(x)

    tibble(
        categoria = xpathSApply(h.sub.cat, "//span[@class='desc']", xmlValue),
        subcategoria = xpathSApply(h.sub.cat, "//span[@class='name']", xmlValue),
        url = str_c(url, xpathSApply(h.sub.cat, "//a[@class='waves-effect']", xmlGetAttr, "href"))
    )    
})
out <- bind_rows(out)

# ID das categorias
out$cat <- str_extract(out$url, "[0-9]{5}$")

# Fecha navegador
remDr$close()

# Salva no banco de dados
con <- dbConnect(MySQL(), dbname = "superbid", host = "127.0.0.1")

dbWriteTable(con, "config", as.data.frame(out), row.names = FALSE, overwrite = TRUE)

dbDisconnect(con)


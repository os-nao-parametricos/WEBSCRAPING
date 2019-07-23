#!/usr/bin/env Rscript

library(RSelenium)
library(XML)

args <- commandArgs(trailingOnly = TRUE)

# Cria caminho se não existir
if (!dir.exists("~/databases")) {
    dir.create("~/databases")
}

if (!dir.exists("~/databases/google_flights")) {
    dir.create("~/databases/google_flights")
}

# Muda diretorio
setwd("~/databases/google_flights")

if (args == "config") {
    # Cria arquivo que é utilizado para coletar as viagens
    url <- data.frame(matrix(ncol = 6, nrow = 0), stringsAsFactors = FALSE)
    colnames(url) <- c("id", "de", "para", "di", "df", "url")
    write.csv2(url, row.names = FALSE, file = "url.csv")
    
} else if (args == "coleta") {
    
    remDr <- remoteDriver(
        remoteServerAddr = "localhost",
        port = 4445L,
        browserName = "firefox"
    )

    # remDr$closeall()
    remDr$open()
    
    if (!file.exists("url.csv")) {
        stop("Arquivo url.csv não existe.\n\nPor favor execute: \n\t\t $ Rscript google_flights.R url")
    }
    
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
} else if (args == "scrap") {
    # TODO
    # h <- htmlParse("2019_07_07/2019_10_06_1.html")
    # 
    # xpath <- "gws-flights-results__result-item gws-flights__flex-box gws-flights-results__collapsed"
    # h.sub <- getNodeSet(h, paste0("//li[@class='", xpath, "']"))
    # 
    # # Loop
    # v <- xmlDoc(h.sub[[1]])
    # 
    # # Preço ------------------------------------------------------
    # xpath <- "//div[@class='gws-flights-results__itinerary-price']"
    # preco <- xpathApply(v, xpath, xmlValue)
    # 
    # # De ---------------------------------------------------------
    # xpath <- "//div[@class='gws-flights-results__leg-arrival gws-flights__flex-box flt-subhead1Normal']"
    # de <- xpathApply(v, xpath, xmlValue)
    # 
    # # Para -------------------------------------------------------
    # xpath <- "//div[@class='gws-flights-results__leg-departure gws-flights__flex-box flt-subhead1Normal']"
    # para <- xpathApply(v, xpath, xmlValue)
    # 
    # # TME --------------------------------------------------------
    # xpath <- "//div[@class='gws-flights-results__leg-duration gws-flights__flex-box flt-body2']"
    # tme <- xpathApply()

} else {

    cat("\n\nNenhum argumento identificado.\nPor favor execute um dos três argumentos possiveis:\n\n",
        "\t\tconfig: para criar arquivo de configurações de coleta",
        "\n\t\tcoleta: para coletar os dados",
        "\n\t\tscrap: para raspar e tabular as informações coletadas",
        "\n\n\t\tExemplo:  $ Rscript google_flights coleta\n\n")
    
}

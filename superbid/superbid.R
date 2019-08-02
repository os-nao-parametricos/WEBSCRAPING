#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
args <- args[1]

# Bibliotecas
library(tidyverse)
library(lubridate)
library(RMySQL)
library(XML)

library(RSelenium)

# Muda diretorio ---------------------------------------------------------------
if (dir.exists("~/databases/superbid/")) {
    setwd("~/databases/superbid/")    
} else {
    if (args != "config") {
        stop("Primeiro deve-se executar: \n\t\t $ Rscript superbid.R config")
    }
}

if (args == "config") {
    # Cria diretório -----------------------------
    DIR <- "~/databases/superbid"
    if (!dir.exists(DIR)) dir.create(DIR)
    if (!dir.exists(paste0(DIR, "/data"))) dir.create(paste0(DIR, "/data"))
    if (!dir.exists(paste0(DIR, "/data"))) dir.create(paste0(DIR, "/order"))
    if (!dir.exists(paste0(DIR, "/img"))) dir.create(paste0(DIR, "/img"))

    # Coleta URL's da "API" ----------------------
    url <- "https://www.superbid.net"
    h <- httr::GET(url, httr::config(ssl_verifypeer = FALSE))

    # Parse da página
    h <- htmlParse(h, encoding = "utf-8")

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

    saveRDS(out, "config.RData")
    
} else if (args == "coleta") {

    remDr <- remoteDriver(
        remoteServerAddr = "localhost",
        port = 4445L,
        browserName = "firefox"
    )
    remDr$open()
    
    # Coleta URL's com a data de ONTEM
    f <- paste0("order/", Sys.Date() - 1, ".RData")

    if (file.exists(f)) {
        tb <- readRDS(f)
    } else {
        stop("Sem orders.")
    }

    if (nrow(tb) == 0) stop("Sem orders.")

    DIR <- paste0("data/", Sys.Date() - 1)
    dir.create(DIR)

    i <- which(tb$index==0)[1]
    for (i in i:nrow(tb)) {

        remDr$navigate(tb[i, "u"][[1]])
        Sys.sleep(2)
        
        # Precisa executar o js na página TODO
        # h <- httr::GET(tb[i, "u"][[1]], httr::config(ssl_verifypeer = FALSE))
        h <- remDr$getPageSource()[[1]]
        h <- htmlParse(h, encoding = "utf-8")
        
        xpath <- "//div[@class='gwt-Label corner2px lcd chronometer close']"
        status <- tolower(xpathSApply(h, xpath, xmlValue))
        # browseURL(tb[i, "u"][[1]])
        
        if (length(status) == 0) {
            tb[i, "index"] <- -1
            Sys.sleep(1)
            next
        } else {
            # Coleta imagens -----------------------------------------------------------
            img <- xpathSApply(h, "//div[@class='rsNavItem rsThumb']/img",
                               xmlGetAttr, "data-zoom-image")
            
            if (length(img) > 0) {
                if (is.list(img)) img <- do.call(c, img)
                img <- str_extract(img, ".+jpg|.+jpeg")
                dir.create(paste0("img/", tb[i, "id"][[1]]))
                for (m in 1:length(img))
                    download.file(img[m], paste0("img/", tb[i, "id"][[1]], "/", m, ".jpg"))
            }
            
            # Baixa html ---------------------------------------------------------------
            xml2::write_html(xml2::read_html(remDr$getPageSource()[[1]]),
                             paste0(DIR, "/", tb[i, "id"][[1]], ".html"))
            
            tb[i, "index"] <- 1
            saveRDS(tb, f)
            Sys.sleep(1)
        }
    }
    
} else if (args == "order") {
    config <- readRDS("config.RData")
    tb <- tibble()

    for (i in 1:nrow(config)) {
        url <- paste0(config$url[i], "&ord=pordata&size=100")

        h <- httr::GET(url, httr::config(ssl_verifypeer = FALSE))
        h <- htmlParse(h, encoding = "utf-8")

        dt <- xpathSApply(h, "//strong[@class='data']", xmlValue)
        if (length(dt) == 0) next
        dt <- dmy(str_extract(dt, "[0-9]{2}/[0-9]{2}/[0-9]{4}"))

        urls <- xpathSApply(h, "//div[@class='image-wrapper']/a[@class='link']",
                            xmlGetAttr, "href")
        urls <- paste0("https://www.superbid.net", urls)

        tb_new <- tibble(cat = config$cat[i], d = dt, u = urls) %>%
            mutate(cat = as.integer(cat),
                   id = as.integer(str_extract(u, "(?<=_id=)[0-9]+(?=&)"))) %>%
            distinct()

        tb <- bind_rows(tb, tb_new)
        cat(i, sep = "\n")
        Sys.sleep(1)
    }
    tb <- tb %>% distinct()
    tb$index <- 0

    ## Somente os fechamentos de hoje
    tb <- tb %>% filter(d == Sys.Date())
    cat("\n\n------------------------------------- FIM -------------------------------------")
    saveRDS(tb, paste0("order/", Sys.Date(), ".RData"))
    
} else if (args == "scrap") {
    
}

#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

# Funções ----------------------------------------
htmlParse2 <- function(url) {
    while (TRUE) {
        out <- try(htmlParse(httr::GET(url, httr::config(ssl_verifypeer = FALSE))), silent = TRUE)
        # out <- try(htmlParse(RCurl::getURL(url)), silent = TRUE)
        if (!("try-error" %in% class(out))) break
        Sys.sleep(1)
    }
    return(out)
}

suppressMessages(library(tidyverse))
library(parallel)
library(XML)

if (args[1] == "config") {
    cat("Criando pasta ~/databases/g1globo")

    if (!dir.exists("~/databases")) dir.create("~/databases")
    setwd("~/databases")
    if (!dir.exists("g1globo")) dir.create("g1globo")
    setwd("g1globo")

    cat("\n\n\tPronto.\n\n")

} else if (args[1] == "tudo") {
    f1 <- proc.time()[[3]]
    setwd("~/databases/g1globo/")
    cat("Configurações iniciais para paralelismo...\n\n ")
    
    nc <- detectCores()
    cl <- makeCluster(nc)
    
    clusterExport(cl, "htmlParse2")
    clusterEvalQ(cl, library(tidyverse))
    clusterEvalQ(cl, library(XML))

    cat("Inicia coleta de URL's...\n\n")
    all.links <- parLapply(cl, 1:2000, function(i) {
        url <- sprintf("https://g1.globo.com/index/feed/pagina-%s.ghtml", i)
        
        h <- htmlParse2(url)

        xpath <- str_c(
            "//div[@class='feed-post-body-title gui-color-primary ",
            "gui-color-hover ']//a"
        )

        links <- xpathSApply(h, xpath, xmlGetAttr, "href")
        links <- if (is.list(links)) do.call(c, links) else links

        links <- links[str_detect(links, "^https")]
        links <- links[str_detect(links, ".ghtml$|.html$")]
        links
    })

    stopCluster(cl)

    all.links <- do.call(c, all.links)
    all.links <- unique(all.links)

    cat("URL's coletadas.\nTotal: ", length(all.links),
        "\nTempo decorrido: ",  proc.time()[[3]] - f1, "\n\n")
    
    # length(all.links)
    f2 <- proc.time()[[3]]
    cat("Configurando raspagem dos links...\n\n")
    
    cl <- makeCluster(nc)
    clusterExport(cl, "htmlParse2")
    clusterEvalQ(cl, library(tidyverse))
    clusterEvalQ(cl, library(XML))
    
    conteudo <- parLapply(cl, all.links, function(link) {

        h.links <- htmlParse2(link)

        xpath.links <- c(
            # Titulo
            "//div[@class='title']",
            # Autor
            "//p[@class='content-publication-data__from']",
            # Data
            "//p/time",
            # Meta.titulo
            "//div[@class='medium-centered subtitle']",
            # Texto
            "//div[@class='mc-column content-text active-extra-styles ']",
            # Tags
            "//li[@class='entities__list-item']"
        )

        conteudo <- lapply(xpath.links, function(l) {
            out <- trimws(xpathSApply(h.links, l, xmlValue))
            if (length(out) == 0) return(NA) else out
        })
        
        # Corrige data para formato yyyy-mm-dd
        conteudo[[3]] <- lubridate::dmy(str_extract(conteudo[[3]], "[0-9]{2}/[0-9]{2}/[0-9]{4}"))
        # adiciona URL
        conteudo <- append(conteudo, link)
        conteudo[[5]] <- paste0(conteudo[[5]], collapse = " \n ")
        conteudo[[6]] <- paste0(conteudo[[6]], collapse = " - ")
        names(conteudo) <- c("titulo", "autor", "data", "metatitulo", "texto", "tags", "url")
        conteudo <- as_tibble(conteudo)
        conteudo
    })
    conteudo <- bind_rows(conteudo)

    # Remove noticias em que não foi coletado o texto
    # Em geral noticias relacionadas a FUTEBOL.
    conteudo <- conteudo %>% drop_na(titulo)
    
    # Remove emojis
    conteudo$texto <- gsub("[^[:cntrl:][:alnum:][:blank:]!\",.><()&/+-~{}^#:=@|]", "",
                           conteudo$texto)

    
    cat("Total de páginas raspadas: ", nrow(conteudo),
        "\nTotal de páginas não raspadas: ", length(all.links) - nrow(conteudo),
        "\nTempo decorrido: ", proc.time()[[3]] - f2,
        "\n\nExportando dados para data.RData")

    saveRDS(conteudo, "data.RData")

    cat("\n\nTotal de tempo decorrido: ",  proc.time()[[3]] - f1)
    
} else if (args[1] ==  "coleta") {
    cat("\n\n\n---------------------------------------- ",
        as.character(Sys.Date()),
        "----------------------------------------")
    # Coleta noticias do dia de ontem
    setwd("~/databases/g1globo/")

    all.links <- c()

    # Coleta notícias até a página 15.
    for (i in 1:15) {
        url <- sprintf("https://g1.globo.com/index/feed/pagina-%s.ghtml", i)
        # browseURL(url)
        
        h <- htmlParse2(url)

        xpath <- str_c(
            "//div[@class='feed-post-body-title gui-color-primary ",
            "gui-color-hover ']//a"
        )

        links <- xpathSApply(h, xpath, xmlGetAttr, "href")
        links <- if (is.list(links)) do.call(c, links) else links

        links <- links[str_detect(links, "^https")]
        links <- links[str_detect(links, ".ghtml$|.html$")]
        all.links <- c(all.links, links)
        # cat(i, sep = "\n")
        Sys.sleep(0.25)
    }

    all.links <- unique(all.links)
    cat("\n\nTotal de notícias: ",  length(all.links), '\n')

    conteudo <- lapply(all.links, function(link) {

        h.links <- htmlParse2(link)

        xpath.links <- c(
            # Titulo
            "//div[@class='title']",
            # Autor
            "//p[@class='content-publication-data__from']",
            # Data
            "//p/time",
            # Meta.titulo
            "//div[@class='medium-centered subtitle']",
            # Texto
            "//div[@class='mc-column content-text active-extra-styles ']",
            # Tags
            "//li[@class='entities__list-item']"
        )

        conteudo <- lapply(xpath.links, function(l) {
            out <- trimws(xpathSApply(h.links, l, xmlValue))
            if (length(out) == 0) return(NA) else out
        })
        
        # Corrige data para formato yyyy-mm-dd
        conteudo[[3]] <- lubridate::dmy(str_extract(conteudo[[3]], "[0-9]{2}/[0-9]{2}/[0-9]{4}"))
        # adiciona URL
        conteudo <- append(conteudo, link)
        conteudo[[5]] <- paste0(conteudo[[5]], collapse = " \n ")
        conteudo[[6]] <- paste0(conteudo[[6]], collapse = " - ")
        names(conteudo) <- c("titulo", "autor", "data", "metatitulo", "texto", "tags", "url")
        conteudo <- as_tibble(conteudo)
        conteudo
    })
    conteudo <- bind_rows(conteudo)

    # Remove emojis
    conteudo$texto <- gsub("[^[:cntrl:][:alnum:][:blank:]!\",.><()&/+-~{}^#:=@|]", "",
                           conteudo$texto)

    # Remove noticias em que não foi coletado o texto
    # Em geral noticias relacionadas a FUTEBOL.
    conteudo <- conteudo %>% drop_na(titulo)

    conteudo$texto[conteudo$texto == "NA"] <- NA
    conteudo$tags[conteudo$tags == "NA"] <- NA
    
    cat("\n\nTotal de páginas raspadas: ", nrow(conteudo),
        "\nTotal de páginas não raspadas: ", length(all.links) - nrow(conteudo),
        "\n\nExportando dados para ", as.character(Sys.Date()-1), ".RData")

    saveRDS(conteudo, paste0(Sys.Date() - 1, ".RData"))

    cat("\n\n\t\tPronto.\n\n\n")
    
} else if (args[1] == "mysql") {
    setwd("~/databases/g1globo/")
    library(RMySQL)
    con <- dbConnect(MySQL(), db = "webscraping")

    if (args[2] == "tudo") {
        df <- readRDS("data.RData")
        df$ID <- substring(str_replace_all(df$url, "[[:punct:]]", ""), 1, 150)
        dbWriteTable(con, "g1globo", df, row.names = FALSE, append = TRUE, overwrite = FALSE)
        info <- DBI::dbGetQuery(con, "show index from webscraping.g1globo where Key_name='PRIMARY'")
        if (nrow(info) == 0) {
            DBI::dbSendQuery(con, "alter table webscraping.g1globo modify ID varchar(150);")
            DBI::dbSendQuery(con, "alter table webscraping.g1globo add primary key (ID)")
        }
        dbDisconnect(con)
    }

    df <- readRDS(paste0(Sys.Date() - 1, ".RData"))
    df$ID <- substring(str_replace_all(df$url, "[[:punct:]]", ""), 1, 150)
    dbWriteTable(con, "g1globo", df, row.names = FALSE, append = TRUE, overwrite = FALSE)
    dbDisconnect(con)
}

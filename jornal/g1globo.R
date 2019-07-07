#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

htmlParse2 <- function(url) {
    while (TRUE) {
        out <- try(htmlParse(RCurl::getURL(url)), silent = TRUE)
        if (!("try-error" %in% class(out))) break
        Sys.sleep(1)
    }
    return(out)
}

coleta_noticias <- function(N) {
    i <- 1
    conteudo <- tibble()

    # Coleta noticias
    for (i in i:N) {
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


        conteudo2 <- lapply(links, function(link) {

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

            conteudo <- lapply(xpath.links, function(l) trimws(xpathSApply(h.links, l, xmlValue)))
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
        conteudo2 <- bind_rows(conteudo2)
        conteudo <- bind_rows(conteudo, conteudo2)
        # cat(i, sep = "\n")
    }

    # Remove emojis
    conteudo$texto <- gsub("[^[:cntrl:][:alnum:][:blank:]!\",.><()&/+-~{}^#:=@|]", "",
                           conteudo$texto)

    return(conteudo)
}

if (args[1] == "tudo" | args[1] == "hoje") {
    library(tidyverse)
    library(XML)
    library(RMySQL)
    
    N <- ifelse(args[1] == "tudo", 2001, 10)

    conteudo <- as_tibble(coleta_noticias(N))

    if (nrow(conteudo) == 0) stop("Nenhuma notícia coletada.")
    
    # Conexão com o banco
    con <- dbConnect(MySQL(), host = "127.0.0.1", dbname = "jornal")

    # Pega as últimas noticias da última semana
    conteudo.ult.dias <- dbSendQuery(con,
                                     paste0("SELECT * FROM g1globo WHERE data IN (",
                                            paste0("'", Sys.Date() - 1:5, "'",
                                                   collapse = ", "), ")",
                                            collapse = "")
                                     )
    conteudo.ult.dias <- dbFetch(conteudo.ult.dias)

    # Remove noticias já coletadas
    conteudo <- conteudo[!(conteudo$url %in% conteudo.ult.dias$url), ]
    
    dbWriteTable(con, "g1globo", conteudo, row.names = FALSE, append = TRUE, overwrite = FALSE)
    # DBI::dbGetQuery(con, "show variables like 'character_set_%'")
    # as_tibble(dbReadTable(con, "g1globo"))

    dbDisconnect(con)
    
} else {
    cat(
        paste0(
            "Erro!! Utilize um dos argumentos abaixo: \n\n",
            "tudo: para coletar todas as notícias disponíveis do G1.\n",
            "hoje: para coletar as notícias do dia de hoje."
        )
    )
}

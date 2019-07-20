#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

library(telegram)
library(RMySQL)

webscraping_log <- function(message) {
    setwd("~/")
    bot <- TGBot$new(token = bot_token("Webscraping"))
    bot$set_default_chat_id(user_id("me"))
    bot$sendMessage(message, parse_mode = "markdown")
}

if (length(args) == 0) stop("\n\nNenhum argumento foi passado, parando......\n\n")

for (i in 1:length(args)) {

    if (args[i] == "g1globo") {
        con <- dbConnect(MySQL(), dbname = "webscraping", host = "127.0.0.1")

        query <- paste0("'", Sys.Date() - 1:2, "'", collapse = ", ")
        query <- paste0("SELECT COUNT(*) FROM g1globo WHERE data IN (", query, ")")
        n <- dbSendQuery(con, query)
        n <- dbFetch(n)[[1]]

        dt <- format(Sys.Date(), "%d/%m/%Y")
        message <- paste0("*", dt ,"* - Total de noticías coletadas do *G1*: ", n)
        webscraping_log(message)
        
    } else if (args[i] == "google_flights") {
        dt <- format(Sys.Date(), "%d/%m/%Y")
        if (dir.exists(paste0("~/databases/google_flights/", gsub("-", "_", Sys.Date())))) {
            message <- paste0("*", dt, "* - As páginas de voo foram coletadas.")
            webscraping_log(message)
        } else {
            message <- paste0("*", dt, "* - Problemas na coleta das páginas de voo.")
            webscraping(message)
        }
        
    } else if (args[i] == "superbid") {
        
    } else if (args[i] == "crontab") {
        library(cronR)

        cron_rm(id = "telegram_webscraping")
        
        f <- "telegram.R"

        ## Add mais scripts AQUI
        cmd <- cron_rscript(f, rscript_args = c("jornal", "google_flights", "superbid"))
        cron_add(cmd, at = "10:00", id = "telegram_webscraping", tags =  "webscraping", 
                 description = "Informa status da coleta de dados.")
    } 
}



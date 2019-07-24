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
        if (file.exists(paste0("~/databases/superbid/order/", Sys.Date() - 1, ".RData"))) {
            superbid <- readRDS(paste0("~/databases/superbid/order/", Sys.Date() - 1, ".RData"))
            n1 <- (sum(superbid$index == 1)/nrow(superbid)) * 100
            n1t <- nrow(superbid)
        } else {
            n1 <- 0
        }

        if (file.exists(paste0("~/databases/superbid/order/", Sys.Date(), ".RData"))) {
            superbid2 <- readRDS(file.exists(paste0("~/databases/superbid/order/", Sys.Date(), ".RData")))
            n2 <- nrow(superbid2)
        } else {
            n2 <- 0
        }

        dt <- format(Sys.Date(), "%d/%m/%Y")
        message <- paste0("*", dt, "* - Superbid - Percentual de anúncios coletados: ",
                          n1, "% de um total de ", n1t, "\n Total de novos anúncios: ", n2)
        webscraping_log(message)        
    }
}



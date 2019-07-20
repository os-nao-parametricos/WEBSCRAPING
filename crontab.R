#!/usr/bin/env Rscript

library(cronR)

# Telegram
cron_rm(id = "telegram_webscraping1")
cron_rm(id = "telegram_webscraping2")
if (length(cron_ls(id = "telegram_webscraping1")) == 0 |
    length(cron_ls(id = "telegram_webscraping2")) == 0) {

    f <- "telegram.R"

    ## Add mais scripts AQUI
    ## IMPORTANT

    # Manha --------------------------------------
    args <- c("jornal", "google_flights")
    cmd <- cron_rscript(f, rscript_args = args)
    cron_add(cmd, at = "10:00", id = "telegram_webscraping1",
             tags =  "webscraping",
             description = "Informa status da coleta de dados.")

    # Noite --------------------------------------
    args <- c("superbid")
    cmd <- cron_rscript(f, rscript_args = args)
    cron_add(cmd, at = "21:00", id = "telegram_webscraping2",
             tags =  "webscraping",
             description = "Informa status da coleta de dados.")
} 

# ------------------------------------------------------------------------------

# g1globo.R
cron_rm(id = "g1globo")
if (length(cron_ls(id = "g1globo")) == 0) {
    f <- paste0(getwd(), "/g1globo/g1globo.R")

    cmd <- cron_rscript(f, rscript_args = "hoje")
    cron_add(cmd, at = "8:30", id = "g1globo", tags =  "webscraping", 
             description = "Coleta dados do site de notícias g1.globo")
} 

# google_flights
cron_rm(id = "google_flights")
if (length(cron_ls(id = "google_flights")) == 0) {
    f <- paste0(getwd(), "/google_flights/google_flights.R")

    cmd <- cron_rscript(f, rscript_args = "coleta")
    cron_add(cmd, at = "9:00", id = "googleflights", tags =  "webscraping", 
             description = "Coleta dados de voo do Google Flights.")
}

# superbid
cron_rm(id = "superbid1")
cron_rm(id = "superbid2")
if (length(cron_ls(id = "superbid")) == 0) {
    f <- paste0(getwd(), "/superbid/superbid.R")

    cmd <- cron_rscript(f, rscript_args = "url")
    cron_add(cmd, at = "8:00", id = "superbid1", tags =  "webscraping", 
             description = "Coleta dados do site de leião www.superbid.com.br")

    # cmd <- cron_rscript(f, rscript_args = "coleta")
    # cron_add(cmd, at = "20:00", id = "superbid2", tags =  "webscraping", 
    #          description = "Coleta dados do site de leião www.superbid.com.br")
}

#!/usr/bin/env Rscript

library(cronR)

# g1globo.R
if (length(cron_ls(id = "g1globo")) == 0) {
    f <- paste0(getwd(), "/g1globo/g1globo.R")

    cmd <- cron_rscript(f, rscript_args = "hoje")
    cron_add(cmd, at = "8:30", id = "g1globo", tags =  "webscraping", 
             description = "Coleta dados do site de notícias g1.globo")
} 

# google_flights
if (length(cron_ls(id = "google_flights")) == 0) {
    f <- paste0(getwd(), "/google_flights/google_flights.R")

    cmd <- cron_rscript(f, rscript_args = "coleta")
    cron_add(cmd, at = "9:00", id = "googleflights", tags =  "webscraping", 
             description = "Coleta dados de voo do Google Flights.")
}

# superbid
if (length(cron_ls(id = "superbid")) == 0) {
    f <- paste0(getwd(), "/superbid/??")

    cmd <- cron_rscript(f)
    cron_add(cmd, at = "9:10", id = "superbid", tags =  "webscraping", 
             description = "Coleta dados do site de leião www.superbid.com.br")
}

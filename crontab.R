#!/usr/bin/env Rscript

library(cronR)

# jornal/g1globo.R
if (length(cron_ls(id = "g1globo")) == 0) {
    f <- paste0(getwd(), "/jornal/g1globo.R")

    cmd <- cron_rscript(f, rscript_args = "hoje")
    cron_add(cmd, at = "8:30", id = "g1globo", tags =  "webscraping", 
             description = "Coleta dados do site de notícias g1.globo")
} else {
    cat("Crontab já está programado para disparar todos os dias as 8:30.\n\n\n")
}

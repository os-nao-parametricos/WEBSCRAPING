#!/usr/bin/env Rscript

library(cronR)

args <- commandArgs(trailingOnly = TRUE)


# ------------------------------------------------------------------------------

# if (args == "telegram") {
#     # Telegram
#     cron_rm(id = "telegram_webscraping_manha")
#     # cron_rm(id = "telegram_webscraping2")
#     if (length(cron_ls(id = "telegram_webscraping1")) == 0 |
#         length(cron_ls(id = "telegram_webscraping2")) == 0) {
# 
#         f <- "telegram.R"
# 
#         ## Add mais scripts AQUI
#         ## IMPORTANT
# 
#         # Manha --------------------------------------
#         args <- c("g1globo", "google_flights", "superbid")
#         cmd <- cron_rscript(f, rscript_args = args)
#         cron_add(cmd, at = "10:00", id = "telegram_webscraping_manha",
#                  tags =  "webscraping",
#                  description = "Informa status da coleta de dados.")
# 
#         # Noite --------------------------------------
#         # args <- c("superbid")
#         # cmd <- cron_rscript(f, rscript_args = args)
#         # cron_add(cmd, at = "21:00", id = "telegram_webscraping2",
#         #          tags =  "webscraping",
#         #          description = "Informa status da coleta de dados.")
#     }
# }


# ------------------------------------------------------------------------------

# Coleta dos dados =============================================================
# g1globo.R
if (args[1] == "g1globo") {
    cron_rm(id = "g1globo")
    f <- paste0(getwd(), "/g1globo/g1globo.R")

    cmd <- cron_rscript(f, rscript_args = "coleta")
    cron_add(cmd, at = "8:30", id = "g1globo", tags =  "webscraping", 
             description = "Coleta dados do site de notícias g1.globo")
}

# google_flights
if (args[1] == "google_flights") {
    cron_rm(id = "google_flights")
    f <- paste0(getwd(), "/google_flights/google_flights.R")

    cmd <- cron_rscript(f, rscript_args = "coleta")
    cron_add(cmd, at = "9:00", id = "googleflights", tags =  "webscraping", 
             description = "Coleta dados de voo do Google Flights.")
}

# superbid
if (args[1] == "superbid") {
    cron_rm(id = "superbid_order")
    cron_rm(id = "superbid_coleta")
    f <- paste0(getwd(), "/superbid/superbid.R")

    cmd <- cron_rscript(f, rscript_args = "order")
    cron_add(cmd, at = "8:00", id = "superbid_order", tags =  "webscraping", 
             description = "Coleta dados do site de leião www.superbid.com.br")

    cmd <- cron_rscript(f, rscript_args = "coleta")
    cron_add(cmd, at = "8:15", id = "superbid_coleta", tags =  "webscraping", 
             description = "Coleta dados do site de leião www.superbid.com.br")
}

# Banco de dados ===============================================================
# g1globo.R
if (args[1] == "g1globo_mysql") {
    cron_rm(id = "g1globo_mysql")
    f <- paste0(getwd(), "/g1globo/g1globo.R")

    cmd <- cron_rscript(f, rscript_args = "mysql")
    cron_add(cmd, at = "12:00", id = "g1globo_mysql",
             tags =  c("webscraping", "banco de dados"), 
             description = "Armazena notícias coletadas no banco de dados MySQL.")
}

#!/usr/bin/env Rscript

library(RSelenium)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)
# args <- c("São Paulo", "Natal")

if (length(args) != 2) {
    stop(
        "\n\nDigite o local de partida e o destino.\n",
        "\t\t Ex: Rscript google_flights.R \"São Paulo\"",
        " \"Natal\" \n\n"
        )
}

remDr <- remoteDriver(
    remoteServerAddr = "localhost",
    port = 4445L,
    browserName = "firefox"
)
# remDr$closeall()

remDr$open()

# não está funcionando! Porque?
# remDr$setImplicitWaitTimeout(milliseconds = 10000)
# remDr$setTimeout(milliseconds = 10000)

remDr$navigate("https://www.google.com/flights/")
# remDr$close()

# De ---------------------------------------------------------
webDe <- remDr$findElement("xpath", "//span[@class='gws-flights-form__location-list']")
# webDe$highlightElement()
webDe$clickElement()

webDe <- remDr$findElement("xpath", "//div[@id='sb_ifc50']/input")
# webDe$highlightElement()
webDe$clearElement()
webDe$sendKeysToElement(list(args[1]))
webDe$sendKeysToElement(list(key = "enter"))

Sys.sleep(1)

# Para -------------------------------------------------------
webPara <- remDr$findElement("xpath", "//span[@class='gws-flights-form__location-icon']")
# webPara$highlightElement()
webPara <- webPara$clickElement()

webPara <- remDr$findElement("xpath", "//div[@id='sb_ifc50']/input")
# webPara$highlightElement()
webPara$clearElement()
webPara$sendKeysToElement(list(args[2]))
webPara$sendKeysToElement(list(key = "enter"))

Sys.sleep(1)

# Ida-Volta --------------------------------------------------
webIdaVolta <- remDr$findElement("xpath", "//span[@class='gws-flights-form__menu-label']")
# webIdaVolta$highlightElement()
webIdaVolta$clickElement()

webIdaVoltaMenu <- remDr$findElement("xpath", "//menu-item[@class='mSPnZKpnf91__menu-item flt-subhead2']")
# webIdaVoltaMenu$highlightElement()
webIdaVoltaMenu$clickElement()

Sys.sleep(1)

# Pesquisa ---------------------------------------------------
webClick <- remDr$findElement("xpath", "//span[@class='gws-flights-fab__text']")
# webClick$highlightElement()
webClick$clickElement()

Sys.sleep(1)

# URL --------------------------------------------------------
url <- remDr$getCurrentUrl()[[1]]
if (file.exists("voo.rds")) {
    voo <- readRDS("voo.rds")
    novo_voo <- tibble(de = args[1], para = args[2], url = url)
    voo <- bind_rows(novo_voo, voo)
    voo <- voo %>% distinct()
    saveRDS(voo, "voo.rds")
} else {
    voo <- tibble(de = args[1], para = args[2], url = url)
    saveRDS(voo, "voo.rds")
}
remDr$closeall()

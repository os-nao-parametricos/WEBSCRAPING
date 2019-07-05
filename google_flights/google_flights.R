#!/usr/bin/env Rscript

library(RSelenium)

args <- commandArgs(trailingOnly = TRUE)

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

remDr$open()

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
Sys.sleep(2)
webDe$sendKeysToElement(list(key = "enter"))

# Para -------------------------------------------------------
webPara <- remDr$findElement("xpath", "//span[@class='gws-flights-form__location-icon']")
# webPara$highlightElement()
webPara <- webPara$clickElement()

webPara <- remDr$findElement("xpath", "//div[@id='sb_ifc50']/input")
# webPara$highlightElement()
webPara$clearElement()
webPara$sendKeysToElement(list(args[2]))
Sys.sleep(2)
webPara$sendKeysToElement(list(key = "enter"))

# Ida-Volta --------------------------------------------------
webIdaVolta <- remDr$findElement("xpath", "//span[@class='gws-flights-form__menu-label']")
# webIdaVolta$highlightElement()
webIdaVolta$clickElement()

webIdaVoltaMenu <- remDr$findElement("xpath", "//menu-item[@class='mSPnZKpnf91__menu-item flt-subhead2']")
# webIdaVoltaMenu$highlightElement()
webIdaVoltaMenu$clickElement()

# Pesquisa ---------------------------------------------------
webClick <- remDr$findElement("xpath", "//span[@class='gws-flights-fab__text']")
# webClick$highlightElement()
webClick$clickElement()

# URL --------------------------------------------------------
url <- remDr$getCurrentUrl()[[1]]
saveRDS(url, "url.rds")
remDr$closeall()

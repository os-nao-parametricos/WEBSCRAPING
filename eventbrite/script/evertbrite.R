#' @title Arquivo para extrair dados do Eventbrite
#' @name brain_eventBrite.R
#' @author
#' @description

#' @database
#' 
#' @function
#' @param 
#' @param
#' @param
#' 
#' @output
#' 
#' @analysis
#' 
#' @insights
#' 
#' 
#' @learning html_attr("href") # Extrae o valor de uma tag html
#' @learning html_text("a") # Extrae o valor entre as tags

# package -----------------------------------------------------------------
require(rvest)
require(stringr)
require(rebus)
require(dplyr)
require(purrr)
require(mongolite)

# Balneario_Camboriu ------------------------------------------------------
bc_page <- "https://www.eventbrite.com.br/d/brazil--balne%C3%A1rio-cambori%C3%BA/all-events/"

html <- read_html(bc_page)

# Descobrir quantas páginas tem --------------------------------------------------

get_last_page <- function(link){
  
  pages_data <-
    link %>% 
    html_nodes('a')  %>%  # puxa todas as linhas de nó (a) que é HTML
    html_attr("href") %>%  # extrai os atributo href
    grep("page", ., value = TRUE) %>% 
    str_match_all("[0-9]+") %>% unlist %>% as.numeric() %>% 
    sort(decreasing  = TRUE) %>% 
    first(1)
  
  return(pages_data)

}


# extract links  -------------------------------------------------------------------

html <- read_html(bc_page)

get.all.link <- function(page){

  evento <- 
    page %>%
    read_html() %>% 
    html_nodes("section aside a") %>% 
    html_attr("href") %>% 
    unique()
  
  return(evento)
}


# extract variables -------------------------------------------------------


# Extract title 
extract.title <- function(link){
  
  title <-
    link %>%
    read_html() %>% 
    html_nodes("h1[class='listing-hero-title']") %>% 
    html_text("h1")# Take between the nodes 
    # as.character() %>% 
    
  
  return(title)
}

# Extract Date
extract.date <- function(link){
  date <- 
    link %>% 
    read_html() %>% 
    html_nodes("time[class='listing-hero-date']") %>% 
    html_attr("datetime") 
    # as.character() %>% 

  return(date)
}

# Extract - valor
extract.valor <- function(link){
  
  valor <-
    link %>%
    read_html() %>% 
    html_nodes("div[class='js-display-price']") %>% 
    html_text("div") %>% # Take between the nodes
    str_replace_all(., space(), "") %>% 
    gsub("R\\$", "", .)
    # as.character() %>% 
  
  
  return(valor)
}

# Descrição do Evento
extract.description <- function(link){
  
  description <- 
    link %>% 
    read_html() %>%
    
    # html_nodes("div[class='has-user-generated-content']") %>%  # - english - https://www.eventbrite.com.br/e/workshop-de-musculacao-personafit-tickets-59068298872?aff=ebdssbdestsearch
    # html_text("div")
    # html_nodes("div[data-automation='listing-event-description']") %>% 
    html_nodes("div[data-automation='listing-event-description']") %>%  # br - "https://www.eventbrite.com.br/e/seminario-vida-nova-itajai-tickets-62294024103?aff=ebdssbdestsearch"
    html_text("div") %>%  # Take between the nodes
    str_replace_all(., space(), " ") %>% 
    stringr::str_squish() %>%
    # as.character() %>% 
    unlist()
    
    
  return(description)
}


# values -----------------------------------------------------------


extract.attr <- function(v_evento){
  
  date_web <- map(.x = v_evento,  .f = ~extract.date(.x)) %>%  map_chr(.x = .,  .f = ~char.to.na(.x))
  title_web <- map(.x = v_evento, .f = ~extract.title(.x)) %>%  map_chr(.x = .,  .f = ~char.to.na(.x))
  price_web <- map(.x = v_evento, .f = ~extract.valor(.x)) %>%  map_chr(.x = .,  .f = ~char.to.na(.x))
  description_web <- map(.x = v_evento, .f = ~extract.description(.x)) %>%  map_chr(.x = .,  .f = ~char.to.na(.x))
  
  
  df_scrap <- tibble("date" = date_web, "title" = title_web, "price" = price_web, "description" = description_web)
  return(df_scrap)
}


# evento_one_page ---------------------------------------------------------
# teste <- 
#   evento %>% 
#   extract.attr()
  


# etl ---------------------------------------------------------------------

char.to.na <- function(x){
  
  if(identical(x,character(0))) {
    x <- NA  
  } else x
}


# faster_function -------------------------------------------------------

# Extract title 
extract.attr.union <- function(link){
  
  link <- "https://www.eventbrite.com.br/d/brazil--balne%C3%A1rio-cambori%C3%BA/all-events/"
  evento <- get.all.link(link)
  link_html <- read_html(evento[1])  
  
  en_html <- 
    link_html %>% 
    html_nodes("meta[content='en']")
  
  title <-
    link_html %>% 
    html_nodes("h1[class='listing-hero-title']") %>% 
    html_text("h1") %>% # Take between the nodes 
    char.to.na()
  
  date <- 
    link_html %>%
    html_nodes("time[class='listing-hero-date']") %>% 
    html_attr("datetime") %>% 
    char.to.na()

  
  price <-
    link_html %>%
    html_nodes("div[class='js-display-price']") %>% 
    html_text("div") %>% # Take between the nodes
    str_replace_all(., space(), "") %>% 
    gsub("R\\$", "", .) %>% 
    char.to.na()
  
  lat <-
    link_html %>%
    html_nodes("meta[property ='event:location:latitude']") %>%
    html_attr("content")  # Take between the nodes
  
  long <- 
    link_html %>%
    html_nodes("meta[property ='event:location:longitude']") %>%
    html_attr("content") 
  
  if(purrr::is_empty(en_html)){
  
  description <-
    link_html %>%
    html_nodes("div[data-automation='listing-event-description']") %>%
    html_text("div") %>%  # Take between the nodes
    str_replace_all(., space(), " ") %>% 
    stringr::str_squish() %>%
    char.to.na()
  
  } else{
    
    description <-
      link_html %>%
      html_nodes("div[class='has-user-generated-content']") %>% 
      html_text("div") %>% 
      str_replace_all(., space(), " ") %>% 
      stringr::str_squish() %>%
      char.to.na()
  } 

  nd_df <- tibble("date" = date, "title" = title, "price" = price, "description" = description, "longitude"= long, "latitude" = lat, "url" = link)
  
  return(nd_df)
  
}


# future::plan(future::multiprocess)
# furrr::future_map(evento[1:20], ~extract.attr.union(.x))

# link <- evento[1]  

# extract_all_links -------------------------------------------------------

url_ch <- "https://www.eventbrite.com.br/d/brazil--balne%C3%A1rio-cambori%C3%BA/all-events/?page="
list_of_pages <- str_c(url_ch, 1:get_last_page(html))

# get all urls pages

# future::plan(future::multiprocess)
url_evento <- furrr::future_map(list_of_pages, ~get.all.link(.x)) %>% unlist()

# Extract_all_events
future::plan(future::multiprocess)
event_brite <- furrr::future_map_dfr(url_evento, ~extract.attr.union(.x))


# spatial --------------------------------------------------------------------
geo_event_brite <- 
  event_brite %>% 
  mutate(longitude = as.numeric(longitude),
         latitude = as.numeric(latitude)) %>%  
  sf::st_as_sf(
    coords = c("longitude", "latitude"),
    agr = "identity", # Atributo identidade
    crs = 4326
  )

# mapa --------------------------------------------------------------------
plot(geo_event_brite)

# pe ----------------------------------------------------------------------

event_brite %>% 
  filter(is.na(description))
  
# to do -------------------------------------------------------------------
# Trocar cidade
# ter as tags
# html - english ---- 
# Requisitar api
# vinheta

# Função de Dados -------------------------------------------------------------------

# Extrair por cidades
get.evertbrite <- function(link){
  
  url_ch <- link
  # remove - 
   
  f
  list_of_pages <- str_c(url_ch, 1:get_last_page(html))
  
  url_evento <- 
    furrr::future_map(list_of_pages, 
                      ~get.all.link(.x)) %>%
    unlist()
  
  future::plan(future::multiprocess)
  event_brite <- furrr::future_map_dfr(url_evento, ~extract.attr.union(.x))
  
  return(event_brite)
}
# take all events 

url <- "https://www.eventbrite.com.br/d/brazil--balne%C3%A1rio-cambori%C3%BA/all-events/?page="
eventbrite <- get.evertbrite(url)

# BSave in mongodb
connect <- mongo(collection = "eventbrite", db = "scrap")
connect$insert(eventbrite)


# https://www.eventbrite.com/ajax/event/64622170652/related?aff=erelliv
  
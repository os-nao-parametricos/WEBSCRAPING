source("/home/gabriel/suporte/ciencia_de_dados/programacao/R/function/tidy/etl.R")

# package -----------------------------------------------------------------
require(rvest)
require(stringr)
require(rebus)
require(dplyr)
require(purrr)


# find_last_page  ------------------------------------------------------------------
get.last.page <- function(link){
  
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

get.all.link <- function(page){
  
  evento <- 
    page %>%
    read_html() %>% 
    html_nodes("section aside a") %>% 
    html_attr("href") %>% 
    unique()
  
  return(evento)
}


# extract.data ------------------------------------------------------------

extract.attr.union <- function(link){
  
  link_html <- read_html(link)   

  en_html <- 
    link_html %>% 
    html_nodes("meta[content='en']")
  
  title <-
    link_html %>% 
    html_nodes("h1[class='listing-hero-title']") %>% 
    html_text("h1") %>% # Take between the nodes 
    character.to.na()
  
  date <- 
    link_html %>%
    html_nodes("time[class='listing-hero-date']") %>% 
    html_attr("datetime") %>% 
    character.to.na()
  
  
  price <-
    link_html %>%
    html_nodes("div[class='js-display-price']") %>% 
    html_text("div") %>% # Take between the nodes
    str_replace_all(., space(), "") %>% 
    gsub("R\\$", "", .) %>% 
    character.to.na()
  
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
      character.to.na()
    
  } else{
    
    description <-
      link_html %>%
      html_nodes("div[class='has-user-generated-content']") %>% 
      html_text("div") %>% 
      str_replace_all(., space(), " ") %>% 
      stringr::str_squish() %>%
      character.to.na()
  } 
  
  nd_df <- tibble("date" = date, "title" = title, "price" = price, "description" = description, "longitude"= long, "latitude" = lat, "url" = link)
  
  return(nd_df)
  
}


# apply function -----------------------------------------------------------



# # all_events
# all_event <- "https://www.eventbrite.com.br/d/brazil--balne%C3%A1rio-cambori%C3%BA/all-events/"
# 
# # looping page
# loop_page_event <- paste0(all_event, "?page=")
# 
# # get_all_links
# html_all_event <- read_html(all_event)
# list_of_page <- str_c(url_ch, 1:get_last_page(html_all_event))
# 
# # 
# all_event_url <- furrr::future_map(list_of_page, ~get.all.link(.x)) %>% unlist()
# 
# # Extract_all_events
# future::plan(future::multiprocess)
# eventbrite <- try(
#   furrr::future_map_dfr(all_event_url, ~extract.attr.union(.x))
# )

# functio.to.apply --------------------------------------------------------

get.eventbrite <- function(url){
  # all_event <- "https://www.eventbrite.com.br/d/brazil--balne%C3%A1rio-cambori%C3%BA/all-events/"
  all_event <- url
  
  loop_page_event <- paste0(all_event, "?page=")
  
  # get_all_links
  html_all_event <- read_html(all_event)
  list_of_page <- str_c(loop_page_event, 1:get.last.page(html_all_event))
  
  # 
  all_event_url <- furrr::future_map(list_of_page, ~get.all.link(.x)) %>% unlist()
  
  # Extract_all_events
  
    future::plan(future::multiprocess)
    eventbrite <- try(furrr::future_map_dfr(all_event_url, ~extract.attr.union(.x)))
  
  return(eventbrite)
}


# event_brite <- get.eventbrite("https://www.eventbrite.com.br/d/brazil--balne%C3%A1rio-cambori%C3%BA/all-events/")
# eventbrite_cwb <- get.eventbrite(url = "https://www.eventbrite.com.br/d/brazil--curitiba/all-events/")




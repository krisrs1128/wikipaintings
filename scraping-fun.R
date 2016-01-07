library("rvest")

process_page <- function(url) {
  page_html <- url %>% read_html
  page_data <- list()
  page_data$url <- url
  page_data$image <- page_html %>%
    html_nodes("img[itemprop=image]") %>%
    html_attr("src")
  page_html <- html_nodes(page_html, ".DataProfileBox")
  page_data$author <- page_html %>%
    html_nodes("a[itemprop='author']") %>% html_text
  page_data$id <- paste(gsub(" ", "_", tolower(page_data$author)),
                        basename(url), sep = "@")
  page_data$date <- page_html %>%
    html_nodes("span[itemprop='dateCreated']") %>%  html_text
  page_data$style <- page_html %>%
    html_nodes("span[itemprop='style']") %>% html_text
  page_data$genre <- page_html %>%
    html_nodes("span[itemprop='genre']") %>% html_text
  page_data$technique <- page_html %>%
    html_nodes("span[itemprop='technique']") %>% html_text
  page_data$keywords <- page_html %>%
    html_nodes("span[itemprop='keywords'] a") %>% html_text
  page_data$gallery <- clean_contains_data(page_html, "Gallery")
  page_data$dimensions <-   clean_contains_data(page_html, "Dimensions")
  page_data$material <- clean_contains_data(page_html, "Material")
  return (page_data)
}

get_artists_by_letter <- function(letter) {
  url <- file.path("http://www.wikiart.org/en/Alphabet", letter)
  page_html <- url %>% read_html
  artists <- page_html %>%
    html_nodes(".pozRel a") %>%
    html_attr("href") %>%
    basename
  return (artists)
}

get_paintings_for_artist <- function(artist) {
  artist_homepage <- file.path(sprintf("http://www.wikiart.org/en/%s//mode/all-paintings", artist))
  page_html <- artist_homepage %>% read_html

  all_urls <- page_html %>%
    html_nodes(".pager-items a") %>%
    html_attr("href") %>%
    unique() %>% na.omit()

  paintings_paths <- vector(length = length(all_urls), mode = "list")
  for(i in seq_along(paintings_paths)) {
    paintings_paths[[i]] <- get_paintings_on_page(all_urls[i])
  }

  unlist(paintings_paths, use.names = FALSE)
}

get_paintings_on_page <- function(artist_subpage) {
  cur_page <- file.path(artist_subpage)
  page_html <- cur_page %>% read_html
  paintings <- page_html %>%
    html_nodes("#paintings .pb5 a") %>%
    html_attr("href")
  file.path("http://www.wikiart.org", paintings)
}

clean_contains_data <- function(page_html, term) {
  selector <- sprintf(":contains('%s')", term)
  term_data <- page_html %>% html_nodes(selector) %>% html_text
  term_data <- gsub("\r||\t||\n", "", strsplit(term_data[1], ":")[[1]][2])
  return (term_data)
}

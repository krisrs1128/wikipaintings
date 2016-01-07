source("scraping-fun.R")

img_dir <- "paintings"
metadata_file <- "metadata.tsv"
failed_pages <- "failed_pages.txt"
failed_images <- "failed_images.txt"
failed_artists <- "failed_artists.txt"
failed_letters <- "failed_letters.txt"


cat(c("url", "id", "image", "author", "date", "style", "genre",
      "technique", "keywords", "gallery", "dimensions",
      "material"), "\n", file = metadata_file)
cat("failed_pages \n", file = failed_pages)
cat("failed_images \n", file = failed_images)
cat("failed_artists \n", file = failed_artists)
cat("failed_letters \n", file = failed_letters)

redon <- get_paintings_for_artist("odilon-redon")
process_page(redon[1])
dir.create("redon")

metadata <- vector(length = length(redon), mode = "list")
for(i in seq_along(redon)) {
  metadata[[i]] <- process_page(redon[i])
  cur_url <- metadata[[i]]$image
  download.file(cur_url, file.path("redon", basename(cur_url)))
}

library("jsonlite")
library("plyr")
toJSON(metadata)
ldply(metadata, as.data.frame)

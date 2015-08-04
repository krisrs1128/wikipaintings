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

for(letter in LETTERS) {
    # Attempt to get artists whose names start with a certain letter
    artists <- try(get_artists_by_letter(letter))
    if(class(artists) == "try-error") {
        cat(letter, "\n", file = failed_letters, append = TRUE)
    } else {
        for(artist in artists) {
        # Attempt to get paintings for current artist
            paintings <- try(get_paintings_for_artist(artist))
            if(class(paintings) == "try-error") {
                cat(artist, "\n", file = failed_artists, append = TRUE)
            } else {
                for(cur_painting in paintings) {
                    # Attempt to scrape page data
                    cur_page <- try(process_page(cur_painting))
                    if(class(cur_page) == "try-error") {
                        cat(cur_painting, "\n", file = failed_pages, append = TRUE)
                    } else {
                        cur_page$keywords <- paste0(cur_page$keywords, collapse = ",")
                        cat(unlist(cur_page), "\n", file = metadata_file, append = TRUE)
                        Sys.sleep(.5)
                    }

                    # Attempt to download the associated image
                    download_attempt <- try(download.file(cur_page$image, file.path(img_dir, cur_page$id)))
                    if(class(download_attempt) == "try-error") {
                        cat(cur_painting, "\n", file = failed_images, append = TRUE)
                    }
                }
            }
        }
    }
}

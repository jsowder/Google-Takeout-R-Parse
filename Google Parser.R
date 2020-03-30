# Import Libraries
library(tidyverse)
library(rvest)
library(xml2)
library(lubridate)

# Before starting, download your Google Takeout file from:
# https://takeout.google.com/

#########################
# DEFINE YOUR VARIABLES #
#########################

# Where did you download your Takeout files to?
takeout_download_path <- "~/Downloads/Takeout"

# Where would you like to save a CSV of your results?
resulting_csv_path <- "example.csv"

# Now run the script!
# If you add anything helpful please pull and commit -- thanks!
# https://github.com/jsowder/Google-Takeout-R-Parse

#########################^
# DEFINE YOUR VARIABLES #^
#########################^

# General function for cleaning HTML files present in Google Takeout
# Each variable explained with a comment where it is created
clean_takeout_html <- function(file_path){
  r <-
    read_html(file_path) %>%
    html_nodes(".outer-cell") %>% # Gather each card you see in the HTML file
    tibble() %>% 
    rename("raw" = ".") %>% 
    mutate(Service = "GoogleTakeout",
           
           # Search/Youtube/Maps/etc (TITLE of the card)
           ServiceDetail = raw %>% 
             html_node(".header-cell") %>% 
             html_text(),
           
           # Timestamp in the card
           StartTime = raw %>% 
             str_extract(
               pattern = "(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [:digit:]{1,2}, [:digit:]{4}, [:digit:]{1,2}:[:digit:]{1,2}:[:digit:]{1,2} ([AP]M) EDT"
               ) %>% 
             parse_datetime(format = "%b %d, %Y, %T %p %Z"),
           
           # Whatever comes before the colon/etc -- mine is miscoded as the Â character, change as needed.
           #  e.g. "Searched for:", "Visited:", "Got directions to:", etc.
           Activity = raw %>%
             html_node(css = ".content-cell") %>%
             as_list() %>% 
             pluck(1) %>% 
             str_remove("Â") %>% 
             str_trim(),
           
           # Text contents of the link following the colon
           #   e.g. video watched, text searched, address of directions
           Detail = raw %>% 
             html_node(css = ".content-cell") %>%
             html_node("a") %>% 
             html_text() %>% 
             str_trim(),
           
           # Link to whatever followed the colon
           #   e.g. google.com/query=SearchContents...
           Link = raw %>% 
             html_node(css = ".content-cell") %>% 
             html_node("a") %>% 
             html_attr("href")
    )
  
  return(r)
}



# Import data
file_paths <- 
  c(list.files(path = takeout_download_path, recursive = TRUE, full.names = TRUE, pattern = "MyActivity|history.html")) 

all_data <-
  sapply(X = file_paths,
         FUN = clean_takeout_html,
         simplify = FALSE,
         USE.NAMES = TRUE) %>% 
  bind_rows(.id = "ServiceFile") %>% 
  select(-raw) %>% 
  mutate(ServiceFile = ServiceFile %>% 
           basename()) %>% 
  arrange(desc(StartTime)) %>% 
  distinct()


# Export Clean Data
write_csv(all_data,
          path = resulting_csv_path,
          append = FALSE)


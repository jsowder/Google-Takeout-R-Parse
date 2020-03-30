library(tidyverse)
library(rvest)
library(xml2)
library(lubridate)

# Clean it up function
clean_takeout_html <- function(file_path){
  r <-
    read_html(file_path) %>%
    html_nodes(".outer-cell") %>% 
    tibble() %>% 
    rename("raw" = ".") %>% 
    mutate(Service = "GoogleTakeout",
           
           ServiceDetail = raw %>% 
             html_node(".header-cell") %>% 
             html_text(),
           
           StartTime = raw %>% 
             str_extract(
               pattern = "(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [:digit:]{1,2}, [:digit:]{4}, [:digit:]{1,2}:[:digit:]{1,2}:[:digit:]{1,2} ([AP]M) EDT"
               ) %>% 
             parse_datetime(format = "%b %d, %Y, %T %p %Z"),
           
           Activity = raw %>%
             html_node(css = ".content-cell") %>%
             as_list() %>% 
             pluck(1) %>% 
             str_remove("Â") %>% 
             str_trim(),
           
           Detail = raw %>% 
             html_node(css = ".content-cell") %>%
             html_node("a") %>% 
             html_text() %>% 
             str_trim(),
           
           Link = raw %>% 
             html_node(css = ".content-cell") %>% 
             html_node("a") %>% 
             html_attr("href")
    )
  
  return(r)
}



# Import data
takeout_download_path <- "/Users/jacobsowder/Library/Mobile Documents/com~apple~CloudDocs/Data_Mine/Google/_mar-26-2020/Takeout"
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

# Final touches
# all_data %<>% 

# Export Clean Data
write_csv(all_data,
          path = "/Users/jacobsowder/Library/Mobile Documents/com~apple~CloudDocs/Data_Mine/_new/Time/google_takeout_time.csv",
          append = FALSE)


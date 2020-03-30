# Why? What?
Google Takeout provides many files in formats that are easy to view (e.g. HTML) but not so easy to analyze as data. 

The current script above parses the HTML files into one big tibble. This makes for easier analysis and saves you some grunt work.

# How to use
1. Download your Google data from https://takeout.google.com/
2. Open the script from this repo and define the top two variables.
 a. takeout_download_path: the path to your unzipped Google Takeout folder
 b. resulting_csv_path: path to a csv file you would like to save your results to

# Can I make improvements to it?
Yes! Feel free.

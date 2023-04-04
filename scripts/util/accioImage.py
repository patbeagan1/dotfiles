#!python3

import requests
from bs4 import BeautifulSoup
import urllib.request
import sys

# Define the search query
query = sys.argv[1]

# Set the user-agent string to avoid being blocked by the search engines
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
}

# Set the URLs for the Google, Bing, and DuckDuckGo image searches
# Send a GET request to each search engine with the user-agent headers
# Use BeautifulSoup to parse the response HTML for each search engine
# Find the first image result for each search engine
# Download the images to the current directory


def parse_google(query: str):
    google_url = "https://www.google.com/search?q=" + query + "&tbm=isch"
    google_response = requests.get(google_url, headers=headers)
    google_soup = BeautifulSoup(google_response.text, "html.parser")
    google_img_url = [x for x in google_soup.find_all("img")]
    google_img_url = [
        {"alt": x["alt"], "data-src": x["data-src"]}
        for x in google_img_url
        if "alt" in x.attrs
        if x["alt"]
        if "width" in x.attrs
        if int(x["width"]) > 48
        if "data-src" in x.attrs
    ]
    google_img_url = [x for x in google_img_url if x["data-src"].startswith("http")]
    google_img_url = google_img_url[0]["data-src"]
    filename = f"google_{query}.jpg"
    urllib.request.urlretrieve(google_img_url, filename)
    print(google_url)
    print(filename)


def parse_bing(query: str):
    bing_url = "https://www.bing.com/images/search?q=" + query
    bing_response = requests.get(bing_url, headers=headers)
    bing_soup = BeautifulSoup(bing_response.text, "html.parser")
    bing_img_url = [
        {"alt": x["alt"], "data-src": x["data-src"]}
        for x in bing_soup.find_all("img")
        if "alt" in x.attrs
        if x["alt"]
        if "data-src" in x.attrs
    ]
    bing_img_url = [x for x in bing_img_url if x["data-src"].startswith("http")]
    bing_img_url = bing_img_url[0]["data-src"]
    filename = f"bing_{query}.jpg"
    urllib.request.urlretrieve(bing_img_url, filename)
    print(bing_url)
    print(filename)


def main():
    query = sys.argv[1]
    parse_google(query)
    parse_bing(query)

if __name__ == "__main__":
    main()

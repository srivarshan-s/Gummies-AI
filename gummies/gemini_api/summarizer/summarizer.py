import pandas as pd
import os

import requests

# News API Class
class NewsAPI:  
    def __init__(self,api_key=None):
        if(api_key == None):
            self.api_key = os.getenv('NEWS_API_KEY')
        else:
            self.api_key = api_key

    def clean_news(self,raw_news):
        news = raw_news['articles']
        news_contents = list(map(lambda x: x['content'],news))
        images = list(map(lambda x: x['urlToImage'],news))
        return {"contents":news_contents,"images":images}

    def get_all_news(self,query=None):
        raw_news = self.get_raw_news(query)
        news = self.clean_news(raw_news)
        return news
    
    def get_raw_all_news(self,query=None):
        if(query == None):
            query = 'bitcoin'
        url = f'https://newsapi.org/v2/everything?q={query}&apiKey={self.api_key}'
        response = requests.get(url)
        return response.json()
    
    def get_raw_highlights(self,query=None):
        if(query == None):
            query = 'bitcoin'
        url = f'https://newsapi.org/v2/top-headlines?q={query}&apiKey={self.api_key}'
        response = requests.get(url)
        return response.json()
    
    def get_highlights(self,query=None):
        raw_news = self.get_raw_highlights(query)
        news = self.clean_news(raw_news)
        return news
    
# Main Class - Summarizer class
class Summarizer:
    def __init__(self):
        pass



## Test Scripts


## Load DotEnv File
from dotenv import load_dotenv
load_dotenv('../../../.env')

newsInstance = NewsAPI()
news = newsInstance.get_news()
print(news)

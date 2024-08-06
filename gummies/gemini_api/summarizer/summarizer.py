import os
import requests
import json

import google.generativeai as genai

# News API Class
class NewsAPI:  
    def __init__(self,api_key=None):
        try:
            if(api_key == None):
                self.api_key = os.getenv('NEWS_API_KEY')
            else:
                self.api_key = api_key
                
            if(self.api_key == None):
                raise Exception
        except:
            raise Exception("Error loading News API Key")

    def clean_news(self,raw_news):
        news = raw_news['articles']
        news_contents = list(map(lambda x: x['content'],news))
        images = list(map(lambda x: x['urlToImage'],news))
        return {"contents":news_contents,"images":images}

    def get_all_news(self,query=None):
        raw_news = self.get_raw_all_news(query)
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
    prompts_dict = {}
    def __init__(self,gemini_api_key=None,prompts_dir = "../prompts.json"):
        self.news_api = NewsAPI()

        # Load Gemini API key
        if(gemini_api_key == None):
            self.gemini_api_key = os.getenv("GEMINI_API_KEY")
        else:
            self.gemini_api_key = gemini_api_key

        genai.configure(api_key=self.gemini_api_key)
        self.gemini_model = genai.GenerativeModel('gemini-1.5-flash')

        self.load_prompts(prompts_dir)
            
    def load_prompts(self,prompts_dir):
        try:
            with open(prompts_dir) as f:
                self.prompts_dict = json.load(f)
        except:
            raise Exception("Error loading prompts")

    def summarize_news(self,query=None):
        cleaned_news = self.news_api.get_all_news(query)
        article_contents = '\n'.join(cleaned_news['contents'])

        # Call Gemini API
        response = self.gemini_model.generate_content(self.prompts_dict['SUMMARIZE_PROMPT'].format(ARTICLES=article_contents))

        return response.text
    
    def get_highlights(self,query=None):
        news = self.news_api.get_highlights(query)
        return news
        
## Test Scripts

## Load DotEnv File
### Add the following code to the root file
from dotenv import load_dotenv
load_dotenv('../../../.env')

summarizer = Summarizer()
print(summarizer.summarize_news('bitcoin'))
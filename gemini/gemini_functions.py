import json
import logging
import os
import secrets
import urllib.parse
from datetime import datetime
from io import StringIO

import finnhub
import google.generativeai as genai
import requests
import uvicorn
from dateutil.relativedelta import relativedelta
from fastapi import FastAPI
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

# Configure logging
logging.basicConfig(
    level=logging.INFO,  # Set the logging level to INFO (you can change this to DEBUG, ERROR, etc.)
    format="%(asctime)s - %(levelname)s - %(message)s",  # Format the log messages
    handlers=[
        logging.FileHandler(
            "autocorrect.log"
        ),  # Log to a file named 'mongodb_connection.log'
        logging.StreamHandler(),  # Also log to the console
    ],
)

# Get MongoDB username and password from environment variables
MONGO_USNM = urllib.parse.quote_plus(os.environ["MONGO_USNM"])
MONGO_PSWD = urllib.parse.quote_plus(os.environ["MONGO_PSWD"])

uri = f"mongodb+srv://{MONGO_USNM}:{MONGO_PSWD}@cluster0.v2avpdc.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

# Create a new client and connect to the server
client = MongoClient(uri, server_api=ServerApi("1"))

try:
    client.admin.command("ping")
    logging.info("Successfully connected to MongoDB!")
except Exception as err:
    logging.error(f"An error occurred: {err}")
    exit(0)

# Access the api_keys database and gemini collection
db = client["api_keys"]
collection_gemini = db["gemini"]
collection_finnhub = db["finnhub"]


# Retrieve all documents and extract the API keys
GEMINI_API_KEYS = [doc["key"] for doc in collection_gemini.find({}, {"_id": 0, "key": 1})]

FINNHUB_API_KEY = [doc["key"] for doc in collection_finnhub.find({}, {"_id": 0, "key": 1})]

# Access the gummies database and prompts collection
db = client["gummies"]
collection_gemini = db["prompts"]

# Retreive the prompt for autocorrection
prompt_autocorrect = collection_gemini.find({"model": "autocorrect"})[0]["prompt"]

prompt_stockOpinion = collection_gemini.find({"model": "stockOpinion"})[0]["prompt"]

# Close the MongoDB connection
client.close()

app = FastAPI()


@app.get("/autocorrect")
def autocorrect(text: str):
    # Set upper-bound to stop hitting random API keys
    num_hits = len(GEMINI_API_KEYS)
    print(GEMINI_API_KEYS)
    while GEMINI_API_KEYS:
        API_KEY = secrets.choice(GEMINI_API_KEYS)
        try:
            genai.configure(api_key=API_KEY)
            model = genai.GenerativeModel(
                model_name="gemini-1.5-flash",
                system_instruction=prompt_autocorrect,
                generation_config={"response_mime_type": "application/json"},
            )
            response = model.generate_content(text)
            num_hits += 1
            return json.loads(response.text)
        except Exception as e:
            logging.warning(f"Model cannot generate with API key {API_KEY}: {e}")
            num_hits -= 1
            if num_hits <= 0:
                return {"text": "ERROR"}
            

@app.get("/stockOpinion")
def stockOpinion(ticker):
    num_hits = len(GEMINI_API_KEYS)
    print(GEMINI_API_KEYS)
    while GEMINI_API_KEYS:
        API_KEY = secrets.choice(GEMINI_API_KEYS)
        try:
            genai.configure(api_key=API_KEY)
            finnhub_client = finnhub.Client(api_key=FINNHUB_API_KEY)
            model = genai.GenerativeModel(
            'gemini-1.5-flash', 
            system_instruction=prompt_stockOpinion, generation_config={"response_mime_type": "application/json"})
            
            to_date = datetime.now()

            from_date = to_date - relativedelta(months=9)

            # Format the dates
            to_date_str = to_date.strftime("%Y-%m-%d")
            from_date_str = from_date.strftime("%Y-%m-%d")

            output = StringIO()
            articles = finnhub_client.company_news(ticker, _from=from_date_str, to=to_date_str)                
                
            for article in articles:
                output.write(article['headline'])
                output.write('\n')
                output.write(article['summary'])
                date = datetime.fromtimestamp(article['datetime'])
                output.write(f'\nPublished on {date.strftime("%Y-%m-%d")}\n\n')
                output.write('\n')


            news = output.getvalue()

            opinion = model.generate_content(news)

            num_hits += 1

            return json.loads(opinion)

        except Exception as e:
            logging.warning(f"Model cannot generate with API key {API_KEY}: {e}")
            num_hits -= 1
            if num_hits <= 0:
                return {"text": "ERROR"}
		

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
    
# Beautify Class
class Beautify:
    def __init__(self,gemini_api_key=None,prompts_dir = "../prompts.json"):
        self.news_api = NewsAPI()

        # Load Gemini API key
        if(gemini_api_key == None):
            self.gemini_api_key = os.getenv("GEMINI_API_KEY")
        else:
            self.gemini_api_key = gemini_api_key

        # Load Prompts
        self.load_prompts(prompts_dir)

        # Configure Gemini API
        genai.configure(api_key=self.gemini_api_key)

    def load_prompts(self,prompts_dir):
        try:
            with open(prompts_dir) as f:
                self.prompts_dict = json.load(f)
        except:
            raise Exception("Error loading prompts")

    def beautify_content(self,content_json,query="GENERAL_DESCRIPTION"):
        description = content_json['description']
        company_name = content_json['company_name']

        response = self.gemini_model.generate_content(self.prompts_dict[query].format(DESCRIPTION=description,COMPANY_NAME=company_name))
        return response.text


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

class Insights:

    def __init__(self,gemini_api_key=None,prompts_dir = "../prompts.json"):
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

    def get_projections(self,values=[]):
        values = list(map(str,values))
        values = ','.join(values)
        prompt = self.prompts_dict['PROJECTION']
        prompt = prompt.format(STOCK_VALUES=values,TIMES=10)

        response = self.gemini_model.generate_content(prompt)
        return response.text
        
## Test Scripts

## Load DotEnv File
### Add the following code to the root file
# from dotenv import load_dotenv
# load_dotenv('../../../.env')

# summarizer = Summarizer()
# print(summarizer.summarize_news('bitcoin'))

insights = Insights()
print(insights.get_projections(values=[1,2,3,4,45,5,100,20,340]))
                                


if __name__ == "__main__":

    uvicorn.run(app, host="0.0.0.0", port=8080)

import json
from json import JSONDecodeError
import logging
import os
import secrets
import urllib.parse
import certifi
from datetime import datetime
from io import StringIO

import finnhub
import google.generativeai as genai
import requests
import uvicorn
from dateutil.relativedelta import relativedelta
from dotenv import load_dotenv
from fastapi import FastAPI
from google.api_core.exceptions import InvalidArgument  # Exception Handling
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

# Configure logging
logging.basicConfig(
    # Set the logging level to INFO (you can change this to DEBUG, ERROR, etc.)
    level=logging.INFO,
    # Format the log messages
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("gemini.log"),
        logging.StreamHandler(),  # Also log to the console
    ],
)

# Get MongoDB username and password from environment variables
load_dotenv()
MONGO_USNM = urllib.parse.quote_plus(os.environ["MONGO_USNM"])
MONGO_PSWD = urllib.parse.quote_plus(os.environ["MONGO_PSWD"])

uri = f"mongodb+srv://{MONGO_USNM}:{MONGO_PSWD}@cluster0.v2avpdc.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

# Create a new client and connect to the server
client = MongoClient(uri, server_api=ServerApi("1"), tlsCAFile=certifi.where())

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
collection_newsapi = db["news_api"]

# Retrieve all documents and extract the API keys
GEMINI_API_KEYS = [
    doc["key"] for doc in collection_gemini.find({}, {"_id": 0, "key": 1})
]
FINNHUB_API_KEY = [
    doc["key"] for doc in collection_finnhub.find({}, {"_id": 0, "key": 1})
]
NEWS_API_KEY = [doc["key"]
                for doc in collection_newsapi.find({}, {"_id": 0, "key": 1})]

# Access the gummies database and prompts collection
db = client["gummies"]
collection_gemini = db["prompts"]

# Retreive the prompt for autocorrection
prompt_autocorrect = collection_gemini.find(
    {"model": "autocorrect"})[0]["prompt"]
prompt_stockOpinion = collection_gemini.find(
    {"model": "stockOpinion"})[0]["prompt"]
prompt_projection = collection_gemini.find(
    {"model": "projection"})[0]["prompt"]
prompt_recommendation = collection_gemini.find(
    {"model": "recommendation"})[0]["prompt"]
prompt_expandWatchlist = collection_gemini.find(
    {"model": "expandWatchlist"})[0]["prompt"]
prompt_summstartup = collection_gemini.find(
    {"model": "summariseStartup"})[0]["prompt"]


# Close the MongoDB connection
client.close()
app = FastAPI()


@app.get("/get_recommendations")
def get_recommendations(profile: str):
    global prompt_recommendation
    num_hits = len(GEMINI_API_KEYS)
    while GEMINI_API_KEYS:
        API_KEY = secrets.choice(GEMINI_API_KEYS)
        prompt_recommendation = prompt_recommendation.format(
            DESCRIPTION=profile)
        try:
            genai.configure(api_key=API_KEY)
            model = genai.GenerativeModel(
                "gemini-1.5-flash",
                generation_config={"response_mime_type": "application/json"},
                system_instruction=" ",
            )
            response = model.generate_content(prompt_recommendation)
            num_hits += 1
            return json.loads(response.text)
        except InvalidArgument as e:
            logging.warning(
                f"Model cannot generate with API key {API_KEY}: {e}")
            num_hits -= 1
            if num_hits <= 0:
                return {"text": "ERROR"}


@app.get("/get_projections")
def get_projections(object_string: str):
    global prompt_projection
    values = json.loads(object_string["results"])
    values = list(map(lambda x: str(x["v"]), values))
    values = "[" + ",".join(values) + "]"

    num_hits = len(GEMINI_API_KEYS)
    while GEMINI_API_KEYS:
        API_KEY = secrets.choice(GEMINI_API_KEYS)
        try:
            prompt_projection = prompt_projection.format(
                STOCK_VALUES=values, TIMES=10)
            genai.configure(api_key=API_KEY)
            model = genai.GenerativeModel(
                "gemini-1.5-flash",
                generation_config={"response_mime_type": "application/json"},
            )
            response = model.generate_content(prompt_projection)
            num_hits += 1
            return json.loads(response.text)
        except InvalidArgument as e:
            logging.warning(
                f"Model cannot generate with API key {API_KEY}: {e}")
            num_hits -= 1
            if num_hits <= 0:
                return {"text": "ERROR"}


@app.get("/autocorrect")
def autocorrect(text: str):
    # Set upper-bound to stop hitting random API keys
    num_hits = len(GEMINI_API_KEYS)
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
        except InvalidArgument as e:
            logging.warning(
                f"Model cannot generate with API key {API_KEY}: {e}")
            num_hits -= 1
            if num_hits <= 0:
                return {"text": "ERROR"}
            

@app.get('/summarizestartup')
def summarizeStartup(jsonDetails):
    num_hits = len(GEMINI_API_KEYS)
    while GEMINI_API_KEYS:
        API_KEY = secrets.choice(GEMINI_API_KEYS)
        try:
            # Summarise the given comapny's aim and vision. Return it as a json with the format: {'Company name': str, 'Year founded': str, 'Headquarters': str. 'Contact Information': str, 'About': str}
            genai.configure(api_key=API_KEY)
            model = genai.GenerativeModel(
                "gemini-1.5-flash",
                system_instruction=prompt_summstartup,
                generation_config={"response_mime_type": "application/json"},
            )

            jsonDetails = json.dumps(jsonDetails)
            response = model.generate_content(jsonDetails)
            num_hits += 1

            return json.loads(response.text)

        except InvalidArgument as e:
            logging.warning(
                f"Model cannot generate with API key {API_KEY}: {e}")
            num_hits -= 1
            if num_hits <= 0:
                return {"text": "ERROR"}


@app.get("/stockopinion")
def stockOpinion(ticker: str):
    finnhub_client = finnhub.Client(api_key=FINNHUB_API_KEY)
    to_date = datetime.now()
    from_date = to_date - relativedelta(months=9)

    # Format the dates
    to_date_str = to_date.strftime("%Y-%m-%d")
    from_date_str = from_date.strftime("%Y-%m-%d")

    output = StringIO()
    articles = finnhub_client.company_news(
        ticker, _from=from_date_str, to=to_date_str)

    for article in articles:
        output.write(article["headline"])
        output.write("\n")
        output.write(article["summary"])
        date = datetime.fromtimestamp(article["datetime"])
        output.write(f'\nPublished on {date.strftime("%Y-%m-%d")}\n\n')
        output.write("\n")

    news = output.getvalue()

    num_hits = len(GEMINI_API_KEYS)
    while GEMINI_API_KEYS:
        API_KEY = secrets.choice(GEMINI_API_KEYS)
        try:
            genai.configure(api_key=API_KEY)
            model = genai.GenerativeModel(
                "gemini-1.5-flash",
                system_instruction=prompt_stockOpinion,
                generation_config={"response_mime_type": "application/json"},
            )
            response = model.generate_content(news)
            num_hits += 1

            return json.loads(response.text)

        except InvalidArgument as e:
            logging.warning(
                f"Model cannot generate with API key {API_KEY}: {e}")
            num_hits -= 1
            if num_hits <= 0:
                return {"text": "ERROR"}


@app.get("/expandwatchlist")
def expandWatchlist(symbols):
    # response = requests.get("http://localhost:3000/get_watchlist?user_id=")
    # response.raise_for_status()  # Ensure that the request was successful
    # watchlist = response.json()  # Use the .json() method to parse the response JSON

    # symbols = [company["symbol"] for company in watchlist.get("selected_companies", [])]

    num_hits = len(GEMINI_API_KEYS)
    while GEMINI_API_KEYS:
        API_KEY = secrets.choice(GEMINI_API_KEYS)
        try:
            genai.configure(api_key=API_KEY)
            model = genai.GenerativeModel(
                "gemini-1.5-flash",
                system_instruction=prompt_expandWatchlist,
                generation_config={"response_mime_type": "application/json"},
            )
            response = model.generate_content(symbols)
            num_hits += 1
            return json.loads(response.text)

        except InvalidArgument as e:
            logging.warning(
                f"Model cannot generate with API key {API_KEY}: {e}")
            num_hits -= 1
            if num_hits <= 0:
                return {"text": "ERROR"}

        except JSONDecodeError as e:
            logging.warning(
                f"JSON Error: {e}")
            return {"text": "JSONERROR"}


# News API Classgem
class NewsAPI:
    def __init__(self, api_key=None):
        try:
            if api_key is None:
                self.api_key = os.getenv("NEWS_API_KEY")
            else:
                self.api_key = api_key

            if self.api_key is None:
                raise Exception
        except Exception as e:
            raise Exception(f"Error loading News API key {self.api_key}: {e}")

    def clean_news(self, raw_news):
        news = raw_news["articles"]
        news_contents = list(map(lambda x: x["content"], news))
        images = list(map(lambda x: x["urlToImage"], news))
        return {"contents": news_contents, "images": images}

    def get_all_news(self, query=None):
        raw_news = self.get_raw_all_news(query)
        news = self.clean_news(raw_news)
        return news

    def get_raw_all_news(self, query=None):
        if query is None:
            query = "bitcoin"
        url = f"https://newsapi.org/v2/everything?q={query}&apiKey={self.api_key}"
        response = requests.get(url)
        return response.json()

    def get_raw_highlights(self, query=None):
        if query is None:
            query = "bitcoin"
        url = f"https://newsapi.org/v2/top-headlines?q={query}&apiKey={self.api_key}"
        response = requests.get(url)
        return response.json()

    def get_highlights(self, query=None):
        raw_news = self.get_raw_highlights(query)
        news = self.clean_news(raw_news)
        return news


# Main Class - Summarizer class
class Summarizer:
    prompts_dict = {}

    def __init__(self, gemini_api_key=None, prompts_dir="../prompts.json"):
        self.news_api = NewsAPI()

        # Load Gemini API key
        if gemini_api_key is None:
            self.gemini_api_key = os.getenv("GEMINI_API_KEY")
        else:
            self.gemini_api_key = gemini_api_key

        genai.configure(api_key=self.gemini_api_key)
        self.gemini_model = genai.GenerativeModel("gemini-1.5-flash")

        self.load_prompts(prompts_dir)

    def load_prompts(self, prompts_dir):
        try:
            with open(prompts_dir) as f:
                self.prompts_dict = json.load(f)
        except Exception as e:
            raise Exception(f"Error loading prompts: {e}")

    def summarize_news(self, query=None):
        cleaned_news = self.news_api.get_all_news(query)
        article_contents = "\n".join(cleaned_news["contents"])

        # Call Gemini API
        response = self.gemini_model.generate_content(
            self.prompts_dict["SUMMARIZE_PROMPT"].format(
                ARTICLES=article_contents)
        )

        return response.text

    def get_highlights(self, query=None):
        news = self.news_api.get_highlights(query)
        return news


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
    # uvicorn.run(app, host="localhost", port=8080)

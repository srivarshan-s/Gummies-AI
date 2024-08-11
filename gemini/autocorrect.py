import logging
import os
import secrets
import urllib.parse
import json

import google.generativeai as genai
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

from fastapi import FastAPI

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
collection = db["gemini"]

# Retrieve all documents and extract the API keys
API_KEYS = [doc["key"] for doc in collection.find({}, {"_id": 0, "key": 1})]

# Access the gummies database and prompts collection
db = client["gummies"]
collection = db["prompts"]

# Retreive the prompt for autocorrection
prompt = collection.find({"model": "autocorrect"})[0]["prompt"]

# Close the MongoDB connection
client.close()

app = FastAPI()


@app.get("/autocorrect")
def autocorrect(text: str):
    # Set upper-bound to stop hitting random API keys
    num_hits = len(API_KEYS)
    print(API_KEYS)
    while API_KEYS:
        API_KEY = secrets.choice(API_KEYS)
        try:
            genai.configure(api_key=API_KEY)
            model = genai.GenerativeModel(
                model_name="gemini-1.5-flash",
                system_instruction=prompt,
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


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8080)

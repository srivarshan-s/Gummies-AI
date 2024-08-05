import textwrap
import google.generativeai as genai
from IPython.display import Markdown
import os
from datetime import datetime
import finnhub


def to_markdown(text):
  text = text.replace('•', '  *')
  return Markdown(textwrap.indent(text, '> ', predicate=lambda _: True))

GOOGLE_API_KEY = os.environ.get('GOOGLE_API_KEY')
FINNHUB_API_KEY = os.environ.get('FINNHUB_API_KEY')

model = genai.GenerativeModel(
  'gemini-1.5-flash', 
  system_instruction='You are a stock market news analyser who summarizes news articles of a particular company and predicts share price in the near future, with an opinion on whether to buy or sell. Give your response in less than 200 words.',)


finnhub_client = finnhub.Client(api_key=FINNHUB_API_KEY)

with open('news_summary.txt', 'w') as file:
  articles = finnhub_client.company_news('AAPL', _from="2024-01-01", to="2024-08-03")
  
  for article in articles:
    file.write(article['headline'])
    file.write('\n')
    file.write(article['summary'])
    date = datetime.fromtimestamp(article['datetime'])
    file.write(f'\nPublished on {date.strftime("%Y-%m-%d")}\n\n')
    file.write('\n')


with open('news_summary.txt', 'r') as file:
  news = file.read()

response = model.generate_content(news)

to_markdown(response.text)

for chunk in response:
  print(chunk.text)
  print("_"*80)
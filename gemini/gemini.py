import textwrap
import google.generativeai as genai
import os
from datetime import datetime
import finnhub

from datetime import datetime
from dateutil.relativedelta import relativedelta


class Stocks:
	def __init__(self):
		self.GOOGLE_API_KEY = os.environ.get('GOOGLE_API_KEY')
		self.FINNHUB_API_KEY = os.environ.get('FINNHUB_API_KEY')

		self.finnhub_client = finnhub.Client(api_key=self.FINNHUB_API_KEY)
		genai.configure(api_key=self.GOOGLE_API_KEY)


	def stockOpinion(self, ticker):
		model = genai.GenerativeModel(
		'gemini-1.5-flash', 
		system_instruction='You are a stock market news analyser who summarizes news articles of a particular company and predicts share price in the near future, with an opinion on whether to buy, sell or hold. Give your response in less than 200 words. Opinion should be only 1 word. Use this JSON schema: {\"Summary\": str, \"Opinion:\": str}', generation_config={"response_mime_type": "application/json"})
		
		to_date = datetime.now()

		from_date = to_date - relativedelta(months=9)

		# Format the dates
		to_date_str = to_date.strftime("%Y-%m-%d")
		from_date_str = from_date.strftime("%Y-%m-%d")


		with open('news_summary.txt', 'w', encoding='utf-8') as file:
			articles = self.finnhub_client.company_news(ticker, _from=from_date_str, to=to_date_str)
			
			for article in articles:
				file.write(article['headline'])
				file.write('\n')
				file.write(article['summary'])
				date = datetime.fromtimestamp(article['datetime'])
				file.write(f'\nPublished on {date.strftime("%Y-%m-%d")}\n\n')
				file.write('\n')


		with open('news_summary.txt', 'r', encoding='utf-8') as file:
			news = file.read()

		response = model.generate_content(news)

		# to_markdown(response.text)

		# for chunk in response:
		# 	print(chunk.text)
		# 	print("_"*80)

		return response
	

	def userRecommendation(self, profile):
		model = genai.GenerativeModel(
			'gemini-1.5-flash', 
			system_instruction='Give a list of 5 companies which have the best stock performance in that sector.')
		

		response = model.generate_content(profile)

		# for chunk in response:
		# 	print(chunk.text)
		# 	print("_"*80)

		return response


stocks = Stocks()
stocks.stockOpinion('INTC')

stocks.userRecommendation('Automotive Manufacturing industry')
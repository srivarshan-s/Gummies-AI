from http.client import HTTPException
from flask import Flask, request, jsonify, send_file
import os
from bson import ObjectId
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
import certifi
import finnhub
import requests
import matplotlib
import matplotlib.pyplot as plt
import datetime
from io import BytesIO
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

finn_api_key = 'cqsqsb1r01qsc7l9vj0gcqsqsb1r01qsc7l9vj10'
finnhub_client = finnhub.Client(api_key=finn_api_key)

alpha_api_key = 'U7NN2DLYMXQNXBZW'

uri = "mongodb+srv://doofenshmirtz5inc:doofenshitz@cluster0.v2avpdc.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
client = MongoClient(uri, server_api=ServerApi('1'), tlsCAFile=certifi.where())

db = client['gummies']
user_collection = db['users']
company_collection = db['startups']
company_form_collection = db['startup_forms']
user_form_collection = db['user_form']
watchlist_collection = db['watchlist']

matplotlib.use('Agg')


@app.route('/upload', methods=['POST'])
def upload_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['image']

    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    if file:
        filename = file.filename
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
        return jsonify({'message': 'Image uploaded successfully', 'file_path': file_path}), 200


@ app.route('/autocomplete', methods=['GET'])
def search():
    query = request.args.get('query')
    if not query:
        return jsonify({'error': 'Missing query parameter'}), 400
    try:
        result = finnhub_client.symbol_lookup(query)
        filtered_result = {
            'count': 0,
            'result': []
        }

        for item in result.get('result', []):
            if '.' not in item.get('symbol', ''):
                filtered_result['result'].append(item)

        filtered_result['count'] = len(filtered_result['result'])

        return jsonify(filtered_result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/news', methods=['GET'])
def news():
    try:
        result = finnhub_client.general_news('general', min_id=0)
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/stock_details', methods=['GET'])
def stock_details():
    query = request.args.get('query')
    if not query:
        return jsonify({'error': 'Missing query parameter'}), 400
    try:
        # Get company profile
        company_profile = finnhub_client.company_profile2(symbol=query)

        # Get stock quote
        stock_quote = finnhub_client.quote(query)

        financial = finnhub_client.company_basic_financials(query, 'all')

        # Combine the two results into one dictionary
        result = {
            'company_profile': company_profile,
            'stock_quote': stock_quote,
            'financial': financial
        }

        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/quote_details', methods=['GET'])
def quote_details():
    query = request.args.get('query')
    if not query:
        return jsonify({'error': 'Missing query parameter'}), 400
    try:
        stock_quote = finnhub_client.quote(query)

        return jsonify(stock_quote)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/store_company_data', methods=['POST'])
def store_company_data():
    try:
        # Get the JSON data from the request
        company_data = request.json

        # Insert the data into MongoDB
        result = company_form_collection.insert_one(company_data)

        # Return the ID of the inserted document
        return jsonify({'id': str(result.inserted_id)}), 201

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/store_user_form_data', methods=['POST'])
def store_user_form_data():
    try:
        # Get the JSON data from the request
        company_data = request.json

        # Insert the data into MongoDB
        result = user_form_collection.insert_one(company_data)

        # Return the ID of the inserted document
        return jsonify({'id': str(result.inserted_id)}), 201

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/get_company_data', methods=['GET'])
def get_company_data():
    try:
        # Get the query parameters from the request
        company_id = request.args.get('id')
        company_name = request.args.get('name')

        # Initialize a query dictionary
        query = {}

        if company_id:
            query['_id'] = ObjectId(company_id)

        if company_name:
            query['name'] = company_name

        company_data = company_form_collection.find_one(query)

        if company_data:
            # Convert ObjectId to string
            company_data['_id'] = str(company_data['_id'])
            return jsonify(company_data), 200
        else:
            return jsonify({'error': 'Company not found'}), 404

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/get_user_form_data', methods=['GET'])
def get_user_form_data():
    try:
        # Retrieve the user ID from the query parameters
        user_id = request.args.get('user_id')

        if not user_id:
            return jsonify({'error': 'Missing user_id parameter'}), 400

        # Find the document in the MongoDB collection by user ID
        user_form_data = user_form_collection.find_one({'user': user_id})

        if not user_form_data:
            return jsonify({'error': 'User data not found'}), 404

        # Convert ObjectId to string
        user_form_data['_id'] = str(user_form_data['_id'])

        return jsonify(user_form_data), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/remove_from_watchlist', methods=['DELETE'])
def remove_from_watchlist():
    user = request.args.get('user')
    symbol = request.args.get('symbol')

    if not user or not symbol:
        return jsonify({"error": "User and symbol are required"}), 400

    try:
        # Find the user's watchlist
        watchlist_entry = watchlist_collection.find_one({"user": user})

        if not watchlist_entry:
            return jsonify({"error": "Watchlist not found"}), 404

        # Remove the symbol from the watchlist
        updated_companies = [
            company for company in watchlist_entry["selected_companies"]
            if company["symbol"] != symbol
        ]

        # Update the watchlist in the database
        watchlist_collection.update_one(
            {"user": user},
            {"$set": {"selected_companies": updated_companies}}
        )

        return jsonify({"message": "Company removed from watchlist"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/edit_user', methods=['POST'])
def edit_user():
    try:
        # Get the JSON data from the request
        data = request.json
        user_id = data.get('userId')
        new_display_name = data.get('userData', {}).get('name')
        new_email = data.get('userData', {}).get('email')

        print(data)
        if not user_id:
            return jsonify({'error': 'Missing userId parameter'}), 400

        update_fields = {}
        if new_display_name:
            update_fields['displayName'] = new_display_name
        if new_email:
            update_fields['email'] = new_email

        if not update_fields:
            return jsonify({'error': 'No fields to update provided'}), 400

        # Update the user document in the collection
        result = user_collection.update_one(
            {'userId': user_id},
            {'$set': update_fields}
        )

        if result.matched_count == 0:
            return jsonify({'error': 'User not found'}), 404

        return jsonify({'message': 'User updated successfully'}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/store_user', methods=['POST'])
def store_user():
    try:
        data = request.json
        result = user_collection.insert_one(data)
        print(result.inserted_id)
        user_id = str(result.inserted_id)
        return jsonify({'id': user_id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/store_company', methods=['POST'])
def store_company():
    try:
        data = request.json
        result = company_collection.insert_one(data)
        print(result.inserted_id)
        company_id = str(result.inserted_id)
        return jsonify({'id': company_id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/add_to_watchlist', methods=['POST'])
def add_to_watchlist():
    try:
        data = request.json

        user = data.get('user')
        new_symbols = data.get('selected_companies', [])

        if not user:
            return jsonify({'error': 'User ID is required'}), 400

        # Step 1: Check if the user already has a watchlist
        watchlist_entry = watchlist_collection.find_one({'user': user})

        if watchlist_entry:
            # Step 2: User exists, append new symbols if they are not already in the watchlist
            existing_symbols = watchlist_entry.get('selected_companies', [])
            for symbol in new_symbols:
                if symbol not in existing_symbols:
                    existing_symbols.append(symbol)

            # Step 3: Update the watchlist with the new set of symbols
            watchlist_collection.update_one(
                {'user': user},
                {'$set': {'selected_companies': existing_symbols}}
            )
            return jsonify({'message': 'Watchlist updated successfully!'}), 200

        else:
            # Step 4: User does not exist, create a new watchlist entry
            watchlist_entry = {
                'user': user,
                'selected_companies': new_symbols,
            }
            watchlist_collection.insert_one(watchlist_entry)
            return jsonify({'message': 'Watchlist created successfully!'}), 201

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/get_watchlist', methods=['GET'])
def get_watchlist():
    try:
        user_id = request.args.get('user_id') or 'jakW0e77MlOvwDBlKb5HvpEwmcC3'
        if not user_id:
            return jsonify({'error': 'user_id is required'}), 400

        watchlist = watchlist_collection.find_one({'user': user_id})
        if not watchlist:
            return jsonify({'error': 'Watchlist not found'}), 404

        watchlist['_id'] = str(watchlist['_id'])
        return jsonify(watchlist), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/is_in_watchlist', methods=['GET'])
def is_in_watchlist():
    try:
        user = request.args.get('user')
        symbol = request.args.get('symbol')

        if not user or not symbol:
            return jsonify({'error': 'User and symbol are required'}), 400

        # Check if the user exists and if the symbol is in their watchlist
        watchlist_entry = watchlist_collection.find_one({'user': user})

        if watchlist_entry and symbol in watchlist_entry.get('selected_companies', []):
            return jsonify({'in_watchlist': True}), 200
        else:
            return jsonify({'in_watchlist': False}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/get_user_data', methods=['GET'])
def get_user_data():
    try:
        user_id = request.args.get('user_id')
        if not user_id:
            return jsonify({'error': 'user_id is required'}), 400

        data = user_collection.find_one({'userId': user_id})
        if not data:
            return jsonify({'error': 'User data not found'}), 404

        data['_id'] = str(data['_id'])
        return jsonify(data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/generate_chart_icon', methods=['GET'])
def generate_chart_icon():
    ticker = request.args.get('ticker')
    output_dir = 'charts'

    os.makedirs(output_dir, exist_ok=True)

    if not ticker:
        return jsonify({'error': 'Missing ticker parameter'}), 400

    try:
        to_date = datetime.datetime.today().strftime('%Y-%m-%d')

        # Get the date one month ago
        from_date = (datetime.datetime.today() -
                     datetime.timedelta(days=30)).strftime('%Y-%m-%d')

        # Construct the URL with dynamic dates
        url = f"https://api.polygon.io/v2/aggs/ticker/{ticker}/range/1/day/{from_date}/{to_date}?adjusted=true&sort=asc&apiKey=pXmH80NXQjAduR22FxXVpEh4jWk5pWVc"

        response = requests.get(url)
        data = response.json()

        stock_quote = finnhub_client.quote(ticker)

        change_percent = stock_quote['dp']

        if 'results' not in data:
            return jsonify({'error': 'No data found for the given ticker'}), 404

        # Step 2: Parse the data
        dates = []
        closing_prices = []

        for result in data['results']:
            date = datetime.datetime.fromtimestamp(
                result['t'] / 1000).strftime('%Y-%m-%d')
            dates.append(date)
            closing_prices.append(result['c'])

        # Step 3: Plot the graph
        fig, ax = plt.subplots(figsize=(10, 5))

        # Remove background
        fig.patch.set_alpha(0)
        ax.patch.set_alpha(0)

        line_color = 'green' if change_percent >= 0 else 'red'

        # Plot the graph
        ax.plot(dates, closing_prices, color=line_color,
                linestyle='solid', linewidth=15)

        # Remove title, labels, grid, and axis
        ax.set_title('')
        ax.set_xlabel('')
        ax.set_ylabel('')
        ax.grid(False)

        # Remove the axes
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['left'].set_visible(False)
        ax.spines['bottom'].set_visible(False)

        # Save the plot to a BytesIO object
        img = BytesIO()
        plt.savefig(img, format='png', bbox_inches='tight',
                    pad_inches=0, transparent=True)
        img.seek(0)
        plt.close()

        return send_file(img, mimetype='image/png')

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/generate_chart', methods=['GET'])
def generate_chart():
    ticker = request.args.get('ticker')

    if not ticker:
        return jsonify({'error': 'Missing ticker parameter'}), 400

    try:
        # Step 1: Fetch the data
        to_date = datetime.datetime.today().strftime('%Y-%m-%d')

        # Get the date one month ago
        from_date = (datetime.datetime.today() -
                     datetime.timedelta(days=30)).strftime('%Y-%m-%d')

        # Construct the URL with dynamic dates
        url = f"https://api.polygon.io/v2/aggs/ticker/{ticker}/range/1/day/{from_date}/{to_date}?adjusted=true&sort=asc&apiKey=pXmH80NXQjAduR22FxXVpEh4jWk5pWVc"
        response = requests.get(url)
        data = response.json()

        stock_quote = finnhub_client.quote(ticker)

        change_percent = stock_quote['dp']

        if 'results' not in data:
            return jsonify({'error': 'No data found for the given ticker'}), 404

        # Step 2: Parse the data
        dates = []
        closing_prices = []

        for result in data['results']:
            date = datetime.datetime.fromtimestamp(
                result['t'] / 1000).strftime('%Y-%m-%d')
            dates.append(date)

            # Extract the closing price
            closing_prices.append(result['c'])

        # Step 3: Plot the graph
        fig, ax = plt.subplots(figsize=(10, 5))

        fig.patch.set_alpha(0)  # Set figure background to transparent
        ax.patch.set_alpha(0)

        # Plot the graph
        fig, ax = plt.subplots(figsize=(10, 5))

        # Remove background
        fig.patch.set_alpha(0)  # Set figure background to transparent
        ax.patch.set_alpha(0)  # Set axis background to transparent

        line_color = 'green' if change_percent >= 0 else 'red'

        ax.plot(dates, closing_prices, color=line_color,
                linestyle='solid', linewidth=3)

        ax.grid(True, which='both', color='gray',
                linestyle='--', linewidth=0.2)

        # Display only half of the x-axis labels
        ax.set_xticks(dates[::2])
        ax.set_xticklabels(dates[::2], rotation=45, ha="right")

        ax.spines['bottom'].set_color('white')
        ax.spines['left'].set_color('white')
        ax.xaxis.label.set_color('white')
        ax.yaxis.label.set_color('white')
        ax.tick_params(axis='x', colors='white')
        ax.tick_params(axis='y', colors='white')

        # Save the plot to a BytesIO object
        img = BytesIO()
        plt.savefig(img, format='png', bbox_inches='tight',
                    pad_inches=0, transparent=True)
        img.seek(0)
        plt.close()

        return send_file(img, mimetype='image/png')

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=3000)

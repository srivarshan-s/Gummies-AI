from flask import Flask, request, jsonify
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
import certifi
import finnhub

app = Flask(__name__)

api_key = 'cmr19q1r01ql2lmtdgi0cmr19q1r01ql2lmtdgig'
finnhub_client = finnhub.Client(api_key=api_key)

uri = "mongodb+srv://doofenshmirtz5inc:doofenshitz@cluster0.v2avpdc.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
client = MongoClient(uri, server_api=ServerApi('1'), tlsCAFile=certifi.where())

db = client['gummies']
user_collection = db['users']
watchlist_collection = db['watchlist']


@ app.route('/autocomplete', methods=['GET'])
def search():
    query = request.args.get('query')
    if not query:
        return jsonify({'error': 'Missing query parameter'}), 400

    try:
        result = finnhub_client.symbol_lookup(query)
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@ app.route('/news', methods=['GET'])
def news():
    try:
        result = finnhub_client.general_news('general', min_id=0)
        return jsonify(result)
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


@ app.route('/add_to_watchlist', methods=['POST'])
def add_to_watchlist():
    try:
        data = request.json
        watchlist_collection.insert_one(data)
        return jsonify({'message': 'Watchlist added successfully!'}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/get_watchlist', methods=['GET'])
def get_watchlist():
    try:
        user_id = request.args.get('user_id')
        if not user_id:
            return jsonify({'error': 'user_id is required'}), 400

        watchlist = watchlist_collection.find_one({'user': user_id})
        if not watchlist:
            return jsonify({'error': 'Watchlist not found'}), 404

        watchlist['_id'] = str(watchlist['_id'])
        return jsonify(watchlist), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/get_user_data', methods=['GET'])
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


if __name__ == '__main__':
    app.run(debug=True)

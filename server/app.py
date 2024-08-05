from flask import Flask, request, jsonify
import finnhub

app = Flask(__name__)

api_key = 'cmr19q1r01ql2lmtdgi0cmr19q1r01ql2lmtdgig'
finnhub_client = finnhub.Client(api_key=api_key)


@app.route('/autocomplete', methods=['GET'])
def search():
    query = request.args.get('query')
    if not query:
        return jsonify({'error': 'Missing query parameter'}), 400

    try:
        result = finnhub_client.symbol_lookup(query)
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)

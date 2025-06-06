from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
from bson import ObjectId
import os
import json

app = Flask(__name__)
CORS(app)

# MongoDB Connection
client = MongoClient(os.getenv('MONGODB_URI', 'mongodb://mongodb:27017/ecommerce'))
db = client.ecommerce
products_collection = db.products

# API Key configuration
API_KEY = os.getenv("API_KEY", "123456")

def require_api_key(func):
    def wrapper(*args, **kwargs):
        key = request.headers.get("X-API-KEY")
        if key != API_KEY:
            return jsonify({"error": "Invalid API key"}), 401
        return func(*args, **kwargs)
    wrapper.__name__ = func.__name__
    return wrapper

# Helper function to convert MongoDB documents to JSON-serializable format
def convert_to_json_serializable(doc):
    if isinstance(doc, dict):
        for key, value in doc.items():
            if isinstance(value, ObjectId):
                doc[key] = str(value)
            elif isinstance(value, dict):
                doc[key] = convert_to_json_serializable(value)
            elif isinstance(value, list):
                doc[key] = [convert_to_json_serializable(item) for item in value]
    return doc

# Initialize database with sample data if empty
def initialize_db():
    if products_collection.count_documents({}) == 0:
        sample_products = [
            {"name": "Laptop", "price": 999.99, "description": "High-performance laptop"},
            {"name": "Smartphone", "price": 499.99, "description": "Latest model smartphone"}
        ]
        products_collection.insert_many(sample_products)
        print("Database initialized with sample products")

# Call initialization function
initialize_db()

@app.route('/products', methods=['GET'])
@require_api_key
def get_products():
    """Get all products from MongoDB"""
    try:
        products = list(products_collection.find())
        # Convert ObjectIds to strings
        products = [convert_to_json_serializable(product) for product in products]
        return jsonify(products)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/products', methods=['POST'])
@require_api_key
def create_product():
    """Create a new product in MongoDB"""
    try:
        if not request.is_json:
            return jsonify({"error": "Content-Type must be application/json"}), 400
        
        data = request.get_json()
        required_fields = ['name', 'price', 'description']
        
        if not all(field in data for field in required_fields):
            return jsonify({"error": "Missing required fields"}), 400
        
        product = {
            "name": data['name'],
            "price": float(data['price']),
            "description": data['description']
        }
        
        result = products_collection.insert_one(product)
        product['_id'] = str(result.inserted_id)
        return jsonify(product), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/products/<product_id>', methods=['DELETE'])
@require_api_key
def delete_product(product_id):
    """Delete a product from MongoDB by ID"""
    try:
        result = products_collection.delete_one({"_id": ObjectId(product_id)})
        if result.deleted_count == 0:
            return jsonify({"error": "Product not found"}), 404
        return jsonify({"message": "Product deleted successfully"})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True) 
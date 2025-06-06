#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Load API key from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: .env file not found. Please create a .env file with API_KEY=your_key"
  exit 1
fi

# API endpoint
API_URL="http://3.120.41.22:5000"
API_KEY="123456"

# Function to make API calls with API key
call_api() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    if [ -z "$data" ]; then
        curl -s -H "X-API-KEY: $API_KEY" -X $method "$API_URL$endpoint"
    else
        curl -s -H "X-API-KEY: $API_KEY" -H "Content-Type: application/json" -X $method -d "$data" "$API_URL$endpoint"
    fi
}

# 1. Check API is reachable and returns products
response=$(curl -s -H "X-API-KEY: $API_KEY" $API_URL/products)
echo "GET all products:"
echo "$response"
if echo "$response" | grep -q "Laptop"; then
    echo "PASS: API is reachable and returns products."
else
    echo "FAIL: API did not return expected products."
    exit 1
fi

# 2. Add a new product
add_response=$(curl -s -X POST -H "Content-Type: application/json" -H "X-API-KEY: $API_KEY" \
  -d '{"name":"TestProduct","price":123.45,"description":"Test product description"}' \
  $API_URL/products)
echo "\nPOST new product:"
echo "$add_response"
product_id=$(echo "$add_response" | python3 -c "import sys, json; print(json.load(sys.stdin).get('_id', ''))")
if [ -n "$product_id" ]; then
    echo "PASS: Product added with _id $product_id"
else
    echo "FAIL: Product was not added."
    exit 1
fi

# 3. Delete the product
if [ -n "$product_id" ]; then
    del_response=$(curl -s -X DELETE -H "X-API-KEY: $API_KEY" $API_URL/products/$product_id)
    echo "\nDELETE product:"
    echo "$del_response"
    if echo "$del_response" | grep -q "successfully"; then
        echo "PASS: Product deleted."
    else
        echo "FAIL: Product was not deleted."
        exit 1
    fi
fi

echo "\nAll tests completed and passed."

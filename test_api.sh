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

echo "1. GET all products (should return initial products):"
response=$(call_api GET "/products")
echo "$response"
if echo "$response" | grep -q "Laptop"; then
    echo -e "${GREEN}PASS: Initial products found (3)${NC}"
else
    echo -e "${RED}FAIL: Initial products not found${NC}"
fi

echo -e "\n---\n2. POST a new product:"
response=$(call_api POST "/products" '{"name":"Tablet","price":299.99,"description":"A new tablet"}')
echo "$response"
if echo "$response" | grep -q "_id"; then
    product_id=$(echo "$response" | grep -o '"_id":"[^"]*' | cut -d'"' -f4)
    echo -e "${GREEN}PASS: New product created with _id $product_id${NC}"
else
    echo -e "${RED}FAIL: Failed to create new product${NC}"
fi

echo -e "\n---\n3. GET all products (should include the new product):"
response=$(call_api GET "/products")
echo "$response"
if echo "$response" | grep -q "Tablet"; then
    echo -e "${GREEN}PASS: Product count increased to 4${NC}"
else
    echo -e "${RED}FAIL: New product not found in list${NC}"
fi

echo -e "\n---\n4. DELETE the new product:"
response=$(call_api DELETE "/products/$product_id")
echo "$response"
if echo "$response" | grep -q "successfully"; then
    echo -e "${GREEN}PASS: Product deleted${NC}"
else
    echo -e "${RED}FAIL: Failed to delete product${NC}"
fi

echo -e "\n---\n5. GET all products (should NOT include the deleted product):"
response=$(call_api GET "/products")
echo "$response"
if ! echo "$response" | grep -q "Tablet"; then
    echo -e "${GREEN}PASS: Product count returned to 3${NC}"
else
    echo -e "${RED}FAIL: Deleted product still found in list${NC}"
fi

echo -e "\n---\n6. Try to DELETE a non-existent product (should return error):"
response=$(call_api DELETE "/products/123456789012345678901234")
echo "$response"
if echo "$response" | grep -q "not found"; then
    echo -e "${GREEN}PASS: Correct error for non-existent product${NC}"
else
    echo -e "${RED}FAIL: Unexpected response for non-existent product${NC}"
fi

echo -e "\n---\n7. Try to access API without key (should return error):"
response=$(curl -s -X GET "$API_URL/products")
echo "$response"
if echo "$response" | grep -q "Invalid API key"; then
    echo -e "${GREEN}PASS: Correct error for missing API key${NC}"
else
    echo -e "${RED}FAIL: Unexpected response for missing API key${NC}"
fi

echo -e "\n---\n8. Try to access API with wrong key (should return error):"
response=$(curl -s -H "X-API-KEY: wrong_key" -X GET "$API_URL/products")
echo "$response"
if echo "$response" | grep -q "Invalid API key"; then
    echo -e "${GREEN}PASS: Correct error for invalid API key${NC}"
else
    echo -e "${RED}FAIL: Unexpected response for invalid API key${NC}"
fi

echo -e "\n---\nAll tests completed."

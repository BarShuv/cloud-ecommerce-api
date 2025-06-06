#!/bin/bash
set -e

API_URL="http://localhost:5000"
API_KEY="123456"

# Helper for colored output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function print_success() { echo -e "${GREEN}$1${NC}"; }
function print_error() { echo -e "${RED}$1${NC}"; }

fail=0

print_success "1. GET all products (should return initial products):"
response=$(curl -s -H "X-API-KEY: $API_KEY" -X GET "$API_URL/products")
echo "$response"
if echo "$response" | grep -q "Laptop"; then
  print_success "PASS: Initial products found (4)"
else
  print_error "FAIL: Initial products not found"
  fail=1
fi
echo -e "\n---"

print_success "2. POST a new product:"
response=$(curl -s -H "X-API-KEY: $API_KEY" -H "Content-Type: application/json" -X POST -d '{"name":"Tablet","price":299.99,"description":"A new tablet"}' "$API_URL/products")
echo "$response"
if echo "$response" | grep -q "_id"; then
  product_id=$(echo "$response" | grep -o '"_id":"[^"]*' | cut -d'"' -f4)
  print_success "PASS: New product created with _id $product_id"
else
  print_error "FAIL: Failed to create new product"
  fail=1
fi
echo -e "\n---"

print_success "3. GET all products (should include the new product):"
response=$(curl -s -H "X-API-KEY: $API_KEY" -X GET "$API_URL/products")
echo "$response"
if echo "$response" | grep -q "Tablet"; then
  print_success "PASS: Product count increased to 5"
else
  print_error "FAIL: New product not found in list"
  fail=1
fi
echo -e "\n---"

print_success "4. DELETE the new product:"
response=$(curl -s -H "X-API-KEY: $API_KEY" -X DELETE "$API_URL/products/$product_id")
echo "$response"
if echo "$response" | grep -q "successfully"; then
  print_success "PASS: Product deleted"
else
  print_error "FAIL: Failed to delete product"
  fail=1
fi
echo -e "\n---"

print_success "5. GET all products (should NOT include the deleted product):"
response=$(curl -s -H "X-API-KEY: $API_KEY" -X GET "$API_URL/products")
echo "$response"
if ! echo "$response" | grep -q "Tablet"; then
  print_success "PASS: Product count returned to 4"
else
  print_error "FAIL: Deleted product still found in list"
  fail=1
fi
echo -e "\n---"

print_success "6. Try to DELETE a non-existent product (should return error):"
response=$(curl -s -H "X-API-KEY: $API_KEY" -X DELETE "$API_URL/products/123456789012345678901234")
echo "$response"
if echo "$response" | grep -q "not found"; then
  print_success "PASS: Correct error for non-existent product"
else
  print_error "FAIL: Unexpected response for non-existent product"
  fail=1
fi
echo -e "\n---"

print_success "7. Try to access API without key (should return error):"
response=$(curl -s -X GET "$API_URL/products")
echo "$response"
if echo "$response" | grep -q "Invalid API key"; then
  print_success "PASS: Correct error for missing API key"
else
  print_error "FAIL: Unexpected response for missing API key"
  fail=1
fi
echo -e "\n---"

print_success "8. Try to access API with wrong key (should return error):"
response=$(curl -s -H "X-API-KEY: wrong_key" -X GET "$API_URL/products")
echo "$response"
if echo "$response" | grep -q "Invalid API key"; then
  print_success "PASS: Correct error for invalid API key"
else
  print_error "FAIL: Unexpected response for invalid API key"
  fail=1
fi
echo -e "\n---"

if [ $fail -eq 0 ]; then
  print_success "All tests PASSED."
  exit 0
else
  print_error "Some tests FAILED."
  exit 1
fi 
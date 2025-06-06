#!/bin/bash
set -e

API_URL="http://3.120.41.22:5000/products"

# Helper for colored output
green='\033[0;32m'
red='\033[0;31m'
nc='\033[0m'

function print_success() { echo -e "${green}$1${nc}"; }
function print_error() { echo -e "${red}$1${nc}"; }

fail=0

print_success "1. GET all products (should return initial products):"
GET1=$(curl -s $API_URL)
echo "$GET1" | jq .
COUNT1=$(echo "$GET1" | jq 'length')
if [ "$COUNT1" -ge 2 ]; then
  print_success "PASS: Initial products found ($COUNT1)"
else
  print_error "FAIL: Expected at least 2 initial products, got $COUNT1"
  fail=1
fi
echo -e "\n---"

print_success "2. POST a new product:"
NEW_PRODUCT=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"name":"Tablet","price":299.99,"description":"A new tablet"}' $API_URL)
echo $NEW_PRODUCT | jq .
NEW_ID=$(echo $NEW_PRODUCT | jq -r '._id')
if [ "$NEW_ID" != "null" ]; then
  print_success "PASS: New product created with _id $NEW_ID"
else
  print_error "FAIL: New product was not created"
  fail=1
fi
echo -e "\n---"

print_success "3. GET all products (should include the new product):"
GET2=$(curl -s $API_URL)
echo "$GET2" | jq .
COUNT2=$(echo "$GET2" | jq 'length')
if [ "$COUNT2" -eq $((COUNT1+1)) ]; then
  print_success "PASS: Product count increased to $COUNT2"
else
  print_error "FAIL: Product count did not increase as expected"
  fail=1
fi
echo -e "\n---"

print_success "4. DELETE the new product:"
DEL=$(curl -s -X DELETE $API_URL/$NEW_ID)
echo $DEL | jq .
MSG=$(echo $DEL | jq -r '.message')
if [[ "$MSG" == *"deleted"* ]]; then
  print_success "PASS: Product deleted"
else
  print_error "FAIL: Product was not deleted"
  fail=1
fi
echo -e "\n---"

print_success "5. GET all products (should NOT include the deleted product):"
GET3=$(curl -s $API_URL)
echo "$GET3" | jq .
COUNT3=$(echo "$GET3" | jq 'length')
if [ "$COUNT3" -eq "$COUNT1" ]; then
  print_success "PASS: Product count returned to $COUNT3"
else
  print_error "FAIL: Product count did not return to original"
  fail=1
fi
echo -e "\n---"

print_success "6. Try to DELETE a non-existent product (should return error):"
DEL2=$(curl -s -X DELETE $API_URL/000000000000000000000000)
echo $DEL2 | jq .
ERR=$(echo $DEL2 | jq -r '.error')
if [[ "$ERR" == *"not found"* ]]; then
  print_success "PASS: Correct error for non-existent product"
else
  print_error "FAIL: Did not get expected error for non-existent product"
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
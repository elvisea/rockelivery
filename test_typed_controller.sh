#!/bin/bash

echo "🧪 Testando TypedController..."
echo "================================"

BASE_URL="http://localhost:4000/api/typed"

echo "1️⃣ Testando Typespecs..."
curl -s "$BASE_URL/users/123" | jq '.'

echo -e "\n2️⃣ Testando Structs..."
curl -s "$BASE_URL/users-struct/456" | jq '.'

echo -e "\n3️⃣ Testando Pattern Matching (sucesso)..."
curl -s -X POST "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"user": {"name": "Elvis", "email": "elvis@test.com", "age": 30}}' | jq '.'

echo -e "\n4️⃣ Testando Pattern Matching (erro)..."
curl -s -X POST "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"user": {"name": "Elvis", "email": "invalid", "age": "wrong"}}' | jq '.'

echo -e "\n5️⃣ Testando Validação Customizada..."
curl -s "$BASE_URL/users-validation/999" | jq '.'

echo -e "\n6️⃣ Testando Tipos Centralizados..."
curl -s -X POST "$BASE_URL/users-centralized" \
  -H "Content-Type: application/json" \
  -d '{"name": "Elvis", "email": "elvis@test.com", "age": 30}' | jq '.'

echo -e "\n7️⃣ Comparando Abordagens..."
curl -s "$BASE_URL/compare" | jq '.'

echo -e "\n✅ Testes concluídos!"

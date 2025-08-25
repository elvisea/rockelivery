# 🧪 Comandos CURL para testar o TypedController

## 🚀 **Pré-requisito: Servidor rodando**
```bash
# Iniciar o servidor Phoenix
mix phx.server
# ou
iex -S mix phx.server
```

---

## 📋 **ABORDAGEM 1: TYPESPECS (@type + @spec)**

### GET - Usuário com typespecs
```bash
curl -X GET "http://localhost:4000/api/typed/users/123" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

**Resultado esperado:**
```json
{
  "id": 123,
  "name": "Elvis Presley",
  "email": "elvis@graceland.com",
  "active": true,
  "created_at": "2024-01-15T10:30:45.123456Z"
}
```

---

## 🏗️ **ABORDAGEM 2: STRUCTS (Tipos estruturados)**

### GET - Usuário com struct
```bash
curl -X GET "http://localhost:4000/api/typed/users-struct/456" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

**Resultado esperado:**
```json
{
  "id": 456,
  "name": "Elvis Presley",
  "email": "elvis@graceland.com",
  "active": true,
  "created_at": "2024-01-15T10:30:45.123456Z",
  "metadata": {
    "source": "api",
    "version": "1.0"
  }
}
```

---

## 🎯 **ABORDAGEM 3: PATTERN MATCHING + GUARDS**

### POST - Criar usuário com validação automática
```bash
curl -X POST "http://localhost:4000/api/typed/users" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "user": {
      "name": "Elvis Presley",
      "email": "elvis@graceland.com",
      "age": 30
    }
  }'
```

**Resultado esperado (sucesso):**
```json
{
  "id": 789,
  "name": "Elvis Presley",
  "email": "elvis@graceland.com",
  "age": 30,
  "status": "created",
  "created_at": "2024-01-15T10:30:45.123456Z"
}
```

### POST - Teste com dados inválidos (deve falhar)
```bash
curl -X POST "http://localhost:4000/api/typed/users" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "user": {
      "name": "Elvis",
      "email": "invalid-email",
      "age": "not-a-number"
    }
  }'
```

**Resultado esperado (erro):**
```json
{
  "error": "Dados inválidos",
  "code": 400,
  "details": "Formato esperado: {user: {name: string, email: string, age: integer}}",
  "received": {
    "user": {
      "name": "Elvis",
      "email": "invalid-email",
      "age": "not-a-number"
    }
  }
}
```

---

## 🔍 **ABORDAGEM 4: VALIDAÇÃO CUSTOMIZADA**

### GET - Usuário com validação customizada (sucesso)
```bash
curl -X GET "http://localhost:4000/api/typed/users-validation/999" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

**Resultado esperado:**
```json
{
  "id": 999,
  "name": "Elvis Presley",
  "email": "elvis@graceland.com",
  "active": true,
  "created_at": "2024-01-15T10:30:45.123456Z"
}
```

### GET - Usuário com validação customizada (erro)
```bash
curl -X GET "http://localhost:4000/api/typed/users-validation/invalid-id" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

**Resultado esperado:**
```json
{
  "error": "ID inválido: deve ser um número positivo",
  "code": 400,
  "details": "ID deve ser um número positivo"
}
```

---

## 🎛️ **ABORDAGEM 5: TIPOS CENTRALIZADOS**

### POST - Criar usuário com tipos centralizados (sucesso)
```bash
curl -X POST "http://localhost:4000/api/typed/users-centralized" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "Elvis Presley",
    "email": "elvis@graceland.com",
    "age": 30
  }'
```

**Resultado esperado:**
```json
{
  "data": {
    "id": 123,
    "name": "Elvis Presley",
    "email": "elvis@graceland.com",
    "active": true,
    "created_at": "2024-01-15T10:30:45.123456Z"
  },
  "status": "ok",
  "message": "Usuário criado com sucesso!",
  "timestamp": "2024-01-15T10:30:45.123456Z"
}
```

### POST - Criar usuário com tipos centralizados (erro)
```bash
curl -X POST "http://localhost:4000/api/typed/users-centralized" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "",
    "email": "invalid-email",
    "age": -5
  }'
```

**Resultado esperado:**
```json
{
  "error": "Parâmetros inválidos: esperado %{name: string, email: string, age: positive_integer}",
  "code": 400,
  "details": "Verifique os dados enviados",
  "timestamp": "2024-01-15T10:30:45.123456Z"
}
```

---

## 📊 **COMPARAÇÃO DE ABORDAGENS**

### GET - Comparação de todas as abordagens
```bash
curl -X GET "http://localhost:4000/api/typed/compare" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

**Resultado esperado:**
```json
{
  "message": "Comparação de abordagens de tipagem",
  "approaches": {
    "typescript": {
      "interfaces": "Define estrutura em tempo de compilação",
      "runtime_safety": false,
      "exemplo": "interface UserResponse { id: number; name: string; }"
    },
    "elixir_typespecs": {
      "definicao": "@type user_response :: %{id: integer(), name: String.t()}",
      "runtime_safety": false,
      "uso": "Documentação + análise estática com Dialyzer"
    },
    "elixir_structs": {
      "definicao": "defstruct [:id, :name, :email]",
      "runtime_safety": true,
      "uso": "Estrutura garantida + pattern matching"
    },
    "elixir_pattern_matching": {
      "definicao": "def func(conn, %{\"name\" => name}) when is_binary(name)",
      "runtime_safety": true,
      "uso": "Validação automática na assinatura da função"
    },
    "elixir_custom_validation": {
      "definicao": "Funções que retornam {:ok, data} | {:error, reason}",
      "runtime_safety": true,
      "uso": "Validação explícita com tipos de retorno"
    }
  },
  "recomendacao": "Use structs + pattern matching para máxima segurança em runtime"
}
```

---

## 🧪 **SCRIPT DE TESTE AUTOMATIZADO**

### Criar arquivo de teste
```bash
# Salvar como test_typed_controller.sh
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
```

### Executar script
```bash
chmod +x test_typed_controller.sh
./test_typed_controller.sh
```

---

## 📝 **NOTAS IMPORTANTES:**

1. **Servidor deve estar rodando** em `localhost:4000`
2. **jq** é opcional (formata JSON) - instale com `sudo apt install jq`
3. **Todos os testes** mostram logs no console do servidor
4. **Pattern matching** é a abordagem mais poderosa
5. **Structs** garantem estrutura em runtime
6. **Tipos centralizados** facilitam reutilização

---

## 🎯 **ORDEM RECOMENDADA DE TESTE:**

1. **Abordagem 2** (Structs) - Mais robusta
2. **Abordagem 3** (Pattern Matching) - Mais flexível  
3. **Abordagem 5** (Tipos Centralizados) - Mais organizada
4. **Abordagem 1** (Typespecs) - Para documentação
5. **Abordagem 4** (Validação Customizada) - Para casos específicos

**Divirta-se testando! 🚀**

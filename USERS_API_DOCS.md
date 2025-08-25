# 🚀 **API de Usuários - Rockelivery**

## 📋 **Visão Geral**

Esta API demonstra a implementação dos **princípios SOLID** no Phoenix/Elixir, especificamente o **princípio de responsabilidade única**. Cada controller tem uma responsabilidade específica e bem definida.

## 🏗️ **Arquitetura SOLID**

### **Princípio da Responsabilidade Única (SRP)**
- **`UserCreateController`**: Responsável APENAS pela criação de usuários
- **`UserUpdateController`**: Responsável APENAS pela edição de usuários
- **`UserCreateInput`**: Responsável APENAS pela validação de entrada na criação
- **`UserUpdateInput`**: Responsável APENAS pela validação de entrada na edição
- **`UserOutput`**: Responsável APENAS pela validação de saída

## 📡 **Endpoints**

### **1. Criar Usuário**
```http
POST /api/users
Content-Type: application/json

{
  "user": {
    "name": "João Silva",
    "email": "joao@email.com",
    "age": 25,
    "bio": "Desenvolvedor Elixir"
  }
}
```

**Resposta de Sucesso (201):**
```json
{
  "data": {
    "id": 1234,
    "name": "João Silva",
    "email": "joao@email.com",
    "age": 25,
    "bio": "Desenvolvedor Elixir",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  "message": "Usuário criado com sucesso",
  "status": "success",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### **2. Atualizar Usuário**
```http
PUT /api/users/123
Content-Type: application/json

{
  "user": {
    "name": "João Silva Atualizado",
    "age": 26
  }
}
```

**Resposta de Sucesso (200):**
```json
{
  "data": {
    "id": 123,
    "name": "João Silva Atualizado",
    "email": "existente@email.com",
    "age": 26,
    "bio": "Bio existente",
    "created_at": "2024-01-14T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  "message": "Usuário atualizado com sucesso",
  "status": "success",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## ✅ **Validações de Entrada**

### **Campos Obrigatórios (Criação)**
- `name`: String (2-100 caracteres, apenas letras e espaços)
- `email`: String (5-255 caracteres, formato válido de email)
- `age`: Integer (1-149)

### **Campos Opcionais**
- `bio`: String (máximo 500 caracteres)

### **Validações Customizadas**
- **Nome**: Apenas letras e espaços (suporte a acentos)
- **Email**: Formato válido com @ e domínio
- **Idade**: Número positivo entre 1 e 149

## 🔍 **Validações de Saída**

Todos os dados retornados passam por validação usando o schema `UserOutput`:
- Verificação de tipos
- Validação de campos obrigatórios
- Garantia de estrutura consistente

## 📊 **Códigos de Status HTTP**

| Status | Descrição | Cenário |
|--------|-----------|---------|
| **201** | Created | Usuário criado com sucesso |
| **200** | OK | Usuário atualizado com sucesso |
| **400** | Bad Request | Parâmetros inválidos ou ID malformado |
| **422** | Unprocessable Entity | Dados de entrada inválidos |
| **500** | Internal Server Error | Erro na validação de saída |

## 🧪 **Testes**

### **Executar Testes**
```bash
# Testar apenas os controllers de usuário
mix test test/rockelivery_web/controllers/user_create_controller_test.exs
mix test test/rockelivery_web/controllers/user_update_controller_test.exs

# Testar tudo
mix test
```

### **Cobertura de Testes**
- ✅ Criação com dados válidos
- ✅ Criação com dados inválidos
- ✅ Atualização com dados válidos
- ✅ Atualização com dados parciais
- ✅ Validação de ID inválido
- ✅ Validação de formato de dados
- ✅ Campos opcionais

## 🎯 **Exemplos de Uso**

### **Criar Usuário (cURL)**
```bash
curl -X POST http://localhost:4000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "Maria Santos",
      "email": "maria@email.com",
      "age": 28,
      "bio": "Designer UX/UI"
    }
  }'
```

### **Atualizar Usuário (cURL)**
```bash
curl -X PUT http://localhost:4000/api/users/123 \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "age": 29,
      "bio": "Designer UX/UI Senior"
    }
  }'
```

## 🏛️ **Estrutura de Arquivos**

```
lib/rockelivery/
├── users/
│   ├── schemas/
│   │   ├── user_create_input.ex    # Validação entrada criação
│   │   ├── user_update_input.ex    # Validação entrada edição
│   │   └── user_output.ex          # Validação saída
│   └── types.ex                    # Tipos centralizados
└── rockelivery_web/
    └── controllers/
        ├── user_create_controller.ex  # Controller criação
        └── user_update_controller.ex  # Controller edição
```

## 🔧 **Benefícios da Arquitetura**

| Aspecto | Benefício |
|---------|-----------|
| **Manutenibilidade** | Cada módulo tem uma responsabilidade clara |
| **Testabilidade** | Fácil testar cada funcionalidade isoladamente |
| **Reutilização** | Schemas podem ser reutilizados em outros controllers |
| **Escalabilidade** | Fácil adicionar novos controllers seguindo o padrão |
| **Legibilidade** | Código claro e fácil de entender |

## 🚀 **Próximos Passos**

1. **Adicionar autenticação** (JWT, OAuth)
2. **Implementar camada de serviço** (business logic)
3. **Adicionar persistência** (Ecto + PostgreSQL)
4. **Implementar cache** (Redis)
5. **Adicionar logs estruturados**
6. **Implementar rate limiting**

---

**🎓 Esta implementação é para fins didáticos, demonstrando as melhores práticas do Phoenix/Elixir seguindo os princípios SOLID!**

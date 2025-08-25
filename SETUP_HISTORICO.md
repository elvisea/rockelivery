# 📋 **Histórico de Setup - Rockelivery**

> **Documento de registro das etapas executadas para configuração do projeto Rockelivery**

---

## 🎯 **Objetivo do Projeto**

Desenvolvimento de uma **API REST** em **Phoenix Framework** para sistema de delivery, focado apenas no backend (sem frontend/assets).

---

## 🛠️ **Pré-requisitos Instalados**

### **1. Phoenix Framework**
```bash
# Instalação do Phoenix
mix archive.install hex phx_new
```

### **2. Ferramenta de Monitoramento de Arquivos**
```bash
# Necessário para hot reload durante desenvolvimento
sudo apt-get install inotify-tools
```

---

## 🚀 **Etapas de Configuração Executadas**

### **1. Criação do Projeto Phoenix (API Only)**
```bash
# Comando executado para criar projeto apenas backend REST
mix phx.new rockelivery --no-assets --no-html
```

**Flags utilizadas:**
- `--no-assets`: Remove dependências de esbuild, tailwind e assets
- `--no-html`: Remove views HTML (apenas JSON/API)

**O que foi gerado:**
- Estrutura básica do Phoenix
- Configuração para API REST
- Pipeline `:api` no router
- Sem templates HTML ou assets frontend

### **2. Instalação de Dependências Iniciais**
```bash
# Entrar no diretório do projeto
cd rockelivery

# Instalar dependências padrão
mix deps.get
```

### **3. Adição do Credo (Análise de Código)**
**Edição do `mix.exs`:**
```elixir
# Adicionado em defp deps do
{:credo, "~> 1.7", only: [:dev, :test], runtime: false}
```

**Instalação da nova dependência:**
```bash
mix deps.get
```

### **4. Configuração do PostgreSQL via Docker**
**Arquivo criado:** `docker-compose.yml`
```yaml
services:
  postgres:
    image: postgres:latest
    container_name: rockelivery_postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: rockelivery_dev
      POSTGRES_INITDB_ARGS: "--encoding=UTF8"
    ports:
      - "5433:5432"  # Porta customizada para evitar conflito
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - rockelivery_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d rockelivery_dev"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
    driver: local

networks:
  rockelivery_network:
    driver: bridge
```

**Configuração atualizada em `config/dev.exs`:**
```elixir
config :rockelivery, Rockelivery.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5433,  # Porta customizada
  database: "rockelivery_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```

### **5. Inicialização do Banco de Dados**
```bash
# Subir PostgreSQL no Docker
docker compose up -d

# Criar banco, executar migrações e seeds
mix ecto.setup
```

**O que `mix ecto.setup` faz:**
- `mix ecto.create` - Cria o banco de dados
- `mix ecto.migrate` - Executa migrações pendentes
- `mix run priv/repo/seeds.exs` - Executa seeds (se existir)

### **6. Configuração do Credo**
```bash
# Gerar arquivo de configuração do Credo
mix credo gen.config
```

**Personalização aplicada em `.credo.exs`:**
```elixir
# ANTES (linha original)
{Credo.Check.Readability.ModuleDoc, []}

# DEPOIS (desabilitado)
{Credo.Check.Readability.ModuleDoc, false}
```

**Motivo:** Desabilitar obrigatoriedade de documentação de módulos durante desenvolvimento inicial.

### **7. Inicialização do Servidor**
```bash
# Iniciar servidor Phoenix
mix phx.server
```

**Resultado:**
- Servidor rodando em `http://localhost:4000`
- API REST funcional
- PostgreSQL conectado via Docker na porta 5433

---

## 📁 **Estrutura Final do Projeto**

```
rockelivery/
├── config/
│   ├── dev.exs              # Config desenvolvimento (DB porta 5433)
│   ├── test.exs             # Config testes
│   └── runtime.exs          # Config produção
├── lib/
│   ├── rockelivery/         # Contextos e lógica de negócio
│   ├── rockelivery_web/     # Controllers, views, router
│   └── rockelivery.ex       # Módulo principal
├── priv/
│   └── repo/                # Migrações e seeds
├── test/                    # Testes automatizados
├── docker-compose.yml       # PostgreSQL containerizado
├── init.sql                 # Script inicialização DB
├── .credo.exs              # Configuração análise código
├── mix.exs                 # Dependências e configuração
└── DOCKER_README.md        # Documentação Docker
```

---

## 🔧 **Comandos de Desenvolvimento**

### **Docker (PostgreSQL)**
```bash
# Iniciar banco
docker compose up -d

# Parar banco
docker compose down

# Logs do banco
docker compose logs postgres

# Conectar ao banco
docker compose exec postgres psql -U postgres -d rockelivery_dev
```

### **Phoenix**
```bash
# Servidor desenvolvimento
mix phx.server

# Servidor interativo
iex -S mix phx.server

# Testes
mix test

# Análise de código
mix credo

# Banco de dados
mix ecto.create
mix ecto.migrate
mix ecto.rollback
```

---

## 🎯 **Configurações Importantes**

### **Banco de Dados**
- **Host:** localhost
- **Porta:** 5433 (Docker) → 5432 (interno container)
- **Database:** rockelivery_dev
- **User/Pass:** postgres/postgres

### **Servidor Phoenix**
- **URL:** http://localhost:4000
- **Modo:** API Only (sem HTML/Assets)
- **Pipeline:** `:api` (accepts JSON)

### **Ferramentas de Qualidade**
- **Credo:** Análise estática de código
- **ExUnit:** Framework de testes
- **Hot Reload:** Via inotify-tools

---

## ✅ **Checklist de Verificação**

- [x] Phoenix Framework instalado
- [x] Projeto criado com flags corretas (`--no-assets --no-html`)
- [x] PostgreSQL rodando via Docker na porta 5433
- [x] Banco de dados criado e migrações executadas
- [x] Credo configurado e funcional
- [x] Servidor Phoenix iniciando corretamente
- [x] API REST respondendo em `/api`
- [x] Hot reload funcionando durante desenvolvimento

---

## 🚨 **Observações Importantes**

1. **Porta PostgreSQL:** Usamos 5433 para evitar conflito com instalação local
2. **Modo API Only:** Projeto configurado apenas para backend REST
3. **Docker Compose:** Versão moderna sem `version:` no início
4. **Credo:** ModuleDoc desabilitado para desenvolvimento inicial
5. **Assets:** Completamente removidos (`--no-assets --no-html`)

---

## 📝 **Próximos Passos Sugeridos**

1. **Modelagem de Dados:** Definir schemas e migrações
2. **Contextos:** Criar contextos de negócio (Users, Orders, etc.)
3. **Controllers:** Implementar endpoints da API REST
4. **Testes:** Escrever testes automatizados
5. **Documentação:** Adicionar documentação da API
6. **Deploy:** Configurar para produção

---

**📅 Data de Setup:** `$(date +"%d/%m/%Y %H:%M")`
**🚀 Status:** Ambiente de desenvolvimento configurado e funcional

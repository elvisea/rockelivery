# 🐳 Docker Setup - Rockelivery

## 📋 Pré-requisitos

- Docker e Docker Compose instalados
- Porta 5433 (PostgreSQL Docker) disponível

## 🚀 Como usar

### 1. Iniciar os serviços
```bash
# Na raiz do projeto rockelivery
docker compose up -d
```

### 2. Verificar se os containers estão rodando
```bash
docker compose ps
```

### 3. Acessar o banco de dados

#### Via linha de comando:
```bash
# Conectar ao PostgreSQL
docker compose exec postgres psql -U postgres -d rockelivery_dev
```

#### Via DBeaver (ou outro cliente):
- **Host:** localhost
- **Port:** 5433
- **Database:** rockelivery_dev
- **Username:** postgres
- **Password:** postgres

### 4. Executar migrações do Phoenix
```bash
# Certifique-se que o banco está rodando
mix ecto.create
mix ecto.migrate
```

## 🔧 Comandos úteis

### Parar os serviços
```bash
docker compose down
```

### Parar e remover volumes (⚠️ apaga dados)
```bash
docker compose down -v
```

### Ver logs
```bash
# Todos os serviços
docker compose logs

# Apenas PostgreSQL
docker compose logs postgres

# Seguir logs em tempo real
docker compose logs -f postgres
```

### Reiniciar apenas o PostgreSQL
```bash
docker compose restart postgres
```

### Executar comandos no container PostgreSQL
```bash
# Executar psql interativo
docker compose exec postgres psql -U postgres -d rockelivery_dev

# Executar comando SQL direto
docker compose exec postgres psql -U postgres -d rockelivery_dev -c "SELECT version();"

# Abrir bash no container
docker compose exec postgres bash
```

### Gerenciar volumes
```bash
# Listar volumes do projeto
docker compose volumes list

# Ver informações detalhadas
docker volume inspect rockelivery_postgres_data
```

## 📊 Configurações do Banco

### Credenciais (conforme dev.exs):
- **Host:** localhost
- **Porta:** 5433 (mapeada para 5432 interno do container)
- **Database:** rockelivery_dev
- **Username:** postgres
- **Password:** postgres

### Extensões instaladas:
- `uuid-ossp` - Para gerar UUIDs
- `pgcrypto` - Para funções de criptografia

## 🔍 Troubleshooting

### Erro de porta ocupada:
```bash
# Verificar se algo está usando a porta 5433
sudo lsof -i :5433

# Se necessário, use outra porta editando docker-compose.yml
# Exemplo: "5434:5432" e atualize config/dev.exs
```

### Resetar completamente:
```bash
# Parar tudo e limpar
docker compose down -v
docker compose up -d

# Recriar banco no Phoenix
mix ecto.drop
mix ecto.create
mix ecto.migrate
```

### Backup e Restore:
```bash
# Backup
docker compose exec postgres pg_dump -U postgres rockelivery_dev > backup.sql

# Restore
docker compose exec -T postgres psql -U postgres rockelivery_dev < backup.sql
```

### Verificar saúde do container:
```bash
# Status detalhado
docker compose ps --format json | jq .

# Verificar health check
docker compose exec postgres pg_isready -U postgres -d rockelivery_dev
```

## 📈 Monitoramento

### Ver estatísticas dos containers:
```bash
# Estatísticas em tempo real
docker compose stats

# Estatísticas sem streaming
docker compose stats --no-stream
```

### Ver processos rodando:
```bash
docker compose top
```

## 🎯 Próximos passos

1. Execute `docker compose up -d`
2. Execute `mix ecto.create && mix ecto.migrate`
3. Inicie sua aplicação Phoenix com `mix phx.server`
4. Acesse http://localhost:4000

## 💡 Dicas

- Use **DBeaver** para interface gráfica do banco
- O volume `postgres_data` persiste os dados entre reinicializações
- Health check garante que o banco está pronto antes de outras operações
- Extensões PostgreSQL são instaladas automaticamente via `init.sql`
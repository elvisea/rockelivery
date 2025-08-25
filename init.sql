-- Script de inicialização do PostgreSQL para Rockelivery
-- Este arquivo é executado automaticamente quando o container é criado

-- Criar extensões úteis para desenvolvimento
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Configurar timezone para UTC
SET timezone = 'UTC';

-- Log de inicialização
SELECT 'Database rockelivery_dev initialized successfully!' as status;

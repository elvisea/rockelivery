# 🌿 **Git Workflow - Rockelivery**

> **Guia de fluxo de trabalho com Git para desenvolvimento do projeto Rockelivery**

---

## 🎯 **Estrutura de Branches**

### **📊 Branches Principais:**

```
main (produção)
├── develop (desenvolvimento)
    ├── feature/nova-funcionalidade
    ├── feature/user-management
    ├── hotfix/bug-critico
    └── release/v1.0.0
```

### **🌟 Descrição das Branches:**

| Branch | Propósito | Estabilidade | Deploy |
|--------|-----------|--------------|---------|
| `main` | **Produção** | 🟢 Estável | ✅ Automático |
| `develop` | **Desenvolvimento** | 🟡 Testável | 🧪 Staging |
| `feature/*` | **Novas funcionalidades** | 🔴 Em desenvolvimento | ❌ Não |
| `hotfix/*` | **Correções urgentes** | 🟠 Crítico | ⚡ Emergencial |
| `release/*` | **Preparação de versão** | 🟡 RC | 🚀 Pre-prod |

---

## 🚀 **Comandos Essenciais**

### **1. Desenvolvimento Diário:**

```bash
# Sempre começar na develop atualizada
git checkout develop
git pull origin develop

# Criar nova feature
git checkout -b feature/nome-da-funcionalidade

# Trabalhar na feature...
git add .
git commit -m "feat: implementar nova funcionalidade"

# Enviar para remoto
git push -u origin feature/nome-da-funcionalidade
```

### **2. Finalizar Feature:**

```bash
# Voltar para develop e atualizar
git checkout develop
git pull origin develop

# Fazer merge da feature
git merge feature/nome-da-funcionalidade

# Enviar develop atualizada
git push origin develop

# Deletar branch local da feature
git branch -d feature/nome-da-funcionalidade

# Deletar branch remota da feature
git push origin --delete feature/nome-da-funcionalidade
```

### **3. Hotfix Urgente:**

```bash
# Criar hotfix a partir da main
git checkout main
git pull origin main
git checkout -b hotfix/nome-do-bug

# Corrigir o bug...
git add .
git commit -m "fix: corrigir bug crítico"

# Merge na main
git checkout main
git merge hotfix/nome-do-bug
git push origin main

# Merge na develop também
git checkout develop
git merge hotfix/nome-do-bug
git push origin develop

# Limpar hotfix
git branch -d hotfix/nome-do-bug
```

### **4. Release:**

```bash
# Criar release a partir da develop
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0

# Ajustes finais, versioning...
git add .
git commit -m "release: v1.0.0"

# Merge na main
git checkout main
git merge release/v1.0.0
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin main --tags

# Merge na develop
git checkout develop
git merge release/v1.0.0
git push origin develop

# Limpar release
git branch -d release/v1.0.0
```

---

## 📋 **Convenções de Commit**

### **🏷️ Tipos de Commit:**

```bash
feat: nova funcionalidade
fix: correção de bug
docs: documentação
style: formatação (sem mudança de código)
refactor: refatoração de código
test: testes
chore: tarefas de build/config
perf: melhoria de performance
ci: integração contínua
```

### **📝 Exemplos:**

```bash
git commit -m "feat: adicionar autenticação de usuários"
git commit -m "fix: corrigir validação de CPF"
git commit -m "docs: atualizar README com instruções Docker"
git commit -m "refactor: extrair lógica de validação para módulo separado"
git commit -m "test: adicionar testes para UserController"
```

---

## 🔄 **Fluxo de Trabalho Completo**

### **📈 Ciclo de Desenvolvimento:**

1. **📋 Planejamento**
   - Definir funcionalidade/bug
   - Criar issue no GitHub (opcional)

2. **🌿 Criação de Branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/user-authentication
   ```

3. **💻 Desenvolvimento**
   ```bash
   # Trabalhar na funcionalidade
   mix test
   mix credo
   git add .
   git commit -m "feat: implementar autenticação JWT"
   ```

4. **🧪 Testes**
   ```bash
   # Executar testes completos
   mix test
   mix credo
   docker compose up -d
   mix ecto.migrate
   ```

5. **📤 Push & PR**
   ```bash
   git push -u origin feature/user-authentication
   # Criar Pull Request no GitHub
   ```

6. **🔍 Code Review**
   - Review do código
   - Testes automáticos
   - Aprovação

7. **🔀 Merge**
   ```bash
   # Via GitHub ou local
   git checkout develop
   git merge feature/user-authentication
   git push origin develop
   ```

---

## ⚙️ **Configurações Úteis**

### **🛠️ Aliases Git:**

```bash
# Adicionar aliases úteis
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

# Aliases para workflow
git config --global alias.sync '!git checkout develop && git pull origin develop'
git config --global alias.feature '!f() { git checkout develop && git pull origin develop && git checkout -b feature/$1; }; f'
git config --global alias.hotfix '!f() { git checkout main && git pull origin main && git checkout -b hotfix/$1; }; f'
```

### **🔧 Configurações Recomendadas:**

```bash
# Configurar push padrão
git config --global push.default simple

# Configurar merge sem fast-forward
git config --global merge.ff false

# Configurar pull com rebase
git config --global pull.rebase true

# Configurar editor padrão
git config --global core.editor "code --wait"
```

---

## 🚨 **Regras Importantes**

### **❌ Nunca Fazer:**
- ❌ Commit direto na `main`
- ❌ Push force na `main` ou `develop`
- ❌ Merge sem testes
- ❌ Commit de arquivos de configuração local
- ❌ Commit de credentials/secrets

### **✅ Sempre Fazer:**
- ✅ Pull antes de criar nova branch
- ✅ Executar testes antes do commit
- ✅ Usar mensagens de commit descritivas
- ✅ Revisar código antes do merge
- ✅ Manter branches atualizadas

---

## 📊 **Status Atual do Projeto**

### **🌿 Branches Configuradas:**
- ✅ `main` - Branch principal (produção)
- ✅ `develop` - Branch de desenvolvimento
- ✅ Upstream configurado para ambas

### **🔗 Repositório:**
```
https://github.com/elvisea/rockelivery
```

### **📝 Próximos Passos:**
1. Começar desenvolvimento na branch `develop`
2. Criar features conforme necessário
3. Implementar CI/CD (GitHub Actions)
4. Configurar proteção de branches no GitHub

---

**📅 Criado em:** $(date +"%d/%m/%Y %H:%M")  
**🚀 Status:** Fluxo de branches configurado e pronto para desenvolvimento

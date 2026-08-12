#!/bin/bash

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "${BLUE}📁 Criando estrutura de providers...${NC}"

# Criar diretório
mkdir -p lib/presentation/providers

# Criar arquivos
touch lib/presentation/providers/auth_provider.dart
touch lib/presentation/providers/dashboard_provider.dart
touch lib/presentation/providers/pedido_provider.dart
touch lib/presentation/providers/cliente_provider.dart
touch lib/presentation/providers/produto_provider.dart
touch lib/presentation/providers/providers.dart

echo "${GREEN}✅ Providers criados!${NC}"
echo ""
echo "Arquivos criados:"
ls -la lib/presentation/providers/

#!/bin/bash

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "${BLUE}📁 Criando estrutura de pages...${NC}"

# Criar diretórios
mkdir -p lib/presentation/pages
mkdir -p lib/presentation/pages/auth
mkdir -p lib/presentation/pages/dashboard
mkdir -p lib/presentation/pages/pedidos
mkdir -p lib/presentation/pages/clientes
mkdir -p lib/presentation/pages/produtos

# Criar arquivos
touch lib/presentation/pages/splash_page.dart
touch lib/presentation/pages/auth/login_page.dart
touch lib/presentation/pages/dashboard/dashboard_page.dart
touch lib/presentation/pages/dashboard/dashboard_widgets.dart
touch lib/presentation/pages/pedidos/pedidos_page.dart
touch lib/presentation/pages/pedidos/detalhe_pedido_page.dart
touch lib/presentation/pages/clientes/clientes_page.dart
touch lib/presentation/pages/clientes/detalhe_cliente_page.dart
touch lib/presentation/pages/produtos/produtos_page.dart
touch lib/presentation/pages/produtos/detalhe_produto_page.dart
touch lib/presentation/pages/home_page.dart

echo "${GREEN}✅ Pages criadas!${NC}"
echo ""
echo "Estrutura criada:"
tree lib/presentation/pages/

registro.go
Este arquivo contém todas as definições, regras e estrutura do projeto.
Pode ser copiado e colado em qualquer nova conversa para retomar o contexto.

package registro

1. ESTRUTURA DE LEITURA E LISTAGEM DE ARQUIVOS

Endpoint base: https://file.etoolstec.com.br
Token (atual): fbe087384805253292b041980d5bb824e7c6a1f0aea7cdb0c67c3e1f91bb05e0
Método de autenticação: ?token= na URL (via query params)

A) Listar uma pasta
Endpoint: /list
Método: GET
Parâmetros:
  - token (obrigatório)
  - path (caminho absoluto no servidor)

Exemplo:
  GET https://file.etoolstec.com.br/list?token=SEU_TOKEN&path=/home/opc/prj/front-openerp/lib/presentation/pages

Retorno (JSON):
  {
    "files": [
      {"isDir": true, "name": "auth", "path": "/home/opc/.../auth", "size": 64},
      {"isDir": false, "name": "home_page.dart", "path": "/home/opc/.../home_page.dart", "size": 1828}
    ]
  }

B) Ler um arquivo
Endpoint: /file
Método: GET
Parâmetros:
  - token (obrigatório)
  - path (caminho absoluto do arquivo)

Exemplo:
  GET https://file.etoolstec.com.br/file?token=SEU_TOKEN&path=/home/opc/prj/front-openerp/lib/presentation/pages/home_page.dart

Retorno: Conteúdo do arquivo como texto puro.

2. ORGANIZAÇÃO DO PROJETO

front-openerp/
├── lib/
│   ├── main.dart
│   ├── core/                      # Configurações e constantes
│   ├── data/
│   │   ├── models/                # DTOs (TenantModel, ClienteModel, etc.)
│   │   ├── repositories/          # Camada de repositório (abstração)
│   │   └── services/              # Camada de serviço (chamadas HTTP)
│   └── presentation/
│       ├── pages/                 # Telas organizadas por funcionalidade
│       │   ├── auth/
│       │   ├── clientes/
│       │   ├── dashboard/
│       │   ├── pedidos/
│       │   ├── produtos/
│       │   └── tenants/           # ⬅️ Foco atual
│       └── providers/             # Gerenciamento de estado (Provider)

3. PADRÕES E REGRAS ADOTADAS

+-------------+--------------------------------------------------+--------------------------------------+
| Camada      | Responsabilidade                                 | Padrão                               |
+-------------+--------------------------------------------------+--------------------------------------+
| Model       | Representar dados, serialização/deserialização   | fromJson / toJson / copyWith         |
| Service     | Comunicação com a API, tratamento de erros       | Injeção de ApiService                |
| Repository  | Abstração da fonte de dados                      | Interface entre Service e Provider   |
| Provider    | Estado reativo, regras de negócio, notificações  | ChangeNotifier + notifyListeners     |
| View        | UI, interação, validação de formulário           | StatefulWidget ou StatelessWidget    |
+-------------+--------------------------------------------------+--------------------------------------+

4. REGRAS DE IMPLEMENTAÇÃO PARA TENANTS

- Listagem: carregarTenants() → chama _repository.getAll()
- Criação: criarTenant(tenant) → chama _repository.create() → recarrega lista
- Edição: atualizarTenant(tenant) → chama _repository.update() → recarrega lista
- Exclusão: excluirTenant(id) → chama _repository.delete() → recarrega lista
- Detalhe: selecionarTenant(id) → busca e armazena em _selectedTenant
- Estado: _isLoading, _error, _tenants, _selectedTenant
- Notificações: SnackBar na View
- Validação: Nome obrigatório no formulário

5. AUTENTICAÇÃO E CONFIGURAÇÃO

- Token injetado via query param (?token=...) em todas as chamadas.
- baseUrl da API definido em api_service.dart.
- Provider registrado no main.dart via MultiProvider.

6. VALIDAÇÃO DO JSON DA API PARA TENANTS

GET /tenants → retorna { data: [] } (sem paginação)

Exemplo do JSON retornado:
  {
    "data": [
      {
        "id": 1,
        "nome": "Empresa A",
        "cnpj": "12.345.678/0001-90",
        "email": "contato@a.com",
        "telefone": "(11) 99999-1111",
        "endereco": "Rua A, 123",
        "ativo": true,
        "created_at": "2025-01-01T10:00:00.000Z",
        "updated_at": "2025-01-02T14:30:00.000Z"
      }
    ]
  }

Mapeamento para o Model:
+-------------+-------------+----------+-----------------------------+
| JSON        | Model       | Tipo     | Conversão                   |
+-------------+-------------+----------+-----------------------------+
| id          | id          | int?     | direto                      |
| nome        | nome        | String   | direto (obrigatório)        |
| cnpj        | cnpj        | String?  | direto (fallback documento) |
| email       | email       | String?  | direto                      |
| telefone    | telefone    | String?  | direto (fallback phone)     |
| endereco    | endereco    | String?  | direto (fallback address)   |
| ativo       | ativo       | bool     | direto (fallback active)    |
| created_at  | createdAt   | DateTime?| DateTime.tryParse           |
| updated_at  | updatedAt   | DateTime?| DateTime.tryParse           |
+-------------+-------------+----------+-----------------------------+

7. COMO REUTILIZAR EM OUTRA CONVERSA

Cole este bloco ao abrir uma nova conversa:

  Tenho um projeto Flutter com a seguinte estrutura:
  - Models: lib/data/models/
  - Services: lib/data/services/ (usam ApiService com baseUrl e token via ?token=)
  - Repositories: lib/data/repositories/
  - Providers: lib/presentation/providers/ (ChangeNotifier)
  - Pages: lib/presentation/pages/

  Para ler/listar arquivos, use:
  GET https://file.etoolstec.com.br/list?token=TOKEN&path=CAMINHO
  GET https://file.etoolstec.com.br/file?token=TOKEN&path=CAMINHO

  Padrão de CRUD para Tenants:
  - Model com id, nome, cnpj, email, telefone, endereco, ativo, createdAt, updatedAt
  - Service com listar, obter, criar, atualizar, excluir
  - Provider com carregarTenants, criarTenant, atualizarTenant, excluirTenant, selecionarTenant

  Sempre tratar loading, erro e feedback visual.
  Não usar ! sem verificar null.
  Use fallback para campos alternativos (cnpj vs documento, ativo vs active, etc.).
  Mantenha consistência com o código existente.
  Qualquer ajuste precisa ser validado com o JSON da API (resposta com { data: [] }).

8. OBSERVAÇÕES FINAIS

- Evite usar ! em variáveis que podem ser null.
- Prefira ?? para fallback.
- Sempre valide o JSON antes de mapear.
- Use try/catch em todas as chamadas assíncronas.
- Mantenha a UI responsiva com CircularProgressIndicator e SnackBar.

📎 Este documento serve como referência oficial para continuidade do projeto.
Basta copiar e colar em qualquer novo chat para retomar o contexto.
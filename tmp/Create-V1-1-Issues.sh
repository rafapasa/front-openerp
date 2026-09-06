###
#!/bin/bash
# create_v1.1_front_issues.sh - Cria milestone v1.1 e issues do front operacional
# Uso: chmod +x tmp/Create-V1-1-Issues.sh && ./tmp/Create-V1-1-Issues.sh
# Requer: gh cli autenticado (gh auth login)

set -euo pipefail

REPO="${REPO:-rafapasa/front-openerp}"
PROJECT_TITLE="FrontEnd-mcp-server-openerp"
MILESTONE_TITLE="v1.1 - Front Operacional - Go Live"
export PROJECT_TITLE MILESTONE_TITLE

if [[ ! "$REPO" =~ ^[^/]+/[^/]+$ ]]; then
  echo "REPO inválido: '$REPO' (use owner/repository)" >&2
  exit 1
fi

REPO_OWNER="${REPO%%/*}"

find_milestone() {
  gh api --paginate "repos/$REPO/milestones?state=all&per_page=100" \
    --jq '.[] | select(.title == env.MILESTONE_TITLE) | .number' |
    head -n 1
}

MILESTONE_NUMBER="$(find_milestone)"
if [[ -z "$MILESTONE_NUMBER" ]]; then
  echo "→ Criando milestone $MILESTONE_TITLE..."
  MILESTONE_NUMBER="$(
    gh api --method POST "repos/$REPO/milestones" \
      --raw-field "title=$MILESTONE_TITLE" \
      --raw-field "description=Front operacional: gestão de pedidos, notificações realtime, handoff humano, relatórios e PWA. Foco em comerciante sem ERP." \
      --raw-field state=open --jq '.number'
  )"
else
  echo "→ Milestone #$MILESTONE_NUMBER encontrado"
fi

ensure_label() {
  local label=$1

  if gh api "repos/$REPO/labels/$label" >/dev/null 2>&1; then
    return
  fi

  echo "→ Criando label $label..."
  gh api --method POST "repos/$REPO/labels" \
    --raw-field "name=$label" \
    --raw-field color=ededed >/dev/null
}

for label in front security P0 realtime P1 whatsapp dashboard P2; do
  ensure_label "$label"
done

find_project_id() {
  local project_id
  project_id="$(
    gh api graphql \
      -f query='
        query($login: String!, $title: String!) {
          user(login: $login) {
            projectsV2(first: 100, query: $title) {
              nodes { id title }
            }
          }
        }' \
      -F login="$REPO_OWNER" -F title="$PROJECT_TITLE" \
      --jq '.data.user.projectsV2.nodes[] | select(.title == env.PROJECT_TITLE) | .id' 2>/dev/null |
      head -n 1
  )" || true

  if [[ -n "$project_id" ]]; then
    printf '%s\n' "$project_id"
    return
  fi

  project_id="$(
    gh api graphql \
      -f query='
        query($login: String!, $title: String!) {
          organization(login: $login) {
            projectsV2(first: 100, query: $title) {
              nodes { id title }
            }
          }
        }' \
      -F login="$REPO_OWNER" -F title="$PROJECT_TITLE" \
      --jq '.data.organization.projectsV2.nodes[] | select(.title == env.PROJECT_TITLE) | .id' 2>/dev/null |
      head -n 1
  )" || true

  if [[ -z "$project_id" ]]; then
    echo "Projeto '$PROJECT_TITLE' não encontrado para '$REPO_OWNER'; issues não serão associadas ao Project." >&2
    return 1
  fi
  printf '%s\n' "$project_id"
}

PROJECT_ID="$(find_project_id)" || exit 1

add_to_project() {
  local content_id=$1
  if ! gh api --method POST graphql \
    --raw-field query='
      mutation($projectId: ID!, $contentId: ID!) {
        addProjectV2ItemById(input: {
          projectId: $projectId
          contentId: $contentId
        }) {
          item { id }
        }
      }' \
    --raw-field "projectId=$PROJECT_ID" \
    --raw-field "contentId=$content_id" >/dev/null; then
    echo "Aviso: issue criada, mas não foi associada ao Project '$PROJECT_TITLE'. Verifique o escopo 'project' (e 'read:project') do token." >&2
  fi
}

create_issue() {
  local title=$1
  local body=$2
  local labels=$3
  echo "→ Criando: $title"
  local issue_json
  local -a label_args=()
  local -a label_list=()
  local label
  IFS=',' read -ra label_list <<< "$labels"
  for label in "${label_list[@]}"; do
    label_args+=(--raw-field "labels[]=$label")
  done
  issue_json="$(
    gh api --method POST "repos/$REPO/issues" \
      --raw-field "title=$title" \
      --raw-field "body=$body" \
      --field "milestone=$MILESTONE_NUMBER" \
      "${label_args[@]}" \
      --jq '.node_id'
  )"
  local content_id="$issue_json"
  add_to_project "$content_id"
}

# #24
create_issue "[Front] #24 Refatorar api_service - Segurança JWT e Multi-tenant" "
### Problema
api_service atual não atende requisitos de segurança do backend.

### Tarefas
- [ ] Interceptor Dio com JWT + Refresh (401 -> refresh -> retry)
- [ ] SecureStorage / localStorage criptografado
- [ ] Header X-Tenant-ID obrigatório
- [ ] Logout automático 403/401

### Aceite
- Refresh silencioso funciona
- Tenant isolation validado (trocar ID retorna 403)
" "front,security,P0"

# #25
create_issue "[Front] #25 Tela Gestão de Pedidos - Kanban Operacional" "
### Descrição
Tela principal operacional, 4 colunas: NOVOS | EM PREPARO | SAIU P/ ENTREGA | CONCLUÍDO

Card: #ID, cliente, itens, valor, forma pgto, status pgto, tempo criação (vermelho >15min), endereço resumido.

### Tarefas
- [ ] PedidosProvider (Riverpod) polling 15s
- [ ] Kanban drag-and-drop
- [ ] Cores por SLA
- [ ] Pull-to-refresh

### Aceite
- Pedido chega em <15s
- Drag muda status PATCH /api/v1/orders/{id}/status
" "front,P0"

# #26
create_issue "[Front] #26 Detalhe do Pedido + Ações Operacionais" "
### Ao clicar no card abre modal
Cliente (ligar/Whats/Maps), itens, pagamento (Marcar como Pago), entrega (Saiu p/ entrega), timeline, Imprimir cupom 80mm, Recusar com motivo.

### Tarefas
- [ ] Modal detalhe
- [ ] PATCH status com motivo
- [ ] PATCH pagamento
- [ ] window.print 80mm
" "front,P0"

# #27
create_issue "[Front] #27 Notificação Realtime de Novos Pedidos - SSE + Som" "
### User Story
Como caixa quero ouvir plim quando chegar pedido.

### Solução
Backend SSE /api/v1/orders/stream?tenant_id=X via Redis PubSub
Front RealtimeService EventSource + audio new_order.mp3 + Notification API + badge favicon

### Tarefas
- [ ] Backend SSE new_order
- [ ] Front listener + som
- [ ] Notificação navegador
- [ ] Reconexão automática
" "front,realtime,P1"

# #28
create_issue "[Front] #28 Handoff Humano - Assumir Chat" "
### Lista conversas ativas do bot, botão Assumir -> status HUMAN, campo texto, Devolver pro Bot, transcrição.

### Tarefas
- [ ] GET /conversations?status=bot
- [ ] POST /conversations/{id}/handoff
- [ ] Tela chat simples
- [ ] Timer 5min sem resposta
" "front,whatsapp,P1"

# #29
create_issue "[Front] #29 Relatórios Visuais Operacionais - 3 gráficos" "
1. Hoje: pedidos por hora + total R$
2. Status: pizza status
3. Pagamento: barra por forma + ticket médio + cancelamento

### Tarefas
- [ ] Reutilizar widgets dashboard
- [ ] GET /reports/today
- [ ] Filtros Hoje/Ontem/7d
- [ ] KPI cards

" "front,dashboard,P1"

# #30
create_issue "[Front] #30 Busca, Filtros e Operação Rápida" "
Busca nome/tel/#pedido, filtros data/status/pgto/entrega, ordenação, atalhos N/P.

Filtro local para 500 pedidos.
" "front,P2"

# #31
create_issue "[Front] #31 PWA + Responsivo + Modo Quiosque" "
Tornar Flutter Web PWA instalável, responsivo tablet cozinha e celular dono, modo quiosque (tela sempre ligada, som alto), login com logo tenant.

" "front,P2"

echo "✓ Todas issues criadas no milestone $MILESTONE_TITLE no repo $REPO"
echo "✓ Issues associadas ao Project $PROJECT_TITLE"

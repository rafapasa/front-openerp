/// Enum para status do pedido
enum StatusPedido {
  pendente,
  confirmado,
  preparando,
  emPreparo,
  pronto,
  saiuEntrega,
  entregue,
  cancelado;

  /// Converte string para enum
  static StatusPedido fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pendente':
        return StatusPedido.pendente;
      case 'confirmado':
        return StatusPedido.confirmado;
      case 'preparando':
        return StatusPedido.preparando;
      case 'em_preparo':
      case 'em-preparo':
        return StatusPedido.emPreparo;
      case 'pronto':
        return StatusPedido.pronto;
      case 'saiu_entrega':
      case 'saiu-entrega':
      case 'saiu_para_entrega':
        return StatusPedido.saiuEntrega;
      case 'entregue':
        return StatusPedido.entregue;
      case 'cancelado':
        return StatusPedido.cancelado;
      default:
        return StatusPedido.pendente;
    }
  }

  /// Converte enum para string (usado na API)
  String toStringValue() {
    switch (this) {
      case StatusPedido.pendente:
        return 'pendente';
      case StatusPedido.confirmado:
        return 'confirmado';
      case StatusPedido.preparando:
        return 'preparando';
      case StatusPedido.emPreparo:
        return 'em_preparo';
      case StatusPedido.pronto:
        return 'pronto';
      case StatusPedido.saiuEntrega:
        return 'saiu_entrega';
      case StatusPedido.entregue:
        return 'entregue';
      case StatusPedido.cancelado:
        return 'cancelado';
    }
  }

  String get label {
    switch (this) {
      case StatusPedido.pendente:
        return 'Pendente';
      case StatusPedido.confirmado:
        return 'Confirmado';
      case StatusPedido.preparando:
        return 'Preparando';
      case StatusPedido.emPreparo:
        return 'Em preparo';
      case StatusPedido.pronto:
        return 'Pronto';
      case StatusPedido.saiuEntrega:
        return 'Saiu p/ entrega';
      case StatusPedido.entregue:
        return 'Entregue';
      case StatusPedido.cancelado:
        return 'Cancelado';
    }
  }

  String get colorHex {
    switch (this) {
      case StatusPedido.pendente:
        return '#FF9800';
      case StatusPedido.confirmado:
        return '#2196F3';
      case StatusPedido.preparando:
      case StatusPedido.emPreparo:
        return '#9C27B0';
      case StatusPedido.pronto:
        return '#00897B';
      case StatusPedido.saiuEntrega:
        return '#1565C0';
      case StatusPedido.entregue:
        return '#4CAF50';
      case StatusPedido.cancelado:
        return '#F44336';
    }
  }

  String get iconName {
    switch (this) {
      case StatusPedido.pendente:
        return 'pending';
      case StatusPedido.confirmado:
        return 'check_circle';
      case StatusPedido.preparando:
      case StatusPedido.emPreparo:
        return 'build';
      case StatusPedido.pronto:
        return 'done';
      case StatusPedido.saiuEntrega:
        return 'local_shipping';
      case StatusPedido.entregue:
        return 'delivery';
      case StatusPedido.cancelado:
        return 'cancel';
    }
  }

  bool get isCozinha => this == StatusPedido.preparando || this == StatusPedido.emPreparo;
}

/// Enum para origem do pedido
enum OrigemPedido {
  whatsapp,
  web,
  app,
  presencial,
  telefone;

  static OrigemPedido fromString(String value) {
    switch (value.toLowerCase()) {
      case 'whatsapp':
        return OrigemPedido.whatsapp;
      case 'web':
        return OrigemPedido.web;
      case 'dashboard':
        return OrigemPedido.web;
      case 'app':
        return OrigemPedido.app;
      case 'presencial':
        return OrigemPedido.presencial;
      case 'telefone':
        return OrigemPedido.telefone;
      default:
        return OrigemPedido.whatsapp;
    }
  }

  String toStringValue() {
    switch (this) {
      case OrigemPedido.whatsapp:
        return 'whatsapp';
      case OrigemPedido.web:
        return 'web';
      case OrigemPedido.app:
        return 'app';
      case OrigemPedido.presencial:
        return 'presencial';
      case OrigemPedido.telefone:
        return 'telefone';
    }
  }

  String get label {
    switch (this) {
      case OrigemPedido.whatsapp:
        return 'WhatsApp';
      case OrigemPedido.web:
        return 'Web';
      case OrigemPedido.app:
        return 'App';
      case OrigemPedido.presencial:
        return 'Presencial';
      case OrigemPedido.telefone:
        return 'Telefone';
    }
  }
}

enum TenantStatus {
  ativo,
  inativo,
  bloqueado,
  suspenso;

  static TenantStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'ativo':
        return TenantStatus.ativo;
      case 'inativo':
        return TenantStatus.inativo;
      case 'bloqueado':
        return TenantStatus.bloqueado;
      case 'suspenso':
        return TenantStatus.suspenso;
      default:
        return TenantStatus.ativo;
    }
  }

  String toStringValue() {
    switch (this) {
      case TenantStatus.ativo:
        return 'ativo';
      case TenantStatus.inativo:
        return 'inativo';
      case TenantStatus.bloqueado:
        return 'bloqueado';
      case TenantStatus.suspenso:
        return 'suspenso';
    }
  }

  String get label {
    switch (this) {
      case TenantStatus.ativo:
        return 'Ativo';
      case TenantStatus.inativo:
        return 'Inativo';
      case TenantStatus.bloqueado:
        return 'Bloqueado';
      case TenantStatus.suspenso:
        return 'Suspenso';
    }
  }

  String get colorHex {
    switch (this) {
      case TenantStatus.ativo:
        return '#4CAF50';
      case TenantStatus.inativo:
        return '#9E9E9E';
      case TenantStatus.bloqueado:
        return '#F44336';
      case TenantStatus.suspenso:
        return '#FF9800';
    }
  }
}

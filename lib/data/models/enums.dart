/// Enum para status do pedido
enum StatusPedido {
  pendente,
  confirmado,
  preparando,
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
      case StatusPedido.entregue:
        return 'entregue';
      case StatusPedido.cancelado:
        return 'cancelado';
    }
  }

  /// Label amigável para exibição
  String get label {
    switch (this) {
      case StatusPedido.pendente:
        return 'Pendente';
      case StatusPedido.confirmado:
        return 'Confirmado';
      case StatusPedido.preparando:
        return 'Preparando';
      case StatusPedido.entregue:
        return 'Entregue';
      case StatusPedido.cancelado:
        return 'Cancelado';
    }
  }

  /// Cor associada ao status (para UI)
  String get colorHex {
    switch (this) {
      case StatusPedido.pendente:
        return '#FF9800'; // Laranja
      case StatusPedido.confirmado:
        return '#2196F3'; // Azul
      case StatusPedido.preparando:
        return '#9C27B0'; // Roxo
      case StatusPedido.entregue:
        return '#4CAF50'; // Verde
      case StatusPedido.cancelado:
        return '#F44336'; // Vermelho
    }
  }

  /// Ícone associado ao status (para UI)
  String get iconName {
    switch (this) {
      case StatusPedido.pendente:
        return 'pending';
      case StatusPedido.confirmado:
        return 'check_circle';
      case StatusPedido.preparando:
        return 'build';
      case StatusPedido.entregue:
        return 'delivery';
      case StatusPedido.cancelado:
        return 'cancel';
    }
  }
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

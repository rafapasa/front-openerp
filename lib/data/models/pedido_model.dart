import 'cliente_model.dart';
import 'endereco_model.dart';
import 'enums.dart'; // Importar os enums

// Item do pedido (sub-modelo)
class ItemPedidoModel {
  final String nome;
  final int quantidade;
  final double preco;
  final String? observacao;

  ItemPedidoModel({
    required this.nome,
    required this.quantidade,
    required this.preco,
    this.observacao,
  });

  factory ItemPedidoModel.fromJson(Map<String, dynamic> json) {
    return ItemPedidoModel(
      nome: json['nome'] ?? '',
      quantidade: json['quantidade'] ?? 0,
      preco: (json['preco'] ?? 0).toDouble(),
      observacao: json['observacao'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'quantidade': quantidade,
    'preco': preco,
    'observacao': observacao,
  };

  double get subtotal => quantidade * preco;
}

// Modelo principal do pedido
class PedidoModel {
  final int id;
  final int? tenantId;
  final int? clienteId;
  final String clienteNome;
  final String clienteTelefone;
  final int? enderecoEntregaId;
  final EnderecoModel? enderecoEntrega;
  final List<ItemPedidoModel> itens;
  final double total;
  final StatusPedido status; // AGORA DEFINIDO!
  final String? observacoes;
  final int? tempoEstimado;
  final OrigemPedido origem; // TAMBÉM ADICIONEI
  final DateTime createdAt;
  final DateTime updatedAt;
  final ClienteModel? cliente;

  PedidoModel({
    required this.id,
    this.tenantId,
    this.clienteId,
    required this.clienteNome,
    required this.clienteTelefone,
    this.enderecoEntregaId,
    this.enderecoEntrega,
    required this.itens,
    required this.total,
    required this.status,
    this.observacoes,
    this.tempoEstimado,
    this.origem = OrigemPedido.whatsapp,
    required this.createdAt,
    required this.updatedAt,
    this.cliente,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      clienteId: json['cliente_id'],
      clienteNome: json['cliente_nome'] ?? '',
      clienteTelefone: json['cliente_telefone'] ?? '',
      enderecoEntregaId: json['endereco_entrega_id'],
      enderecoEntrega: json['endereco_entrega'] != null
          ? EnderecoModel.fromJson(json['endereco_entrega'])
          : null,
      itens: (json['itens'] as List? ?? [])
          .map((e) => ItemPedidoModel.fromJson(e))
          .toList(),
      total: (json['total'] ?? 0).toDouble(),
      status: StatusPedido.fromString(json['status'] ?? 'pendente'),
      observacoes: json['observacoes'],
      tempoEstimado: json['tempo_estimado'],
      origem: OrigemPedido.fromString(json['origem'] ?? 'whatsapp'),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      cliente: json['cliente'] != null
          ? ClienteModel.fromJson(json['cliente'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenant_id': tenantId,
    'cliente_id': clienteId,
    'cliente_nome': clienteNome,
    'cliente_telefone': clienteTelefone,
    'endereco_entrega_id': enderecoEntregaId,
    'endereco_entrega': enderecoEntrega?.toJson(),
    'itens': itens.map((e) => e.toJson()).toList(),
    'total': total,
    'status': status.toStringValue(),
    'observacoes': observacoes,
    'tempo_estimado': tempoEstimado,
    'origem': origem.toStringValue(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  // Getters úteis
  String get statusLabel => status.label;
  String get statusColor => status.colorHex;
  String get statusIcon => status.iconName;
  String get origemLabel => origem.label;
  String get totalFormatado => 'R\$ ${total.toStringAsFixed(2)}';

  // Verifica se o pedido pode ser cancelado
  bool get podeCancelar =>
      status == StatusPedido.pendente || status == StatusPedido.confirmado;

  // Verifica se o pedido está ativo (não finalizado)
  bool get isAtivo =>
      status != StatusPedido.entregue && status != StatusPedido.cancelado;
}

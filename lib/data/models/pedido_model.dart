import 'package:front_openerp/core/helpers/json_helper.dart';

import 'cliente_model.dart';
import 'endereco_model.dart';
import 'enums.dart';

class ItemPedidoModel {
  final int? produtoId;
  final String nome;
  final int quantidade;
  final double preco;
  final String? observacao;

  ItemPedidoModel({this.produtoId, required this.nome, required this.quantidade, required this.preco, this.observacao});

  factory ItemPedidoModel.fromJson(Map<String, dynamic> json) {
    return ItemPedidoModel(
      produtoId: json['produto_id'] != null ? JsonHelper.toInt(json['produto_id']) : null,
      nome: JsonHelper.toStr(json['nome']),
      quantidade: JsonHelper.toInt(json['quantidade']),
      preco: JsonHelper.toDouble(json['preco']),
      observacao: json['observacao'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'produto_id': produtoId,
    'nome': nome,
    'quantidade': quantidade,
    'preco': preco,
    'observacao': observacao,
  };

  double get subtotal => quantidade * preco;
}

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
  final StatusPedido status;
  final String? observacoes;
  final int? tempoEstimado;
  final OrigemPedido origem;
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
      id: JsonHelper.toInt(json['id']),
      tenantId: json['tenant_id'] != null ? JsonHelper.toInt(json['tenant_id']) : null,
      clienteId: json['cliente_id'] != null ? JsonHelper.toInt(json['cliente_id']) : null,
      clienteNome: JsonHelper.toStr(json['cliente_nome']),
      clienteTelefone: JsonHelper.toStr(json['cliente_telefone']),
      enderecoEntregaId: json['endereco_entrega_id'] != null ? JsonHelper.toInt(json['endereco_entrega_id']) : null,
      enderecoEntrega: json['endereco_entrega'] != null
          ? EnderecoModel.fromJson(json['endereco_entrega'] as Map<String, dynamic>)
          : null,
      itens: JsonHelper.toList(json['itens'], (e) => ItemPedidoModel.fromJson(e as Map<String, dynamic>)),
      total: JsonHelper.toDouble(json['total']),
      status: StatusPedido.fromString(JsonHelper.toStr(json['status'], fallback: 'pendente')),
      observacoes: json['observacoes'] as String?,
      tempoEstimado: json['tempo_estimado'] != null ? JsonHelper.toInt(json['tempo_estimado']) : null,
      origem: OrigemPedido.fromString(JsonHelper.toStr(json['origem'], fallback: 'whatsapp')),
      createdAt: JsonHelper.toDateTimeOrNow(json['created_at']),
      updatedAt: JsonHelper.toDateTimeOrNow(json['updated_at']),
      cliente: json['cliente'] != null ? ClienteModel.fromJson(json['cliente'] as Map<String, dynamic>) : null,
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

  String get statusLabel => status.label;
  String get statusColor => status.colorHex;
  String get statusIcon => status.iconName;
  String get origemLabel => origem.label;
  String get totalFormatado => 'R\$ ${total.toStringAsFixed(2)}';
  bool get podeCancelar => status == StatusPedido.pendente || status == StatusPedido.confirmado;
  bool get isAtivo => status != StatusPedido.entregue && status != StatusPedido.cancelado;
}

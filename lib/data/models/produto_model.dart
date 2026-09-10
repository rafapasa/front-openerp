import 'package:front_openerp/core/helpers/json_helper.dart';

class ProdutoModel {
  final int id;
  final int? tenantId;
  final int? categoriaId;
  final String? categoriaNome;
  final String nome;
  final String? descricao;
  final double preco;
  final bool disponivel;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProdutoModel({
    required this.id,
    this.tenantId,
    this.categoriaId,
    this.categoriaNome,
    required this.nome,
    this.descricao,
    required this.preco,
    this.disponivel = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      id: JsonHelper.toInt(json['id']),
      tenantId: json['tenant_id'] != null ? JsonHelper.toInt(json['tenant_id']) : null,
      categoriaId: json['categoria_id'] != null ? JsonHelper.toInt(json['categoria_id']) : null,
      categoriaNome: json['categoria_nome'],
      nome: JsonHelper.toStr(json['nome']),
      descricao: json['descricao'],
      preco: JsonHelper.toDouble(json['preco']),
      disponivel: JsonHelper.toBool(json['disponivel'], fallback: true),
      createdAt: JsonHelper.toDateTimeOrNow(json['created_at']),
      updatedAt: JsonHelper.toDateTimeOrNow(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenant_id': tenantId,
    'categoria_id': categoriaId,
    'categoria_nome': categoriaNome,
    'nome': nome,
    'descricao': descricao,
    'preco': preco,
    'disponivel': disponivel,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  String get precoFormatado => 'R\$ ${preco.toStringAsFixed(2)}';
}

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
      id: json['id'],
      tenantId: json['tenant_id'],
      categoriaId: json['categoria_id'],
      categoriaNome: json['categoria_nome'],
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      preco: (json['preco'] ?? 0).toDouble(),
      disponivel: json['disponivel'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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

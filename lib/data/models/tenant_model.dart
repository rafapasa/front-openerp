// lib/data/models/tenant_model.dart
class TenantModel {
  final int? id;
  final String nome;
  final String? cnpj;
  final String? email;
  final String? telefone;
  final String? endereco;
  final bool ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TenantModel({
    this.id,
    required this.nome,
    this.cnpj,
    this.email,
    this.telefone,
    this.endereco,
    this.ativo = true,
    this.createdAt,
    this.updatedAt,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      cnpj: json['cnpj'] ?? json['documento'],
      email: json['email'],
      telefone: json['telefone'] ?? json['phone'],
      endereco: json['endereco'] ?? json['address'],
      ativo: json['ativo'] ?? json['active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cnpj': cnpj,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
      'ativo': ativo,
    };
  }

  TenantModel copyWith({
    int? id,
    String? nome,
    String? cnpj,
    String? email,
    String? telefone,
    String? endereco,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TenantModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cnpj: cnpj ?? this.cnpj,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
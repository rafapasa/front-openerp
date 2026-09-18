import 'package:front_openerp/core/helpers/json_helper.dart';

class TenantModel {
  final int? id;
  final String nome;
  final String? cnpj;
  final String? email;
  final String? telefone;
  final String? endereco;
  final String? segmento;
  final String? wabaId;
  final String? whatsappPhoneId;
  final String? whatsappDisplayNumber;
  final bool ativo;
  final int? clienteBalcaoId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TenantModel({
    this.id,
    required this.nome,
    this.cnpj,
    this.email,
    this.telefone,
    this.endereco,
    this.segmento,
    this.wabaId,
    this.whatsappPhoneId,
    this.whatsappDisplayNumber,
    this.ativo = true,
    this.clienteBalcaoId,
    this.createdAt,
    this.updatedAt,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] != null ? JsonHelper.toInt(json['id']) : null,
      nome: JsonHelper.toStr(json['nome']),
      cnpj: json['cnpj'] ?? json['documento'],
      email: json['email'],
      telefone: json['telefone'] ?? json['phone'],
      endereco: json['endereco'] ?? json['address'],
      segmento: json['segmento'],
      wabaId: json['waba_id'],
      whatsappPhoneId: json['whatsapp_phone_id'],
      whatsappDisplayNumber: json['whatsapp_display_number'],
      ativo: JsonHelper.toBool(json['ativo'] ?? json['active'], fallback: true),
      createdAt: JsonHelper.toDateTime(json['created_at']),
      updatedAt: JsonHelper.toDateTime(json['updated_at']),
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
      'segmento': segmento,
      'waba_id': wabaId,
      'whatsapp_phone_id': whatsappPhoneId,
      'whatsapp_display_number': whatsappDisplayNumber,
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
    String? segmento,
    String? wabaId,
    String? whatsappPhoneId,
    String? whatsappDisplayNumber,
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
      segmento: segmento ?? this.segmento,
      wabaId: wabaId ?? this.wabaId,
      whatsappPhoneId: whatsappPhoneId ?? this.whatsappPhoneId,
      whatsappDisplayNumber: whatsappDisplayNumber ?? this.whatsappDisplayNumber,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

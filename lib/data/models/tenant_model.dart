// lib/data/models/tenant_model.dart
import 'dart:ui';

class TenantModel {
  final int id;
  final String nome;
  final String? cnpj;
  final String? telefone;
  final String? endereco;
  final String? segmento;
  final String? wabaId;
  final String? whatsappPhoneId;
  final String? whatsappDisplayNumber;
  final String? whatsappVerifyToken;
  final bool ativo;
  final DateTime createdAt;

  TenantModel({
    required this.id,
    required this.nome,
    this.cnpj,
    this.telefone,
    this.endereco,
    this.segmento,
    this.wabaId,
    this.whatsappPhoneId,
    this.whatsappDisplayNumber,
    this.whatsappVerifyToken,
    this.ativo = true,
    required this.createdAt,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      cnpj: json['cnpj'],
      telefone: json['telefone'],
      endereco: json['endereco'],
      segmento: json['segmento'] ?? 'geral',
      wabaId: json['waba_id'],
      whatsappPhoneId: json['whatsapp_phone_id'],
      whatsappDisplayNumber: json['whatsapp_display_number'],
      whatsappVerifyToken: json['whatsapp_verify_token'],
      ativo: json['ativo'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cnpj': cnpj,
      'telefone': telefone,
      'endereco': endereco,
      'segmento': segmento,
      'waba_id': wabaId,
      'whatsapp_phone_id': whatsappPhoneId,
      'whatsapp_display_number': whatsappDisplayNumber,
      'whatsapp_verify_token': whatsappVerifyToken,
      'ativo': ativo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Getters úteis
  String get cnpjFormatado => _formatarCnpj(cnpj);
  String get statusLabel => ativo ? 'Ativo' : 'Inativo';
  Color get statusColor => ativo ? Color(0xFF4CAF50) : Color(0xFFF44336);
  String get segmentoLabel => _getSegmentoLabel(segmento);
  bool get isWhatsappConnected =>
      whatsappPhoneId != null && whatsappPhoneId!.isNotEmpty;

  // Métodos auxiliares
  static String _formatarCnpj(String? cnpj) {
    if (cnpj == null) return '';
    final cleaned = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length == 11) {
      // CPF: XXX.XXX.XXX-XX
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6, 9)}-${cleaned.substring(9)}';
    } else if (cleaned.length == 14) {
      // CNPJ: XX.XXX.XXX/XXXX-XX
      return '${cleaned.substring(0, 2)}.${cleaned.substring(2, 5)}.${cleaned.substring(5, 8)}/${cleaned.substring(8, 12)}-${cleaned.substring(12)}';
    }
    return cnpj;
  }

  static String _getSegmentoLabel(String? segmento) {
    switch (segmento) {
      case 'farmacia':
        return 'Farmácia';
      case 'mercado':
        return 'Mercado';
      case 'restaurante':
        return 'Restaurante';
      case 'geral':
        return 'Geral';
      default:
        return segmento ?? 'Geral';
    }
  }

  TenantModel copyWith({
    int? id,
    String? nome,
    String? cnpj,
    String? telefone,
    String? endereco,
    String? segmento,
    String? wabaId,
    String? whatsappPhoneId,
    String? whatsappDisplayNumber,
    String? whatsappVerifyToken,
    bool? ativo,
    DateTime? createdAt,
  }) {
    return TenantModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cnpj: cnpj ?? this.cnpj,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      segmento: segmento ?? this.segmento,
      wabaId: wabaId ?? this.wabaId,
      whatsappPhoneId: whatsappPhoneId ?? this.whatsappPhoneId,
      whatsappDisplayNumber:
          whatsappDisplayNumber ?? this.whatsappDisplayNumber,
      whatsappVerifyToken: whatsappVerifyToken ?? this.whatsappVerifyToken,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// DTOs para criação/atualização
class CreateTenantDTO {
  final String nome;
  final String? cnpj;
  final String? telefone;
  final String? segmento;
  final String? wabaId;
  final String? whatsappPhoneId;
  final String? whatsappDisplayNumber;

  CreateTenantDTO({
    required this.nome,
    this.cnpj,
    this.telefone,
    this.segmento,
    this.wabaId,
    required this.whatsappPhoneId,
    this.whatsappDisplayNumber,
  });

  // 🔧 CONSTRUTOR FACTORY para criar a partir de um Map
  factory CreateTenantDTO.fromJson(Map<String, dynamic> json) {
    return CreateTenantDTO(
      nome: json['nome'] ?? '',
      cnpj: json['cnpj'],
      telefone: json['telefone'],
      segmento: json['segmento'] ?? 'geral',
      wabaId: json['waba_id'],
      whatsappPhoneId: json['whatsapp_phone_id'] ?? '',
      whatsappDisplayNumber: json['whatsapp_display_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cnpj': cnpj,
      'telefone': telefone,
      'segmento': segmento ?? 'geral',
      'waba_id': wabaId,
      'whatsapp_phone_id': whatsappPhoneId,
      'whatsapp_display_number': whatsappDisplayNumber,
    };
  }
}

class UpdateTenantDTO {
  final String? nome;
  final String? cnpj;
  final String? telefone;
  final String? endereco;
  final String? segmento;
  final String? wabaId;
  final String? whatsappPhoneId;
  final String? whatsappDisplayNumber;
  final bool? ativo;

  UpdateTenantDTO({
    this.nome,
    this.cnpj,
    this.telefone,
    this.endereco,
    this.segmento,
    this.wabaId,
    this.whatsappPhoneId,
    this.whatsappDisplayNumber,
    this.ativo,
  });

  // ============================================================
  // 🔧 FACTORY CONSTRUCTOR fromJson
  // ============================================================
  factory UpdateTenantDTO.fromJson(Map<String, dynamic> json) {
    return UpdateTenantDTO(
      nome: json['nome'],
      cnpj: json['cnpj'],
      telefone: json['telefone'],
      endereco: json['endereco'],
      segmento: json['segmento'],
      wabaId: json['waba_id'],
      whatsappPhoneId: json['whatsapp_phone_id'],
      whatsappDisplayNumber: json['whatsapp_display_number'],
      ativo: json['ativo'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (nome != null) map['nome'] = nome;
    if (cnpj != null) map['cnpj'] = cnpj;
    if (telefone != null) map['telefone'] = telefone;
    if (endereco != null) map['endereco'] = endereco;
    if (segmento != null) map['segmento'] = segmento;
    if (wabaId != null) map['waba_id'] = wabaId;
    if (whatsappPhoneId != null) map['whatsapp_phone_id'] = whatsappPhoneId;
    if (whatsappDisplayNumber != null) {
      map['whatsapp_display_number'] = whatsappDisplayNumber;
    }
    if (ativo != null) map['ativo'] = ativo;
    return map;
  }
}

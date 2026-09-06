// lib/data/models/login_model.dart
//
// Modelos que espelham a resposta do POST /login do backend (Go):
//
// type LoginResponse struct {
//     Token   string  `json:"token"`
//     User    UserDTO `json:"user"`
//     Expires string  `json:"expires_at"`
// }
//
// type LoginResponseList struct {
//     Count int             `json:"count"`
//     Users []LoginResponse `json:"users"`
// }
//
// type UserDTO struct {
//     ID       uint   `json:"id"`
//     TenantID uint   `json:"tenant_id"`
//     Nome     string `json:"nome"`
//     Email    string `json:"email"`
//     Role     string `json:"role"`
// }
//
// Cada item de `users` é uma conta do mesmo e-mail dentro de um tenant, com o
// seu próprio token JWT (claims: user_id, tenant_id, role).

/// Uma conta retornada no login: dados do usuário + token válido p/ um tenant.
class LoginConta {
  final String token;
  final String expiresAt; // expires_at (RFC3339)
  final int id; // user.id
  final int tenantId; // user.tenant_id
  final String nome; // user.nome
  final String email; // user.email
  final String role; // user.role

  const LoginConta({
    required this.token,
    required this.expiresAt,
    required this.id,
    required this.tenantId,
    required this.nome,
    required this.email,
    required this.role,
  });

  factory LoginConta.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return LoginConta(
      token: json['token'] as String? ?? '',
      expiresAt: json['expires_at'] as String? ?? '',
      id: (user['id'] as num?)?.toInt() ?? 0,
      tenantId: (user['tenant_id'] as num?)?.toInt() ?? 0,
      nome: user['nome'] as String? ?? '',
      email: user['email'] as String? ?? '',
      role: user['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'expires_at': expiresAt,
        'user': {
          'id': id,
          'tenant_id': tenantId,
          'nome': nome,
          'email': email,
          'role': role,
        },
      };

  /// Rótulo amigável do perfil (role) exibido na tela de seleção de empresa.
  String get roleLabel {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrador';
      case 'atendente':
        return 'Atendente';
      case 'cozinha':
        return 'Cozinha';
      default:
        return role.isEmpty ? 'Usuário' : role;
    }
  }
}

/// Contêiner da resposta do login (LoginResponseList).
class LoginResultado {
  final int count;
  final List<LoginConta> contas;

  LoginResultado({required this.count, required this.contas});

  factory LoginResultado.fromJson(Map<String, dynamic> json) {
    final users = json['users'] as List? ?? const [];
    final contas = users
        .whereType<Map<String, dynamic>>()
        .map(LoginConta.fromJson)
        .toList();
    return LoginResultado(
      count: (json['count'] as num?)?.toInt() ?? contas.length,
      contas: contas,
    );
  }

  bool get possuiMultiplasContas => contas.length > 1;
}

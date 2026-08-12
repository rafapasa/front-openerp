class UsuarioModel {
  final int id;
  final String email;
  final String? nome;
  final String? token;

  UsuarioModel({required this.id, required this.email, this.nome, this.token});

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'],
      email: json['email'] ?? '',
      nome: json['nome'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nome': nome,
    'token': token,
  };
}

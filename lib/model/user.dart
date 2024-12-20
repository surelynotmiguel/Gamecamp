class AppUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final DateTime birthDate;
  final String cpf;
  final String cep;
  final String address;
  final String number;
  final String district;
  final String city;
  final String state;
  final List<String> favoriteGenres;
  final String gender;
  final String profileImageUrl;
  final bool isAdmin; // Campo para verificar se o usuário é admin

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.birthDate,
    required this.cpf,
    required this.cep,
    required this.address,
    required this.number,
    required this.district,
    required this.city,
    required this.state,
    required this.favoriteGenres,
    required this.gender,
    required this.profileImageUrl,
    required this.isAdmin,
  });

  // Método para converter JSON para um User
  factory AppUser.fromJson(String id, Map<String, dynamic> json) {
    return AppUser(
      id: id,
      name: json['nome'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['telefone'] ?? '',
      birthDate: json['dataDeNascimento'] != null
          ? DateTime.parse(json['dataDeNascimento'])
          : DateTime(1900, 1, 1), // Valor padrão para datas nulas
      cpf: json['cpf'] ?? '',
      cep: json['cep'] ?? '',
      address: json['endereco'] ?? '',
      number: json['numero'] ?? '',
      district: json['bairro'] ?? '',
      city: json['cidade'] ?? '',
      state: json['estado'] ?? '',
      favoriteGenres: json['generosFavoritos'] != null
          ? List<String>.from(json['generosFavoritos'])
          : <String>[], // Lista vazia para favoritos nulos
      gender: json['genero'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      isAdmin: json['isAdmin'] ?? false, // Valor default se isAdmin não existir
    );
  }

  // Método para converter um User para JSON
  Map<String, dynamic> toJson() {
    return {
      'nome': name,
      'email': email,
      'telefone': phoneNumber,
      'dataDeNascimento': birthDate.toIso8601String(),
      'cpf': cpf,
      'cep': cep,
      'logradouro': address,
      'numero': number,
      'bairro': district,
      'cidade': city,
      'estado': state,
      'generosFavoritos': favoriteGenres,
      'genero': gender,
      'profileImageUrl': profileImageUrl,
      'isAdmin': isAdmin,
    };
  }

  // Método para converter um Map para um User
  factory AppUser.fromMap(Map<dynamic, dynamic> map) {
    return AppUser(
      id: map['id'],
      name: map['nome'],
      email: map['email'],
      phoneNumber: map['telefone'],
      birthDate: DateTime.parse(map['dataDeNascimento']),
      cpf: map['cpf'],
      cep: map['cep'],
      address: map['endereco'],
      number: map['numero'],
      district: map['bairro'],
      city: map['cidade'],
      state: map['estador'],
      favoriteGenres: List<String>.from(map['generosFavoritos']),
      gender: map['genero'],
      profileImageUrl: map['profileImageUrl'],
      isAdmin: map['isAdmin'],
    );
  }
}

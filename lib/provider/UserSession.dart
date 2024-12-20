class UserSession {
  // Instância única da classe (Singleton)
  static final UserSession _instance = UserSession._internal();

  // Construtor privado para evitar múltiplas instâncias

  // Método de fábrica para obter a instância única
  factory UserSession() {
    return _instance;
  }
  UserSession._internal();

  // Variável para armazenar o userId
  String? userId;
  String? nome;
  bool? isAdmin;
  String? fotoDePerfil;

  // Você pode adicionar mais variáveis aqui, se necessário
}

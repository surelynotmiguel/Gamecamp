import 'package:flutter/material.dart';
import 'package:gamecamp/model/user.dart';
import 'package:gamecamp/provider/user_service.dart'; // A classe de serviço para obter dados do Firebase.

class UserProvider with ChangeNotifier {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<void> fetchUser() async {
    try {
      // Aqui você vai pegar o ID do usuário logado
      final userId =
          'ID_DO_USUARIO_LOGADO'; // Modifique para pegar o ID real do usuário
      AppUser? user = await UserService().getUserById(userId);

      if (user != null) {
        _currentUser = user;
        notifyListeners(); // Notifique os ouvintes para atualizar a UI
      }
    } catch (e) {
      print("Erro ao buscar usuário: $e");
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

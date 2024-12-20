import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> getUserById(String userId) async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(userId).get();

      if (userDoc.exists) {
        return AppUser.fromJson(
            userDoc.id, userDoc.data() as Map<String, dynamic>);
      } else {
        print("Usuário não encontrado no Firestore.");
        return null;
      }
    } catch (e) {
      print("Erro ao buscar usuário no Firestore: $e | $userId");
      return null;
    }
  }

  Future<void> updateUser(AppUser user) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(user.id)
          .update(user.toJson());
      print("Usuário atualizado com sucesso!");
    } catch (e) {
      print("Erro ao atualizar usuário: $e");
    }
  }
}

import 'package:gamecamp/model/game.dart';
import 'package:firebase_database/firebase_database.dart';

class GameService {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('games');

  // Função para adicionar um novo jogo
  Future<void> addGame(Game game) async {
    try {
      await _dbRef.child(game.id).set(game.toJson());
      print("Jogo adicionado com sucesso!");
    } catch (e) {
      print("Erro ao adicionar jogo: $e");
    }
  }

  // Função para excluir um jogo
  Future<void> deleteGame(String gameId) async {
    try {
      await _dbRef.child(gameId).remove();
      print("Jogo excluído com sucesso!");
    } catch (e) {
      print("Erro ao excluir jogo: $e");
    }
  }

  // Função para atualizar um jogo
  Future<void> updateGame(Game game) async {
    try {
      await _dbRef.child(game.id).update(game.toJson());
      print("Jogo atualizado com sucesso!");
    } catch (e) {
      print("Erro ao atualizar jogo: $e");
    }
  }

  // Função para obter os jogos do Firebase como Stream
  Stream<List<Game>> getGamesStream() {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        Map<String, dynamic> gamesMap = Map<String, dynamic>.from(data);
        return gamesMap.entries.map((entry) {
          return Game.fromJson(
              entry.key, Map<String, dynamic>.from(entry.value));
        }).toList();
      } else {
        return [];
      }
    });
  }
}

import 'package:flutter/material.dart';
import 'package:gamecamp/model/game.dart';
import 'package:gamecamp/provider/gameService.dart';
import 'package:gamecamp/view/screen/GameScreenEdit.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({Key? key}) : super(key: key);

  @override
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final GameService _gameService = GameService();
  late Stream<List<Game>> _games;

  @override
  void initState() {
    super.initState();
    _games = _gameService.getGamesStream();
  }

  // Método para excluir o jogo após confirmação
  void _confirmDelete(String gameId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tem certeza?'),
          content: const Text('Você deseja excluir este jogo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () async {
                await _gameService.deleteGame(gameId);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jogo excluído com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Lista de Jogos')),
      body: StreamBuilder<List<Game>>(
        stream: _games,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum jogo cadastrado.'));
          }

          final games = snapshot.data!;
          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return ListTile(
                title: Text(game.name),
                subtitle: Text(game.brand),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        // Navega para a tela de edição e passa os dados do jogo
                        final updatedGame = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreenEdit(game: game),
                          ),
                        );

                        // Se o jogo foi atualizado, você pode atualizar a lista
                        if (updatedGame != null) {
                          // Atualize o jogo na lista ou banco de dados
                          _gameService.updateGame(updatedGame);
                          setState(() {}); // Recarrega a lista de jogos
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _confirmDelete(game.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

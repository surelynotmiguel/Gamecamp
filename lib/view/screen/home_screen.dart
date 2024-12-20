import 'dart:math'; // Para gerar números aleatórios
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gamecamp/model/game.dart';
import 'package:gamecamp/provider/CartProvider.dart'; // Importação do CartProvider
import 'package:provider/provider.dart'; // Importação do provider

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  late DatabaseReference _gamesRef;
  List<Game> games = [];

  @override
  void initState() {
    super.initState();
    _gamesRef = _database.ref('games');
    _loadGames();
  }

  void _loadGames() async {
    DataSnapshot snapshot = await _gamesRef.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> gamesData = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        games = gamesData.entries.map((entry) {
          return Game(
            id: entry.key,
            name: entry.value['name'],
            price: (entry.value['price'] as num).toDouble(),
            releaseDate: DateTime.parse(entry.value['releaseDate']),
            isOnline: entry.value['isOnline'],
            promotionalPrice: entry.value['promotionalPrice'] != null
                ? (entry.value['promotionalPrice'] as num).toDouble()
                : null,
            brand: entry.value['brand'],
            style: entry.value['style'],
            imageUrl: entry.value['imageUrl'],
          );
        }).toList();
      });
    } else {
      print('Nenhum jogo encontrado no Firebase.');
    }
  }

  // Função para selecionar aleatoriamente 5 jogos
  List<Game> _getRandomGames() {
    final random = Random();
    List<Game> randomGames = [];
    if (games.isNotEmpty) {
      while (randomGames.length < 5) {
        final game = games[random.nextInt(games.length)];
        if (!randomGames.contains(game)) {
          randomGames.add(game);
        }
      }
    }
    return randomGames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensagem de boas-vindas
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Bem-vindo ao GameCamp!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Título Populares
            const Text(
              'Populares',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Exibe os jogos populares aleatórios
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _getRandomGames().length,
              itemBuilder: (context, index) {
                return _buildGameCard(_getRandomGames()[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(Game game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Melhor alinhamento
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              game.imageUrl,
              height: 100, // Ajuste de altura
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do jogo
                Text(
                  game.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Evita overflow no nome
                ),
                const SizedBox(height: 5),

                Row(
                  children: [
                    // Verifica se o jogo é gratuito (preço 0)
                    game.price == 0
                        ? Text(
                            'Gratuito',
                            style: TextStyle(
                              color: game.promotionalPrice != null
                                  ? Colors
                                      .red // Se estiver em promoção, "Gratuito" em vermelho
                                  : Colors
                                      .green, // Se não estiver em promoção, "Gratuito" em verde
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          )
                        : Text(
                            'R\$ ${game.price.toStringAsFixed(2)}', // Exibe o preço normal
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                            ),
                          ),
                    if (game.promotionalPrice != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Promo: R\$ ${game.promotionalPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Chips de status
                Wrap(
                  spacing: 4.0,
                  children: [
                    if (game.promotionalPrice != null)
                      Chip(
                        label: const Text(
                          'Promoção',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                // Adicionando ao carrinho
                Provider.of<CartProvider>(context, listen: false)
                    .addToCart(game);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${game.name} foi adicionado ao carrinho!'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

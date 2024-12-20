import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import 'package:gamecamp/model/game.dart';
import 'package:gamecamp/provider/CartProvider.dart';
import 'package:gamecamp/provider/game_filter_bloc.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  late DatabaseReference _gamesRef;
  List<Game> games = [];
  final GameFilterBloc _filterBloc = GameFilterBloc();

  final List<String> _styles = [
    'Ação',
    'Aventura',
    'Corrida',
    'Esportes',
    'Estratégia',
    'FPS',
    'Puzzle',
    'RPG',
    'Simulação',
    'Terror',
  ]; // Lista de estilos disponíveis

  final List<String> selectedStyles = []; // Estilos selecionados

  String selectedBrand = 'Todos Jogos'; // Estado inicial para todas as marcas

  // Lista de marcas e cores associadas
  final List<String> brands = [
    'Todos Jogos',
    'Hoyoverse',
    'Nintendo',
    'Xbox',
  ];

  final Map<String, Color> brandColors = {
    'Todos Jogos': Color(0xff0066ff),
    'Hoyoverse': Color(0xffffe91c),
    'Nintendo': Color(0xffe12525),
    'Xbox': Color(0xff2dc534),
  };

  Widget _buildBrandButtons() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: brands.map((brand) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedBrand == brand
                ? brandColors[brand] ?? Colors.blue
                : Colors.grey.shade300,
            foregroundColor:
                selectedBrand == brand ? Colors.white : Colors.black,
          ),
          onPressed: () {
            setState(() {
              selectedBrand = brand;
            });

            if (selectedBrand == 'Todos Jogos') {
              _filterBloc.updateFilters(brand: null);
            } else {
              _filterBloc.updateFilters(brand: selectedBrand);
            }
          },
          child: Text(
            brand,
            style: TextStyle(
              color: selectedBrand == brand ? Colors.white : Colors.black,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPromoSwitch(bool isPromo) {
    return Row(
      children: [
        Switch(
          value: isPromo,
          onChanged: (value) {
            _filterBloc.updateFilters(promo: value);
          },
        ),
        const Text('Somente Jogos Em Promoção'),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _gamesRef = _database.ref('games');
    _loadGames();
  }

  @override
  void dispose() {
    _filterBloc.dispose();
    super.dispose();
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

  List<Game> _applyFilters(List<Game> games, Map<String, dynamic> filters) {
    return games.where((game) {
      final isOnlineMatch = !filters['online'] || game.isOnline;
      final isPromoMatch = !filters['promo'] ||
          (game.promotionalPrice != null &&
              game.promotionalPrice! < game.price);
      final isPriceMatch =
          (game.promotionalPrice ?? game.price) <= filters['maxPrice'];
      final isStyleMatch =
          selectedStyles.isEmpty || selectedStyles.contains(game.style);

      // Corrigido: Se o filtro de marca for null, não deve ser aplicado
      final isBrandMatch =
          filters['brand'] == null || game.brand == filters['brand'];

      return isOnlineMatch &&
          isPromoMatch &&
          isPriceMatch &&
          isStyleMatch &&
          isBrandMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _filterBloc.filtersStream,
        initialData: const {'online': false, 'promo': false, 'maxPrice': 499.0},
        builder: (context, snapshot) {
          final filters = snapshot.data!;
          final filteredGames = _applyFilters(games, filters);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBrandButtons(), // Adicionando os botões de marca
                _buildFilterControls(filters),
                const SizedBox(height: 20),
                _buildStyleCheckboxes(),
                const SizedBox(height: 20),
                _buildGameCategory('Jogos Disponíveis', filteredGames),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterControls(Map<String, dynamic> filters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: filters['online'],
              onChanged: (value) {
                _filterBloc.updateFilters(online: value);
              },
            ),
            const Text('Online'),
          ],
        ),
        Row(
          children: [
            const Text('Preço:'),
            Expanded(
              child: Slider(
                value: filters['maxPrice'],
                min: 0,
                max: 500,
                divisions: 100,
                label: 'R\$ ${filters['maxPrice'].toStringAsFixed(0)}',
                onChanged: (value) {
                  _filterBloc.updateFilters(maxPrice: value);
                },
              ),
            ),
            const Text('Reais'),
          ],
        ),
        const SizedBox(height: 10),
        _buildPromoSwitch(filters['promo']),
      ],
    );
  }

  Widget _buildStyleCheckboxes() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _styles.map((style) {
        return FilterChip(
          label: Text(style),
          selected: selectedStyles.contains(style),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedStyles.add(style);
              } else {
                selectedStyles.remove(style);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildGameCategory(String category, List<Game> games) {
    if (games.isEmpty) {
      return const Center(child: Text('Nenhum jogo encontrado.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75, // Ajuste o aspecto para caber na tela
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return _buildGameCard(games[index]);
          },
        ),
      ],
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
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Evita overflow no nome
                ),
                const SizedBox(height: 4),

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
                            ),
                          )
                        : Text(
                            'R\$ ${game.price.toStringAsFixed(2)}', // Exibe o preço normal
                            style: TextStyle(color: Colors.green),
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

import 'package:flutter/material.dart';
import 'package:gamecamp/model/game.dart'; // Sua classe Game
import 'package:gamecamp/provider/gameService.dart';

class GameScreenCadastro extends StatefulWidget {
  const GameScreenCadastro({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreenCadastro> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _releaseDateController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isOnline = false;
  String? _selectedStyle;

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
    'Terror'
  ];

  final GameService _gameService = GameService();

  void _saveGame() async {
    final String name = _nameController.text;
    final double price = double.tryParse(_priceController.text) ?? 0;
    final DateTime releaseDate =
        DateTime.tryParse(_releaseDateController.text) ?? DateTime.now();
    final String brand = _brandController.text;
    final String style = _selectedStyle ?? '';
    final String imageUrl = _imageUrlController.text;

    final String gameId = DateTime.now().millisecondsSinceEpoch.toString();

    final Game newGame = Game(
      id: gameId,
      name: name,
      price: price,
      releaseDate: releaseDate,
      isOnline: _isOnline,
      promotionalPrice: null,
      brand: brand,
      style: style,
      imageUrl: imageUrl,
    );

    try {
      await _gameService.addGame(newGame);

      _nameController.clear();
      _priceController.clear();
      _releaseDateController.clear();
      _brandController.clear();
      _imageUrlController.clear();
      setState(() {
        _selectedStyle = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar o jogo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Cadastrar Jogo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do Jogo'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Preço'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _releaseDateController,
              decoration:
                  const InputDecoration(labelText: 'Data de Lançamento'),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Marca'),
            ),
            DropdownButton<String>(
              hint: const Text('Selecione o Estilo'),
              value: _selectedStyle,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStyle = newValue;
                });
              },
              items: _styles.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'URL da Imagem'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isOnline,
                  onChanged: (bool? value) {
                    setState(() {
                      _isOnline = value ?? false;
                    });
                  },
                ),
                const Text('Jogo Online'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveGame,
              child: const Text('Cadastrar Jogo'),
            ),
          ],
        ),
      ),
    );
  }
}

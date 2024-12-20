import 'package:flutter/material.dart';
import 'package:gamecamp/model/game.dart';
import 'package:gamecamp/provider/gameService.dart';

class GameScreenEdit extends StatefulWidget {
  final Game game;

  const GameScreenEdit({Key? key, required this.game}) : super(key: key);

  @override
  _GameScreenEditState createState() => _GameScreenEditState();
}

class _GameScreenEditState extends State<GameScreenEdit> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _releaseDateController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _styleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _promotionalPriceController =
      TextEditingController();

  bool _isOnline = false;
  String? _selectedStyle;

  final GameService _gameService = GameService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.game.name;
    _priceController.text = widget.game.price.toString();
    _releaseDateController.text = widget.game.releaseDate.toString();
    _brandController.text = widget.game.brand;
    _styleController.text = widget.game.style;
    _imageUrlController.text = widget.game.imageUrl;
    _promotionalPriceController.text =
        widget.game.promotionalPrice?.toString() ?? '';
    _isOnline = widget.game.isOnline;
    _selectedStyle = widget.game.style;
  }

  void _updateGame() async {
    final String name = _nameController.text;
    final double price = double.tryParse(_priceController.text) ?? 0;
    final DateTime releaseDate =
        DateTime.tryParse(_releaseDateController.text) ?? DateTime.now();
    final String brand = _brandController.text;
    final String style = _styleController.text;
    final double? promotionalPrice = _promotionalPriceController.text.isNotEmpty
        ? double.tryParse(_promotionalPriceController.text)
        : null;

    final String imageUrl = _imageUrlController.text;
    if (promotionalPrice != null) {
      if (promotionalPrice >= price && promotionalPrice > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'O preço promocional não pode ser maior ou igual ao preço normal!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    final Game updatedGame = Game(
      id: widget.game.id,
      name: name,
      price: price,
      releaseDate: releaseDate,
      isOnline: _isOnline,
      promotionalPrice: promotionalPrice,
      brand: brand,
      style: style,
      imageUrl: imageUrl,
    );

    try {
      await _gameService.updateGame(updatedGame);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jogo atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar o jogo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Jogo')),
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
            TextField(
              controller: _styleController,
              decoration: const InputDecoration(labelText: 'Estilo do Jogo'),
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'URL da Imagem'),
            ),
            TextField(
              controller: _promotionalPriceController,
              decoration: const InputDecoration(
                  labelText: 'Preço promocional (se houver)'),
              keyboardType: TextInputType.number,
            ),
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
                Text('Jogo ${_isOnline ? 'Online' : 'Offline'}'),
              ],
            ),
            ElevatedButton(
              onPressed: _updateGame,
              child: const Text('Atualizar Jogo'),
            ),
          ],
        ),
      ),
    );
  }
}

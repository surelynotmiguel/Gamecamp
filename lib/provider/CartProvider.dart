import 'package:flutter/material.dart';
import 'package:gamecamp/model/game.dart';

class CartProvider with ChangeNotifier {
  final Map<Game, int> _cartItems =
      {}; // Agora usamos um Map para gerenciar quantidades.

  Map<Game, int> get cartItems => _cartItems;

  /// Adiciona um jogo ao carrinho ou aumenta a quantidade.
  void addToCart(Game game) {
    if (_cartItems.containsKey(game)) {
      _cartItems[game] = _cartItems[game]! + 1;
    } else {
      _cartItems[game] = 1;
    }
    notifyListeners();
  }

  /// Diminui a quantidade de um jogo no carrinho ou remove o jogo se a quantidade for 0.
  void decreaseQuantity(Game game) {
    if (_cartItems.containsKey(game) && _cartItems[game]! > 1) {
      _cartItems[game] = _cartItems[game]! - 1;
    } else {
      _cartItems.remove(game);
    }
    notifyListeners();
  }

  /// Remove completamente um jogo do carrinho.
  void removeFromCart(Game game) {
    _cartItems.remove(game);
    notifyListeners();
  }

  /// Obtém a quantidade de um jogo no carrinho.
  int getQuantity(Game game) {
    return _cartItems[game] ?? 0;
  }

  /// Calcula o preço total dos itens no carrinho.
  double get totalPrice {
    return _cartItems.entries.fold(0, (sum, entry) {
      final game = entry.key;
      final quantity = entry.value;
      return sum + (game.promotionalPrice ?? game.price) * quantity;
    });
  }

  /// Remove todos os itens do carrinho.
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

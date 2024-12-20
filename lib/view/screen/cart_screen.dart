import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamecamp/provider/CartProvider.dart';
import 'package:gamecamp/model/game.dart';
import 'package:gamecamp/view/screen/purchase_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:gamecamp/provider/UserSession.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;
    final totalPrice = cartProvider.totalPrice;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Carrinho',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: cartItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Seu carrinho está vazio!',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        List<Game> cartKeys = cartItems.keys.toList();
                        final game = cartKeys[index];
                        final quantity = cartItems[game]!;
                        return _buildCartItem(game, quantity, cartProvider);
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Valor Total:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  'R\$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  if (cartItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Adicione itens ao carrinho antes de finalizar!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    // Buscar informações do usuário no Firebase
                    final userInfo = await _fetchUserInfo();

                    if (userInfo != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PurchaseScreen(
                            userInfo: userInfo,
                            cartItems: cartItems,
                            totalPrice: totalPrice,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Erro ao buscar informações do usuário.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Finalizar Compra',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Game game, int quantity, CartProvider cartProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            game.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                'R\$${game.price.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.black),
                    onPressed: () {
                      cartProvider.decreaseQuantity(game);
                    },
                  ),
                  Text(
                    quantity.toString(),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: () {
                      cartProvider.addToCart(game);
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      cartProvider.removeFromCart(game);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Map<String, String>?> _fetchUserInfo() async {
    try {
      // Recupera o userId salvo no Singleton
      String? userId = UserSession().userId;

      if (userId == null) {
        print('Erro: userId não encontrado no UserSession.');
        return null;
      }

      // Busca o documento do Firestore com o userId armazenado
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return {
          'name': userDoc['nome'],
          'cpf': userDoc['cpf'],
          'address': userDoc['logradouro'],
        };
      } else {
        print('Erro: Documento do usuário não encontrado no Firestore.');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar informações do usuário: $e');
      return null;
    }
  }
}

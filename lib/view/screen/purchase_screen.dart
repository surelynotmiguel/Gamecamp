import 'package:flutter/material.dart';
import 'package:gamecamp/model/game.dart';
import 'package:gamecamp/view/layout/side_tab_menu.dart';
import 'package:provider/provider.dart';
import 'package:gamecamp/provider/CartProvider.dart';

class PurchaseScreen extends StatefulWidget {
  final Map<String, String> userInfo; // Dados do usuário
  final Map<Game, int> cartItems; // Itens do carrinho
  final double totalPrice; // Preço total

  PurchaseScreen({
    Key? key,
    required this.userInfo,
    required this.cartItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  String? selectedState;

  final List<String> formasPagamento = [
    'Cartão de Crédito',
    'Cartão de Débito',
    'Pix',
    'Boleto',
    'Paypal'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo e imagem do carrinho
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://raw.githubusercontent.com/surelynotmiguel/ProgMobile/refs/heads/main/gamecamp_icon.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(width: 30),
              ],
            ),
            const SizedBox(height: 30),
            Image.network(
              'https://raw.githubusercontent.com/surelynotmiguel/ProgMobile/refs/heads/main/cartt.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Compra efetuada com Sucesso!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            // Informações do usuário
            Text(
              'Dados Pessoais:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text('Nome: ${widget.userInfo['name']}'),
            Text('CPF: ${widget.userInfo['cpf']}'),
            Text('Endereço: ${widget.userInfo['address']}'),
            const SizedBox(height: 20),
            // Dados da compra
            Text(
              'Dados da Compra:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final game = widget.cartItems.keys.toList()[index];
                  final quantity = widget.cartItems[game]!;
                  return ListTile(
                    title: Text('${quantity}x ${game.name}'),
                    subtitle: Text(
                        'R\$${(game.price * quantity).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Valor total: R\$${widget.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildDropdownField('Formas de Pagamento', formasPagamento),
            const SizedBox(height: 30),
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
                onPressed: () {
                  // Limpa o carrinho
                  Provider.of<CartProvider>(context, listen: false).clearCart();

                  // Exibe a SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compra concluída com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Redireciona para a tela inicial após mostrar a SnackBar
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SideMenuBar(),
                      ),
                    );
                  });
                },
                child: const Text(
                  'Concluir',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      value: selectedState,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedState = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo é obrigatório';
        }
        return null;
      },
    );
  }
}

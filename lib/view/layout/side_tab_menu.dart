import 'package:flutter/material.dart';
import 'package:gamecamp/view/screen/GameListScreen.dart';
import 'package:gamecamp/view/screen/cart_screen.dart';
import 'package:gamecamp/view/screen/game_screen.dart';
import 'package:gamecamp/view/screen/home_screen.dart';
import 'package:gamecamp/view/screen/profile_screen.dart';
import 'package:gamecamp/view/screen/game_screen_cadastro.dart';
import 'package:gamecamp/view/screen/login_screen.dart';
import 'package:gamecamp/provider/UserSession.dart'; // Importando o UserProvider

class SideMenuBar extends StatefulWidget {
  const SideMenuBar({Key? key}) : super(key: key);

  @override
  State<SideMenuBar> createState() => _SideMenuBarState();
}

class _SideMenuBarState extends State<SideMenuBar> {
  int _currentScreen = 0;

  @override
  Widget build(BuildContext context) {
    // Pegando a informação do admin da UserSession
    bool isAdmin = UserSession().isAdmin ?? false;
    String? profilePictureUrl = UserSession().fotoDePerfil;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.network(
              'https://raw.githubusercontent.com/surelynotmiguel/ProgMobile/refs/heads/main/gamecamp_icon.png',
              width: 80,
              height: 80,
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                _currentScreen = 3;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(profilePictureUrl ??
                      'https://raw.githubusercontent.com/surelynotmiguel/ProgMobile/refs/heads/main/luna.jpg')),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentScreen,
        children: const [
          HomeScreen(),
          GameScreen(),
          CartScreen(),
          ProfileScreen(),
          GameScreenCadastro(),
          GameListScreen()
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Image.network(
                'https://raw.githubusercontent.com/surelynotmiguel/ProgMobile/refs/heads/main/gamecamp_icon.png',
              ),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  _currentScreen = 0;
                });
                Navigator.pop(context);
              },
              leading: const Icon(Icons.home),
              title: const Text("Home"),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  _currentScreen = 1;
                });
                Navigator.pop(context);
              },
              leading: const Icon(Icons.games),
              title: const Text("Jogos"),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  _currentScreen = 2;
                });
                Navigator.pop(context);
              },
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Carrinho"),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  _currentScreen = 3;
                });
                Navigator.pop(context);
              },
              leading: const Icon(Icons.person),
              title: const Text("Perfil"),
            ),
            if (isAdmin) ...[
              ListTile(
                onTap: () {
                  setState(() {
                    _currentScreen = 4;
                  });
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.person),
                title: const Text("Cadastro de Jogos"),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _currentScreen = 5;
                  });
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.list),
                title: const Text("Lista de Jogos"),
              ),
            ],
            ListTile(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sessão finalizada.'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              leading: const Icon(Icons.logout),
              title: const Text("Sair"),
            ),
          ],
        ),
      ),
    );
  }
}

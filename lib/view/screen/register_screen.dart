import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final List<String> gameGenres = [
    'Ação',
    'Aventura',
    'RPG',
    'Esporte',
    'Ritmo',
    'Cartas',
    'Plataforma',
    'Online',
    'Corrida',
    'Terror',
    'Luta',
    'Puzzle'
  ];

  final Map<String, bool> selectedGenres = {};
  String selectedGender = '';
  bool agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    for (var genre in gameGenres) {
      selectedGenres[genre] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              'https://raw.githubusercontent.com/surelynotmiguel/ProgMobile/refs/heads/main/gamecamp_icon.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            _buildTextField(nameController, 'Nome Completo'),
            const SizedBox(height: 10),
            _buildTextField(emailController, 'Email'),
            const SizedBox(height: 10),
            _buildTextField(cpfController, 'CPF'),
            const SizedBox(height: 10),
            _buildTextField(cepController, 'CEP'),
            const SizedBox(height: 10),
            _buildTextField(addressController, 'Endereço'),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gênero de jogos favoritos',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              children: gameGenres.map((genre) {
                return CheckboxListTile(
                  title: Text(genre),
                  value: selectedGenres[genre],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedGenres[genre] = value!;
                    });
                  },
                );
              }).toList(),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gênero',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                _buildRadioButton('Masculino'),
                _buildRadioButton('Feminino'),
                _buildRadioButton('Outro'),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(passwordController, 'Senha', obscureText: true),
            const SizedBox(height: 10),
            _buildTextField(confirmPasswordController, 'Confirme sua Senha',
                obscureText: true),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: agreeToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      agreeToTerms = value!;
                    });
                  },
                ),
                const Text('Concordo com os Termos e Condições'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: agreeToTerms ? _register : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Registre - se',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildRadioButton(String value) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(value),
        value: value,
        groupValue: selectedGender,
        onChanged: (String? newValue) {
          setState(() {
            selectedGender = newValue!;
          });
        },
      ),
    );
  }

  void _register() {
    // Ação de registro
    // Aqui você pode adicionar a lógica para salvar os dados ou realizar uma ação de registro
  }
}

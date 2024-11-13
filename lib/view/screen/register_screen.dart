import 'package:flutter/material.dart';
import 'package:gamecamp/data/data_handler.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController dataDeNascimentoController =
      TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController logradouroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
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

    cepController.addListener(() {
      if (cepController.text.length == 8) {
        _buscarEndereco();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dataDeNascimentoController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                'https://raw.githubusercontent.com/surelynotmiguel/ProgMobile/refs/heads/main/gamecamp_icon.png',
                width: 200,
                height: 200,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dados do usuário',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(nameController, 'Nome Completo'),
              const SizedBox(height: 10),
              _buildTextField(emailController, 'E-mail'),
              const SizedBox(height: 10),
              _buildTextField(telefoneController, 'Telefone'),
              const SizedBox(height: 10),
              _buildDateField(
                  dataDeNascimentoController, 'Data de Nascimento', context),
              const SizedBox(height: 10),
              _buildTextField(cpfController, 'CPF'),
              const SizedBox(height: 10),
              _buildTextField(cepController, 'CEP'),
              const SizedBox(height: 10),
              _buildTextField(logradouroController, 'Logradouro'),
              const SizedBox(height: 10),
              _buildTextField(numeroController, 'Número'),
              const SizedBox(height: 10),
              _buildTextField(bairroController, 'Bairro'),
              const SizedBox(height: 10),
              _buildTextField(cidadeController, 'Cidade'),
              const SizedBox(height: 10),
              _buildTextField(estadoController, 'Estado'),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Gênero de jogos favoritos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Gênero',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  _buildRadioButton('Masculino'),
                  _buildRadioButton('Feminino'),
                  _buildRadioButton('Outro'),
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField(passwordController, 'Senha', obscureText: true),
              const SizedBox(height: 10),
              _buildTextField(confirmPasswordController, 'Confirme sua Senha',
                  obscureText: true),
              const SizedBox(height: 20),
              Row(
                children: [
                  Switch(
                    value: agreeToTerms,
                    onChanged: (bool value) {
                      setState(() {
                        agreeToTerms = value;
                      });
                    },
                  ),
                  const Text(
                    'Concordo com os Termos e Condições',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: agreeToTerms ? _register : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreenAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo é obrigatório';
        }
        return null;
      },
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

  Widget _buildDateField(
      TextEditingController controller, String label, BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo é obrigatório';
        }
        return null;
      },
    );
  }

  Future<void> _buscarEndereco() async {
    final String cep = cepController.text.replaceAll(RegExp(r'\D'), '');

    try {
      final endereco = await DataHandler.buscarEndereco(cep);

      if (!mounted) return;

      if (endereco.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Endereço não encontrado para este CEP'),
          ),
        );
        return;
      }

      setState(() {
        logradouroController.text = endereco['logradouro'] ?? '';
        bairroController.text = endereco['bairro'] ?? '';
        cidadeController.text = endereco['cidade'] ?? '';
        estadoController.text = endereco['estado'] ?? '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar endereço: $e')),
        );
      }
    }
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      if (!DataHandler.isCpfValid(cpfController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CPF inválido!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!DataHandler.isCepValid(cepController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CEP inválido!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!DataHandler.isEmailValid(emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail inválido!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!DataHandler.isPhoneNumberValid(telefoneController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Telefone inválido!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Sucesso"),
            content: const Text("Cadastro realizado com sucesso!"),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../data/data_handler.dart';
import '../../provider/UserSession.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  String? selectedState;
  String pictureUrl = '';
  String profilePictureUrl = '';

  final List<String> countryStates = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO'
  ];

  final maskCpf = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final maskCep = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final maskPhone = MaskTextInputFormatter(
    initialText: '',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  void updatePhoneMask(String rawValue) {
    if (rawValue.length >= 10) {
      maskPhone.updateMask(mask: '(##) #####-####');
    } else {
      maskPhone.updateMask(mask: '(##) ####-####');
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchUserInfo().then((userInfo) {
      if (userInfo != null) {
        setState(() {
          nameController.text = userInfo['nome'] ?? '';
          emailController.text = userInfo['email'] ?? '';
          telefoneController.text = userInfo['telefone'] ?? '';
          dataDeNascimentoController.text = userInfo['dataDeNascimento'] ?? '';
          cpfController.text = userInfo['cpf'] ?? '';
          cepController.text = userInfo['cep'] ?? '';
          logradouroController.text = userInfo['logradouro'] ?? '';
          numeroController.text = userInfo['numero'] ?? '';
          bairroController.text = userInfo['bairro'] ?? '';
          cidadeController.text = userInfo['cidade'] ?? '';
          selectedState = userInfo['estado'] ?? 'AC';
          pictureUrl = userInfo['fotoDePerfil']!;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao carregar as informações do usuário."),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    cepController.addListener(() {
      if (cepController.text.length == 9) {
        _buscarEndereco();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            const Text("Perfil", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profilePictureUrl),
                    onBackgroundImageError: (_, __) {
                      setState(() {
                        profilePictureUrl = pictureUrl;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Bem-vindo(a), ${nameController.text}!",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Email: ${emailController.text}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const Divider(height: 40, thickness: 1),
            const Text(
              "Informações Pessoais",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextField(nameController, "Nome Completo"),
            const SizedBox(height: 10),
            _buildTextField(emailController, "E-mail"),
            const SizedBox(height: 10),
            _buildTextField(telefoneController, "Telefone"),
            const SizedBox(height: 10),
            _buildDateField(
                dataDeNascimentoController, "Data de Nascimento", context),
            const SizedBox(height: 10),
            _buildTextField(cpfController, "CPF"),
            const Divider(height: 40, thickness: 1),
            const Text(
              "Endereço",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextField(cepController, "CEP"),
            const SizedBox(height: 10),
            _buildTextField(logradouroController, "Logradouro"),
            const SizedBox(height: 10),
            _buildTextField(numeroController, "Número"),
            const SizedBox(height: 10),
            _buildTextField(bairroController, "Bairro"),
            const SizedBox(height: 10),
            _buildTextField(cidadeController, "Cidade"),
            const SizedBox(height: 10),
            _buildDropdownField("Estado", countryStates),
            const Divider(height: 40, thickness: 1),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Salvar Alterações",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _deleteProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Deletar Conta",
                  style: TextStyle(fontSize: 18, color: Colors.black),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false, MaskTextInputFormatter? maskFormatter}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      inputFormatters: maskFormatter != null ? [maskFormatter] : [],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        if (maskFormatter == maskPhone) {
          updatePhoneMask(maskPhone.getUnmaskedText());
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo é obrigatório';
        }
        return null;
      },
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

  Future<Map<String, String>?> _fetchUserInfo() async {
    try {
      String? userId = UserSession().userId;

      if (userId == null) {
        print('Erro: userId não encontrado no UserSession.');
        return null;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return {
          'nome': userDoc['nome'],
          'email': userDoc['email'],
          'telefone': userDoc['telefone'],
          'dataDeNascimento': userDoc['dataDeNascimento'],
          'cpf': userDoc['cpf'],
          'cep': userDoc['cep'],
          'logradouro': userDoc['logradouro'],
          'numero': userDoc['numero'],
          'bairro': userDoc['bairro'],
          'cidade': userDoc['cidade'],
          'estado': userDoc['estado'],
          'fotoDePerfil': userDoc['fotoDePerfil'],
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
        selectedState = endereco['estado'] ?? '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar endereço: $e')),
        );
      }
    }
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

  Future<void> _updateProfile() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        telefoneController.text.isEmpty ||
        dataDeNascimentoController.text.isEmpty ||
        cpfController.text.isEmpty ||
        cepController.text.isEmpty ||
        logradouroController.text.isEmpty ||
        numeroController.text.isEmpty ||
        bairroController.text.isEmpty ||
        cidadeController.text.isEmpty ||
        selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, preencha todos os campos obrigatórios."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      String? userId = UserSession().userId;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Usuário não encontrado."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final updatedUserData = {
        'nome': nameController.text,
        'email': emailController.text,
        'telefone': telefoneController.text,
        'dataDeNascimento': dataDeNascimentoController.text,
        'cpf': cpfController.text,
        'cep': cepController.text,
        'logradouro': logradouroController.text,
        'numero': numeroController.text,
        'bairro': bairroController.text,
        'cidade': cidadeController.text,
        'estado': selectedState,
        'fotoDePerfil': pictureUrl,
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update(updatedUserData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perfil atualizado com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao atualizar perfil: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteProfile() async {
    try {
      String? userId = UserSession().userId;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Usuário não encontrado."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .delete();

      firebase_auth.User? user =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Conta deletada com sucesso."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao deletar perfil: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

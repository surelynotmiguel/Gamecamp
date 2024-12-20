import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gamecamp/data/data_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:universal_io/io.dart' as universal_io;

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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

  final Map<String, bool> selectedGenres = {};
  String selectedGender = '';
  String? selectedState;
  bool agreeToTerms = false;
  bool isAdmin = false;
  final String defaultImageUrl =
      'https://raw.githubusercontent.com/surelynotmiguel/ProgMobile/refs/heads/main/luna.jpg';

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

  bool get isMobileDevice {
    return universal_io.Platform.isAndroid || universal_io.Platform.isIOS;
  }

  @override
  void initState() {
    super.initState();
    for (var genre in gameGenres) {
      selectedGenres[genre] = false;
    }

    cepController.addListener(() {
      if (cepController.text.length == 9) {
        _buscarEndereco();
      }
    });
  }

  Future<void> _selectImage() async {
    if (!isMobileDevice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'A seleção de imagens só está disponível em dispositivos móveis.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
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
              GestureDetector(
                onTap: _selectImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : NetworkImage(defaultImageUrl) as ImageProvider,
                  backgroundColor: Colors.grey[300],
                  child: _selectedImage == null && isMobileDevice
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Foto de Perfil',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
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
              _buildTextField(telefoneController, 'Telefone',
                  maskFormatter: maskPhone),
              const SizedBox(height: 10),
              _buildDateField(
                  dataDeNascimentoController, 'Data de Nascimento', context),
              const SizedBox(height: 10),
              _buildTextField(cpfController, 'CPF', maskFormatter: maskCpf),
              const SizedBox(height: 10),
              _buildTextField(cepController, 'CEP', maskFormatter: maskCep),
              const SizedBox(height: 10),
              _buildTextField(logradouroController, 'Logradouro'),
              const SizedBox(height: 10),
              _buildTextField(numeroController, 'Número'),
              const SizedBox(height: 10),
              _buildTextField(bairroController, 'Bairro'),
              const SizedBox(height: 10),
              _buildTextField(cidadeController, 'Cidade'),
              const SizedBox(height: 10),
              _buildDropdownField('Estado', countryStates),
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

  Future<String?> _uploadProfileImage(File imageFile, String userId) async {
    try {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      final UploadTask uploadTask = storageRef.putFile(imageFile);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage != null) {
        final String fileType =
            _selectedImage!.path.split('.').last.toLowerCase();
        const List<String> supportedTypes = ['jpg', 'jpeg', 'png'];

        if (!supportedTypes.contains(fileType)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Formato de imagem não suportado! Use JPG, JPEG ou PNG.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _selectedImage = null;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma foto selecionada, será usada a padrão!'),
            backgroundColor: Colors.orange,
          ),
        );
      }

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

      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('As senhas não conferem!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final userId = userCredential.user!.uid;

        String? imageUrl = defaultImageUrl;
        if (_selectedImage != null) {
          imageUrl = await _uploadProfileImage(_selectedImage!, userId) ??
              defaultImageUrl;
        }

        final profileData = {
          "userId": userId,
          "nome": nameController.text.trim(),
          "email": emailController.text.trim(),
          "telefone": telefoneController.text.trim(),
          "dataDeNascimento": dataDeNascimentoController.text.trim(),
          "cpf": cpfController.text.trim(),
          "cep": cepController.text.trim(),
          "logradouro": logradouroController.text.trim(),
          "numero": numeroController.text.trim(),
          "bairro": bairroController.text.trim(),
          "cidade": cidadeController.text.trim(),
          "estado": selectedState,
          "generosFavoritos": selectedGenres.keys
              .where((genre) => selectedGenres[genre]!)
              .toList(),
          "genero": selectedGender,
          "fotoDePerfil": imageUrl,
          "isAdmin": isAdmin
        };

        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .set(profileData);

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
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

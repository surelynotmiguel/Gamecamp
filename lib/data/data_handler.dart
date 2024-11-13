import 'dart:convert';
import 'package:http/http.dart' as http;

class DataHandler {
  static bool isCpfValid(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');

    if (cpf.length != 11) {
      return false;
    }

    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) {
      return false;
    }

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstVerifierDigit = (sum * 10 % 11) % 10;

    if (firstVerifierDigit != int.parse(cpf[9])) {
      return false;
    }

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondVerifierDigit = (sum * 10 % 11) % 10;

    return secondVerifierDigit == int.parse(cpf[10]);
  }

  static bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  static bool isCepValid(String cep) {
    return RegExp(r'^\d{8}$').hasMatch(cep);
  }

  static bool isPhoneNumberValid(String phone) {
    phone = phone.replaceAll(RegExp(r'[\s()-]'), '');
    final phoneRegex = RegExp(r'^(?:\d{2})?(?:9\d{8}|\d{8})$');
    return phoneRegex.hasMatch(phone);
  }

  static Future<Map<String, String>> buscarEndereco(String cep) async {
    cep = cep.replaceAll(RegExp(r'\D'), '');

    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> dados = json.decode(response.body);

        if (dados.containsKey('erro') && dados['erro'] == true) {
          throw 'CEP não encontrado';
        }

        return {
          'logradouro': dados['logradouro'] ?? '',
          'bairro': dados['bairro'] ?? '',
          'cidade': dados['localidade'] ?? '',
          'estado': dados['uf'] ?? '',
        };
      } else {
        throw 'Falha na requisição';
      }
    } catch (e) {
      throw 'Erro ao buscar o endereço: $e';
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://vpsserveur.itgrafikadmin.fun/acnu-api/api';
  login(String username, String password) async {
    var headers = {'content-type': 'application/json'};
    Map body = {
      'username': username.trim(),
      'password': password.trim(),
    };
    final Uri url = Uri.parse('$baseUrl/login/users');

    final response =
        await http.post(url, body: jsonEncode(body), headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final SharedPreferences _prefs = await SharedPreferences.getInstance();

      final json = jsonDecode(response.body);
      var token = json['token'];
      var userID = json['userId'];
      final SharedPreferences? prefs = await _prefs;
      await prefs?.setString('token', token);
      await prefs?.setString('userId', userID.toString());
      // Get.off(EntryPage());
    } else {
      throw Exception('Erreur de connexion');
    }
  }

  Future<Map<String, dynamic>> fetchData(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/data'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des données');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/user_model.dart';
import '../models/gaji_model.dart';
import '../models/tpp_model.dart';

class ApiService {
  // 1. LOGIN
  Future<User?> login(String nip, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Config.loginUrl),
        body: {'nip': nip, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['access_token'];
        
        // Simpan Token di HP
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('nip', nip);

        return User.fromJson(data['user'], token: token);
      }
    } catch (e) {
      print("Error Login: $e");
    }
    return null;
  }

  // 2. GET GAJI
  Future<List<Gaji>> getGajiHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(Config.gajiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Wajib kirim token
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Sesuai struktur JSON: root -> data (array)
        List<dynamic> listData = json['data']; 
        return listData.map((e) => Gaji.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error Get Gaji: $e");
    }
    return [];
  }

  Future<List<Tpp>> getTppHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(Config.tppUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        List<dynamic> listData = json['data'];
        return listData.map((e) => Tpp.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error Get TPP: $e");
    }
    return [];
  }

}
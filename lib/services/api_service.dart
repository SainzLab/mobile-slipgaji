import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/user_model.dart';
import '../models/gaji_model.dart';
import '../models/tpp_model.dart';
import '../models/potongan_tpp_model.dart';
import '../models/potongan_gaji_model.dart';

class ApiService {
  Future<User?> login(String nip, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Config.loginUrl),
        body: {'nip': nip, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['access_token'];
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', token);
        await prefs.setString('nip', nip);
        await prefs.setString('nama_pegawai', data['user']['nama_pegawai'] ?? "Nama Tidak Diketahui");

        return User.fromJson(data['user'], token: token);
      }
    } catch (e) {
      print("Error Login: $e");
    }
    return null;
  }

  Future<List<Gaji>> getGajiHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(Config.gajiUrl),
        headers: {
          'Authorization': 'Bearer $token', 
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
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

  Future<List<PotonganTpp>> getPotonganTppHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(Config.potonganTppUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        List<dynamic> listData = json['data'];
        return listData.map((e) => PotonganTpp.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error Get Potongan TPP: $e");
    }
    return [];
  }

  Future<List<PotonganGaji>> getPotonganGajiHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(Config.potonganGajiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        List<dynamic> listData = json['data'];
        return listData.map((e) => PotonganGaji.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error Get Potongan Gaji: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse(Config.changePasswordUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );

      final json = jsonDecode(response.body);
      
      // Cek apakah sukses berdasarkan status code 200
      if (response.statusCode == 200 && json['status'] == 'success') {
        return {'success': true, 'message': json['message']};
      } else {
        // Tangkap pesan error dari Laravel (misal: password lama salah / konfirmasi tidak cocok)
        return {'success': false, 'message': json['message'] ?? 'Gagal mengubah password.'};
      }
    } catch (e) {
      print("Error Change Password: $e");
      return {'success': false, 'message': 'Terjadi kesalahan jaringan.'};
    }
  }

}
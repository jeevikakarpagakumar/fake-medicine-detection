import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/medicine_result.dart';

class ApiService {
  // Replace with your backend IP when running on a real device
  // Use 10.0.2.2 for Android emulator
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<MedicineResult> verifyText(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-text'),
      body: {'text': text},
    );
    if (response.statusCode == 200) {
      return MedicineResult.fromJson(jsonDecode(response.body));
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  static Future<MedicineResult> uploadImage(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload-image'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      return MedicineResult.fromJson(jsonDecode(response.body));
    }
    throw Exception('Server error: ${response.statusCode}');
  }
}
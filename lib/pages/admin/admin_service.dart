import 'dart:convert';

import 'package:ctt/utils/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {

  static const String baseUrl = BaseUrl.baseUrl;

  Future<Map<String, String>> _headers() async {

    final prefs = await SharedPreferences.getInstance();

    String token = prefs.getString("token") ?? "";

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  Future<List<dynamic>> getEvents() async {

    final response = await http.get(
      Uri.parse("$baseUrl/api/admin/events"),
      headers: await _headers()
    );

    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getRequests() async {

    final response = await http.get(
      Uri.parse("$baseUrl/api/admin/requests"),
      headers: await _headers()
    );

    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getBookings() async {

    final response = await http.get(
      Uri.parse("$baseUrl/api/admin/bookings"),
      headers: await _headers()
    );

    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getUsers() async {

    final response = await http.get(
      Uri.parse("$baseUrl/api/admin/users"),
      headers: await _headers()
    );

    return jsonDecode(response.body);
  }

  Future<void> approveRequest(String id) async {

    await http.patch(
      Uri.parse("$baseUrl/api/admin/requests/$id/approve"),
      headers: await _headers()
    );

  }

  Future<void> rejectRequest(String id) async {

    await http.patch(
      Uri.parse("$baseUrl/api/admin/requests/$id/reject"),
      headers: await _headers()
    );

  }

  Future<void> deleteUser(String id) async {

    await http.delete(
      Uri.parse("$baseUrl/api/admin/users/$id"),
      headers: await _headers()
    );

  }

  Future<void> deleteBooking(String id) async {

    await http.delete(
      Uri.parse("$baseUrl/api/admin/bookings/$id"),
      headers: await _headers()
    );

  }

}
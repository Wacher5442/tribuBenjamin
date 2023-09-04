import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Network {
  final String _url = 'https://www.appacademie.com/api';
  //final String _url = 'http://10.0.2.2:8000/api';
  //if you are using android studio emulator, change localhost to 10.0.2.2

  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token')!);
  }

  authData(data, apiUrl) async {
    try {
      var fullUrl = Uri.parse(_url + apiUrl);
      if (kDebugMode) {
        print(fullUrl);
        print(data);
      }
      return await http.post(fullUrl,
          body: jsonEncode(data), headers: _setHeaders());
    } catch (e) {
      if (kDebugMode) {
        print('erreur $e');
      }
    }
  }

  storeData(data, apiUrl) async {
    try {
      var fullUrl = Uri.parse(_url + apiUrl);
      if (kDebugMode) {
        print(fullUrl);
        print(data);
      }
      return await http.post(fullUrl,
          body: jsonEncode(data), headers: _setHeaders());
    } catch (e) {
      if (kDebugMode) {
        print("erreur $e");
      }
    }
  }

  getData(apiUrl) async {
    try {
      var fullUrl = Uri.parse(_url + apiUrl);
      if (kDebugMode) {
        print(fullUrl);
      }
      await _getToken();
      return await http.get(fullUrl, headers: _setHeaders());
    } catch (e) {
      if (kDebugMode) {
        print('erreur $e');
      }
    }
  }

  _setHeaders() => {
        'Content-type': 'application/json;charset=UTF-8',
        'Accept': 'application/json',
        'Charset': 'utf-8',
        'Authorization': 'Bearer $token'
      };
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  final Dio _dio = Dio();

  final _baseUrl = 'http://10.0.2.2:8000/api';
  //final _baseUrl = 'https://api.odigo.ci/public/api';
  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token')!);
  }

  Future<dynamic> postFile(String url, data) async {
    await _getToken();
    Response response = await _dio.post(
      _baseUrl + url,
      data: data,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {
          'Accept': "application/json",
          'Authorization': 'Bearer $token'
        },
      ),
    );

    var responseBody = response.data;
    // print('retour $responseBody');

    return responseBody;
  }
}

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/helper_file.dart';
import 'apiEndpoints.dart';
import 'connection.dart';
import 'package:dio/dio.dart';


class ApiProvider {

  // for generating user base api post calls
  static Future post({String? url,Map<String, dynamic> body = const {}}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dio = Dio();
    FormData formData = FormData.fromMap(body);
    var header = {
      'Content-Type':'application/json',
      'auth-key':'earncashRestApi',
    };
    if(!kIsWeb){
      if (!await Connection.isConnected()) {
        return {'status': 'No Connection', 'body': 'No Internet Connection'};
      }
    }

    var _response = await dio.post(
      '${ApiEndPoints.baseUrl}$url',
      data: formData,
      options: Options(
        followRedirects: false,
        validateStatus: (status) {
          return status! <= 500;
        },
        headers: header,
      ),
    );
    return {'status': _response.statusCode, 'body': _response.data};

  }

  // for generating user base api get calls
  static Future get(String url, {required Map<String, dynamic> queryParam}) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var header = {
      'Content-Type':'application/json',
      'auth-key':'earncashRestApi',
    };

    var dio = Dio();
    var _response;

    if(!kIsWeb){
      if (!await Connection.isConnected()) {
        return {'status': 'No Connection', 'body': 'No Internet Connection'};
      }
    }

    if (queryParam == null) {
      try {
        _response = await dio.get(
          '${ApiEndPoints.baseUrl}$url',
          options: Options(
            headers: header,
          ),
        );
      } on DioError catch (e) {
        return {'status': e.response!.statusCode, 'body': e.response!.data};
      }
    }
    else {
      try {
        _response =
        await dio.get('${ApiEndPoints.baseUrl}$url', queryParameters: queryParam,
          options: Options(
            headers: header,
          ),
        );
      } on DioError catch (e) {
        print(e);
        return {'status': e.response!.statusCode, 'body': e.response!.data};
      }
    }
    return {'status': _response.statusCode, 'body': _response.data};
  }

}

import 'dart:io';
import 'package:dio/dio.dart';

class ApiService {
  static String baseUrl = 'http://server:9008';

   static Future<String> predictDigit(File imageFile) async {
    try {
      MultipartFile multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: 'digit.png',
      );

      FormData formData = FormData.fromMap({'file': multipartFile});

      Response response = await Dio().post(
        '$baseUrl/predict',
        data: formData,
      );

      if (response.statusCode == 200) {
        if (response.data['prediction'] != null) {
          return response.data['prediction'].toString();
        }
      }

      return 'Prediction failed';
    } catch (error) {
      return 'Error: $error';
    }
  }
}

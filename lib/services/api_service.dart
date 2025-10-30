import 'package:dio/dio.dart';

class ApiService {
  Future<Map<String, dynamic>?> loginAndFetchMedia(
    String accessCode,
    String password,
  ) async {
    try {
      final response = await Dio().post(
        'https://itbhbalbccwddxmwvzox.supabase.co/functions/v1/device-preview-auth',
        data: {'accessCode': accessCode, 'password': password},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

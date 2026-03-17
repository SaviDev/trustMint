import 'package:dio/dio.dart';
import '../local/secure_storage.dart';

class ApiClient {
  final Dio dio;
  final SecureStorage storage;

  ApiClient(this.storage) : dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/v1')) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }
}

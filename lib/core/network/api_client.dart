import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'api_interceptors.dart';

class ApiClient {
  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        )..interceptors.add(LoggingInterceptor());

  final Dio _dio;

  Dio get dio => _dio;
}

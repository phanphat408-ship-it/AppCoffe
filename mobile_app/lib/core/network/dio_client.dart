import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_endpoints.dart';
import 'jwt_interceptor.dart';
import 'token_storage.dart';

/// Provider cung cấp Dio instance đã cấu hình sẵn JWT Interceptor
final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Thêm JWT Interceptor
  dio.interceptors.add(
    JwtInterceptor(
      tokenStorage: tokenStorage,
      onUnauthorized: () {
        debugPrint('>> JWT Token expired or unauthorized. Navigating to login.');
      },
    ),
  );

  // Thêm Log Interceptor khi ở môi trường Debug
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
    );
  }

  return dio;
});

import 'dart:io';
import 'package:dio/dio.dart';
import 'token_storage.dart';

/// Interceptor tự động gắn JWT Bearer Token vào Header của các Request
/// và xử lý trường hợp mã lỗi 401 Unauthorized (Token hết hạn)
class JwtInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final void Function()? onUnauthorized;

  JwtInterceptor({
    required this.tokenStorage,
    this.onUnauthorized,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Kiểm tra nếu request cần bỏ qua đính kèm Token (như public login/register)
    final requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      final token = await tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
    }

    // Đảm bảo kiểu dữ liệu luôn là JSON
    options.headers[HttpHeaders.contentTypeHeader] = 'application/json';
    options.headers[HttpHeaders.acceptHeader] = 'application/json';

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // 2. Xử lý khi Token hết hạn hoặc không hợp lệ (401 Unauthorized)
    if (err.response?.statusCode == HttpStatus.unauthorized) {
      // Xóa token đã lưu
      await tokenStorage.clearToken();

      // Thông báo cho hệ thống chuyển hướng về trang Login
      onUnauthorized?.call();
    }

    return handler.next(err);
  }
}

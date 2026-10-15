import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Đăng nhập tài khoản
  Future<AuthResponseModel> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'phone': phone.trim(),
          'password': password,
        },
        options: Options(extra: {'requiresAuth': false}),
      );

      final responseData = response.data as Map<String, dynamic>;
      final success = responseData['success'] as bool? ?? false;

      if (!success) {
        final message = responseData['message'] as String? ?? 'Đăng nhập không thành công.';
        throw Exception(message);
      }

      final data = responseData['data'] as Map<String, dynamic>;
      return AuthResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Đăng ký tài khoản mới
  Future<AuthResponseModel> register({
    required String name,
    required String phone,
    required String password,
    String role = 'Customer',
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'name': name.trim(),
          'phone': phone.trim(),
          'password': password,
          'role': role,
        },
        options: Options(extra: {'requiresAuth': false}),
      );

      final responseData = response.data as Map<String, dynamic>;
      final success = responseData['success'] as bool? ?? false;

      if (!success) {
        final message = responseData['message'] as String? ?? 'Đăng ký không thành công.';
        throw Exception(message);
      }

      final data = responseData['data'] as Map<String, dynamic>;
      return AuthResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Lấy thông tin tài khoản hiện tại từ Token
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiEndpoints.me);
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Xử lý phân giải thông báo lỗi từ DioException
  String _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final dynamic data = e.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          return data['message'].toString();
        }
        if (data['errors'] != null && data['errors'] is List && (data['errors'] as List).isNotEmpty) {
          return (data['errors'] as List).first.toString();
        }
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Kết nối máy chủ quá hạn. Vui lòng kiểm tra lại mạng.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối đến máy chủ. Vui lòng đảm bảo Backend API đang chạy.';
    }

    return e.message ?? 'Đã xảy ra lỗi không xác định.';
  }
}

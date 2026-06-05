import 'package:dio/dio.dart';

import 'package:imaginovation_app/core/constants/api_constants.dart';
import 'package:imaginovation_app/core/error/exceptions.dart';
import 'package:imaginovation_app/core/storage/token_storage.dart';

class DioClient {
  DioClient(this._tokenStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenStorage.deleteToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio dio;
  final TokenStorage _tokenStorage;

  ServerException toServerException(Object error) {
    if (error is DioException) {
      final response = error.response;
      if (response != null) {
        final data = response.data;
        var message = 'Something went wrong.';
        Map<String, dynamic>? errors;
        if (data is Map<String, dynamic>) {
          message = data['message']?.toString() ?? message;
          if (data['errors'] is Map<String, dynamic>) {
            errors = data['errors'] as Map<String, dynamic>;
          }
        }
        return ServerException(
          message,
          statusCode: response.statusCode,
          errors: errors,
        );
      }
      return ServerException(
        error.message ?? 'Network error. Check your connection.',
      );
    }
    return ServerException(error.toString());
  }
}

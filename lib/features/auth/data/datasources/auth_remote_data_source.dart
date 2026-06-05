import 'package:imaginovation_app/core/network/dio_client.dart';
import 'package:imaginovation_app/core/storage/token_storage.dart';
import 'package:imaginovation_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client, this._tokenStorage);

  final DioClient _client;
  final TokenStorage _tokenStorage;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      await _tokenStorage.saveToken(data['token'].toString());
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } catch (e) {
      throw _client.toServerException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.dio.post('/logout');
    } catch (_) {
      // Ignore remote errors; we clear the token regardless.
    } finally {
      await _tokenStorage.deleteToken();
    }
  }
}

import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../domain/auth_repository.dart';
import '../domain/models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepositoryImpl({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.post(
        '/v1/auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        
        // Save token and user data
        await _storageService.saveToken(loginResponse.token);
        await _storageService.saveUserData(loginResponse.user.toJson());
        
        return loginResponse;
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _storageService.clearAll();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userData = await _storageService.getUserData();
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }
}

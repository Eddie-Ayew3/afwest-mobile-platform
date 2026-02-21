import '../../../core/services/api_service.dart';
import '../domain/dashboard_repository.dart';
import '../domain/models.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final ApiService _apiService;

  DashboardRepositoryImpl({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<Schedule?> getTodaySchedule() async {
    try {
      final response = await _apiService.get('/v1/guard/today-schedule');
      
      if (response.statusCode == 200 && response.data != null) {
        return Schedule.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to fetch today\'s schedule: $e');
    }
  }

  @override
  Future<void> checkIn(CheckInRequest request, String imagePath) async {
    try {
      await _apiService.uploadFile(
        '/v1/guard/check-in',
        imagePath,
        request.toFormData(),
      );
    } catch (e) {
      throw Exception('Check-in failed: $e');
    }
  }

  @override
  Future<void> checkOut(CheckOutRequest request, String imagePath) async {
    try {
      await _apiService.uploadFile(
        '/v1/guard/check-out',
        imagePath,
        request.toFormData(),
      );
    } catch (e) {
      throw Exception('Check-out failed: $e');
    }
  }
}

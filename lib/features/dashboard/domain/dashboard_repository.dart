import '../domain/models.dart';

abstract class DashboardRepository {
  Future<Schedule?> getTodaySchedule();
  Future<void> checkIn(CheckInRequest request, String imagePath);
  Future<void> checkOut(CheckOutRequest request, String imagePath);
}

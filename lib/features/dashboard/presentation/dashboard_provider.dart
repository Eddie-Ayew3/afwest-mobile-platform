import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/utils/app_utils.dart';
import '../domain/dashboard_repository.dart';
import '../domain/models.dart';

class DashboardState {
  final bool isLoading;
  final bool isCheckingIn;
  final bool isCheckingOut;
  final Schedule? schedule;
  final String? error;

  DashboardState({
    this.isLoading = false,
    this.isCheckingIn = false,
    this.isCheckingOut = false,
    this.schedule,
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    bool? isCheckingIn,
    bool? isCheckingOut,
    Schedule? schedule,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isCheckingIn: isCheckingIn ?? this.isCheckingIn,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      schedule: schedule ?? this.schedule,
      error: error ?? this.error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardNotifier({
    required DashboardRepository dashboardRepository,
  }) : _dashboardRepository = dashboardRepository,
       super(DashboardState());

  Future<void> loadTodaySchedule() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final schedule = await _dashboardRepository.getTodaySchedule();
      state = state.copyWith(
        isLoading: false,
        schedule: schedule,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> checkIn(int shiftId, String imagePath) async {
    state = state.copyWith(isCheckingIn: true, error: null);
    
    try {
      // Get current location
      final position = await LocationService.getCurrentLocation();
      
      final request = CheckInRequest(
        shiftId: shiftId,
        timestamp: DateTime.now(),
        latitude: position!.latitude,
        longitude: position.longitude,
        imagePath: imagePath,
      );
      
      await _dashboardRepository.checkIn(request, imagePath);
      
      // Refresh schedule to get updated status
      await loadTodaySchedule();
      
      state = state.copyWith(isCheckingIn: false);
    } catch (e) {
      state = state.copyWith(
        isCheckingIn: false,
        error: e.toString(),
      );
    }
  }

  Future<void> checkOut(int shiftId, String imagePath) async {
    state = state.copyWith(isCheckingOut: true, error: null);
    
    try {
      // Get current location
      final position = await LocationService.getCurrentLocation();
      
      final request = CheckOutRequest(
        shiftId: shiftId,
        timestamp: DateTime.now(),
        latitude: position!.latitude,
        longitude: position.longitude,
        imagePath: imagePath,
      );
      
      await _dashboardRepository.checkOut(request, imagePath);
      
      // Refresh schedule to get updated status
      await loadTodaySchedule();
      
      state = state.copyWith(isCheckingOut: false);
    } catch (e) {
      state = state.copyWith(
        isCheckingOut: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  bool canCheckIn() {
    if (state.schedule == null) return false;
    
    return AppUtils.isCheckInAllowed(
      state.schedule!.status,
      state.schedule!.startTime,
    );
  }

  bool canCheckOut() {
    if (state.schedule == null) return false;
    
    return AppUtils.isCheckOutAllowed(state.schedule!.status);
  }
}

// Providers
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  throw UnimplementedError('DashboardRepository must be provided in main.dart');
});

final dashboardNotifierProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(
    dashboardRepository: ref.watch(dashboardRepositoryProvider),
  );
});

final dashboardStateProvider = Provider<DashboardState>((ref) {
  return ref.watch(dashboardNotifierProvider);
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/services/permission_service.dart';
import '../domain/models.dart';
import 'dashboard_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../camera/camera_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load today's schedule when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardNotifierProvider.notifier).loadTodaySchedule();
    });
  }

  Future<void> _handleCheckIn() async {
    final schedule = ref.read(dashboardStateProvider).schedule;
    if (schedule == null) return;

    // Request camera permission
    final hasPermission = await PermissionService.hasCameraPermission();
    if (!hasPermission) {
      final granted = await PermissionService.requestCameraPermission();
      if (!granted) {
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            AppStrings.cameraPermission,
            isError: true,
          );
        }
        return;
      }
    }

    // Open camera
    final imagePath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const CameraScreen(title: 'Check-In Photo'),
      ),
    );

    if (imagePath != null && imagePath.isNotEmpty) {
      // Process check-in
      await ref.read(dashboardNotifierProvider.notifier).checkIn(schedule.id, imagePath);
    }
  }

  Future<void> _handleCheckOut() async {
    final schedule = ref.read(dashboardStateProvider).schedule;
    if (schedule == null) return;

    // Request camera permission
    final hasPermission = await PermissionService.hasCameraPermission();
    if (!hasPermission) {
      final granted = await PermissionService.requestCameraPermission();
      if (!granted) {
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            AppStrings.cameraPermission,
            isError: true,
          );
        }
        return;
      }
    }

    // Open camera
    final imagePath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const CameraScreen(title: 'Check-Out Photo'),
      ),
    );

    if (imagePath != null && imagePath.isNotEmpty) {
      // Process check-out
      await ref.read(dashboardNotifierProvider.notifier).checkOut(schedule.id, imagePath);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await AppUtils.showConfirmationDialog(
      context,
      'Logout',
      'Are you sure you want to logout?',
    );

    if (confirmed) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final dashboardNotifier = ref.read(dashboardNotifierProvider.notifier);

    // Listen to dashboard state changes
    ref.listen<DashboardState>(dashboardNotifierProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        AppUtils.showSnackBar(context, next.error!, isError: true);
        dashboardNotifier.clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.dashboard,
          style: TextStyle(fontSize: 20.sp),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => dashboardNotifier.loadTodaySchedule(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppConstants.padding.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              if (authState.user != null) ...[
                Text(
                  'Welcome, ${authState.user!.name}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Here\'s your schedule for today',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Schedule Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.padding.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.todaySchedule,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      if (dashboardState.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (dashboardState.schedule != null) ...[
                        _buildScheduleInfo(dashboardState.schedule!),
                      ] else ...[
                        _buildEmptySchedule(),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Action Buttons
              if (dashboardState.schedule != null) ...[
                _buildActionButtons(dashboardState),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleInfo(Schedule schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          Icons.location_on,
          AppStrings.siteName,
          schedule.siteName,
        ),
        SizedBox(height: 12.h),
        _buildInfoRow(
          Icons.access_time,
          AppStrings.shiftTime,
          '${AppUtils.formatTime(schedule.startTime)} - ${AppUtils.formatTime(schedule.endTime)}',
        ),
        SizedBox(height: 12.h),
        _buildInfoRow(
          Icons.info,
          AppStrings.status,
          AppUtils.getStatusText(schedule.status),
          statusColor: AppUtils.getStatusColor(schedule.status),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? statusColor}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: AppConstants.primaryColor,
        ),
        SizedBox(width: 12.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: statusColor ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySchedule() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 48.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No schedule for today',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DashboardState state) {
    final canCheckIn = ref.read(dashboardNotifierProvider.notifier).canCheckIn();
    final canCheckOut = ref.read(dashboardNotifierProvider.notifier).canCheckOut();

    return Column(
      children: [
        // Check-In Button
        if (canCheckIn)
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: state.isCheckingIn ? null : _handleCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: state.isCheckingIn
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(AppStrings.checkIn),
            ),
          ),

        if (canCheckIn) SizedBox(height: 16.h),

        // Check-Out Button
        if (canCheckOut)
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: state.isCheckingOut ? null : _handleCheckOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: state.isCheckingOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(AppStrings.checkOut),
            ),
          ),

        if (!canCheckIn && !canCheckOut)
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              'No actions available at this time',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/constants/app_constants.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/utils/app_utils.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/data/dashboard_repository_impl.dart';
import 'features/dashboard/presentation/dashboard_provider.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final apiService = ApiService();
  final storageService = StorageService();
  
  apiService.initialize();
  
  runApp(
    ProviderScope(
      overrides: [
        // Override API service
        Provider<ApiService>((ref) => apiService),
        
        // Override storage service
        Provider<StorageService>((ref) => storageService),
        
        // Override auth repository
        authRepositoryProvider.overrideWithValue(
          AuthRepositoryImpl(
            apiService: apiService,
            storageService: storageService,
          ),
        ),
        
        // Override dashboard repository
        dashboardRepositoryProvider.overrideWithValue(
          DashboardRepositoryImpl(apiService: apiService),
        ),
      ],
      child: const GuardApp(),
    ),
  );
}

class GuardApp extends ConsumerStatefulWidget {
  const GuardApp({super.key});

  @override
  ConsumerState<GuardApp> createState() => _GuardAppState();
}

class _GuardAppState extends ConsumerState<GuardApp> {
  @override
  void initState() {
    super.initState();
    // Check authentication status on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: _getInitialScreen(authState),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const DashboardScreen(),
          },
        );
      },
    );
  }

  Widget _getInitialScreen(AuthState authState) {
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authState.isAuthenticated) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/storage_service.dart';
import 'login_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    debugPrint('🚀 [SplashScreen] Checking authentication status...');
    
    // Wait for splash screen to show (2 seconds)
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    try {
      // Check if user is logged in
      final isLoggedIn = await _storageService.isLoggedIn();
      debugPrint('🚀 [SplashScreen] Is logged in: $isLoggedIn');
      
      if (mounted) {
        if (isLoggedIn) {
          debugPrint('✅ [SplashScreen] User is logged in, navigating to HomeScreen...');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          debugPrint('⚠️ [SplashScreen] User is not logged in, navigating to LoginScreen...');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [SplashScreen] Error checking auth status: $e');
      // On error, navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Text(
          'SOAR',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300, // Light/thin font weight
            color: AppColors.black,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}

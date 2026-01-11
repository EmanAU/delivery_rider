import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../data/models/login_request_model.dart';
import '../../data/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _storageService = StorageService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _toastMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    debugPrint('🚀 [LoginScreen] Login button pressed');

    if (_formKey.currentState!.validate()) {
      debugPrint('✅ [LoginScreen] Form validation passed');
      debugPrint('🚀 [LoginScreen] Setting loading state to true');
      setState(() => _isLoading = true);

      try {
        final username = _usernameController.text.trim();
        final password = _passwordController.text;

        debugPrint('🚀 [LoginScreen] Creating login request...');
        debugPrint('🚀 [LoginScreen] Username: $username');
        debugPrint('🚀 [LoginScreen] Password length: ${password.length}');

        final request = LoginRequestModel(
          username: username,
          passwordHash: password,
        );

        debugPrint('🚀 [LoginScreen] Calling AuthService.riderLogin...');
        final response = await _authService.riderLogin(request);

        if (!mounted) {
          debugPrint('⚠️ [LoginScreen] Widget not mounted, returning');
          return;
        }

        if (response != null) {
          debugPrint('✅ [LoginScreen] Login API call successful');

          // Validate response data
          if (response.accessToken.isEmpty) {
            debugPrint('❌ [LoginScreen] Access token is empty');
            throw Exception('Invalid response: Access token is missing');
          }

          debugPrint('✅ [LoginScreen] Access token validated');
          debugPrint('🚀 [LoginScreen] Saving login data to storage...');
          debugPrint('🚀 [LoginScreen] UserName: ${response.userName}');
          debugPrint('🚀 [LoginScreen] RiderId: ${response.riderId}');
          debugPrint('🚀 [LoginScreen] ExpiresIn: ${response.expiresIn}');

          // Save login data
          try {
            await _storageService.saveLoginData(
              accessToken: response.accessToken,
              userName: response.userName,
              riderId: response.riderId,
              expiresIn: response.expiresIn,
            );
            debugPrint('✅ [LoginScreen] Login data saved successfully');
          } catch (e) {
            debugPrint('❌ [LoginScreen] Failed to save login data: $e');
            throw Exception('Failed to save login data. Please try again.');
          }

          debugPrint('🚀 [LoginScreen] Navigating to HomeScreen...');
          // Navigate to home screen
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
            debugPrint('✅ [LoginScreen] Navigation to HomeScreen completed');
          }
        } else {
          debugPrint('❌ [LoginScreen] Invalid credentials (response is null)');
          // Invalid credentials
          if (mounted) {
            setState(() {
              _isLoading = false;
              _toastMessage = 'Invalid username or password';
            });
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _toastMessage = null;
                });
              }
            });
          }
        }
      } catch (e) {
        debugPrint('❌ [LoginScreen] Error occurred: $e');
        if (!mounted) {
          debugPrint('⚠️ [LoginScreen] Widget not mounted, returning');
          return;
        }

        setState(() => _isLoading = false);
        debugPrint('🚀 [LoginScreen] Setting loading state to false');

        // Extract user-friendly error message
        String errorMessage = 'Login failed';
        final errorString = e.toString().toLowerCase();
        debugPrint('🚀 [LoginScreen] Processing error message: $errorString');

        // Check for network errors first
        if (errorString.contains('no internet connection') ||
            errorString.contains('network error') ||
            errorString.contains('internet connection') ||
            errorString.contains('socketfailed') ||
            errorString.contains('host lookup') ||
            errorString.contains('no address associated')) {
          errorMessage = 'No internet connection';
        } else if (errorString.contains('timeout')) {
          errorMessage = 'Connection timeout. Please check your internet connection.';
        } else if (errorString.contains('server error')) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          // Remove "Exception: " prefix if present
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }

        debugPrint('🚀 [LoginScreen] Showing error toast: $errorMessage');
        if (mounted) {
          setState(() {
            _toastMessage = errorMessage;
          });
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) {
              setState(() {
                _toastMessage = null;
              });
            }
          });
        }
      }
    } else {
      debugPrint('❌ [LoginScreen] Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Toast message at top
            if (_toastMessage != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.red,
                child: Row(
                  children: [
                    const Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _toastMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Main content
            Expanded(
              child: Row(
                children: [
                  // Left side - Branding section (visible on larger screens)
                  if (size.width > 800)
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.black,
                              AppColors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Welcome back to your journey',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Right side - Login form
                  Expanded(
                    flex: size.width > 800 ? 5 : 1,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width > 600 ? 64.0 : 32.0,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Welcome text
                                Text(
                                  'Welcome back',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Please enter your credentials to continue',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        AppColors.black.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 48),

                                // Username field
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    labelStyle: TextStyle(
                                      color: AppColors.black
                                          .withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: AppColors.black
                                          .withValues(alpha: 0.5),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.black.withValues(
                                      alpha: 0.02,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.black
                                            .withValues(alpha: 0.1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.black,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color:
                                            Colors.red.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your username';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                      color: AppColors.black
                                          .withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: AppColors.black
                                          .withValues(alpha: 0.5),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.black.withValues(
                                      alpha: 0.02,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.black
                                            .withValues(alpha: 0.1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.black,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color:
                                            Colors.red.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AppColors.black
                                            .withValues(alpha: 0.5),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Login button
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.black,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: AppColors.black
                                          .withValues(alpha: 0.6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                      shadowColor: AppColors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            'LOGIN',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

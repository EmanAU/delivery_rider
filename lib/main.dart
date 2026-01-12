import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/colors.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/orders/presentation/providers/deliver_customer_orders_provider.dart';
import 'features/orders/presentation/providers/returns_merchant_orders_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style globally for navigation bar visibility
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: AppColors.black.withValues(alpha: 0.15),
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeliverCustomerOrdersProvider()),
        ChangeNotifierProvider(create: (_) => ReturnsMerchantOrdersProvider()),
      ],
      child: MaterialApp(
        title: 'SOAR LOGISTICS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.black),
          scaffoldBackgroundColor: AppColors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.white,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

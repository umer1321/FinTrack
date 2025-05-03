import 'package:flutter/material.dart';
import 'package:fintrack/core/models/budget_model.dart';
import 'package:fintrack/core/models/transaction_model.dart';

import 'package:fintrack/home_screen.dart';

import ' features/Budget/screens/budget_form_screen.dart';
import ' features/NotificationSettingsScreen.dart';
import ' features/ProfileSettingsScreen.dart';
import ' features/auth/presentation/screens/login_screen.dart';
import ' features/auth/presentation/screens/register_screen.dart';
import ' features/auth/presentation/screens/reset_password_screen.dart';
import ' features/splash_screen.dart';
import ' features/transactions/presentation/screens/transaction_form_screen.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => ResetPasswordScreen());
      case '/reset-password':
        return MaterialPageRoute(builder: (_) => ResetPasswordScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/transaction-form':
        final args = settings.arguments as Transaction?;
        return MaterialPageRoute(
            builder: (_) => TransactionFormScreen(transaction: args));
      case '/budget-form':
        final args = settings.arguments as Budget?;
        return MaterialPageRoute(builder: (_) => BudgetFormScreen(budget: args));
      case '/profile-settings':
        return MaterialPageRoute(builder: (_) => const ProfileSettingsScreen());
      case '/notification-settings':
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());

    /*
      case '/mfa-verification':
        final args = settings.arguments as String?;
        if (args == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('MFA Verification ID missing')),
            ),
          );
        }
        return MaterialPageRoute(
            builder: (_) => MFAVerificationScreen(verificationId: args));
      */
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
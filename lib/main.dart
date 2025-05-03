import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintrack/routes.dart';
import 'package:fintrack/core/services/firestore_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintrack/home_screen.dart';


import ' features/Budget/bloc/budget_bloc.dart';
import ' features/auth/presentation/bloc/auth_bloc.dart';
import ' features/splash_screen.dart';
import ' features/transactions/presentation/bloc/transaction_bloc.dart';
import ' features/transactions/presentation/data/transaction_repository.dart';
import 'core/services/BillReminderService.dart';
import 'core/services/NotificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();
    final billReminderService = BillReminderService(notificationService: notificationService);
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      billReminderService.startBillReminders(userId);
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => FirestoreService()),
        RepositoryProvider(create: (_) => notificationService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc()),
          BlocProvider(
            create: (context) => TransactionBloc(
              transactionRepository: TransactionRepository(
                RepositoryProvider.of<FirestoreService>(context),
                FirebaseAuth.instance,
              ),
              notificationService: RepositoryProvider.of<NotificationService>(context),
            ),
          ),
          BlocProvider(
            create: (context) => BudgetBloc(
              firestoreService: RepositoryProvider.of<FirestoreService>(context),
              auth: FirebaseAuth.instance,
              notificationService: RepositoryProvider.of<NotificationService>(context),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'FinTrack',
          theme: ThemeData(
            primaryColor: const Color(0xFF1A3C34),
            textTheme: GoogleFonts.poppinsTextTheme(),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          initialRoute: '/splash',
          onGenerateRoute: RouteGenerator.generateRoute,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
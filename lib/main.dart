import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintrack/routes.dart';

import 'package:fintrack/core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import ' features/Budget/bloc/budget_bloc.dart';
import ' features/auth/presentation/bloc/auth_bloc.dart';
import ' features/auth/presentation/bloc/auth_state.dart';
import ' features/auth/presentation/screens/login_screen.dart';
import ' features/transactions/presentation/bloc/transaction_bloc.dart';
import ' features/transactions/presentation/data/transaction_repository.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => FirestoreService()),
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
            ),
          ),
          BlocProvider(
            create: (context) => BudgetBloc(
              firestoreService: RepositoryProvider.of<FirestoreService>(context),
              auth: FirebaseAuth.instance,
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
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return const HomeScreen();
              } else if (state is AuthInitial) {
                return LoginScreen();
              } else if (state is AuthError) {
                return Scaffold(
                  body: Center(child: Text(state.message)),
                );
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
          onGenerateRoute: RouteGenerator.generateRoute,
        ),
      ),
    );
  }
}
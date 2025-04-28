import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/constants/theme.dart';
import 'package:fintrack/ features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fintrack/ features/auth/presentation/screens/login_screen.dart';
import 'package:fintrack/routes.dart';
import ' features/auth/presentation/bloc/auth_bloc.dart';
import ' features/transactions/presentation/bloc/transaction_bloc.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'FinTrack',
        theme: appTheme,
        initialRoute: '/login',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
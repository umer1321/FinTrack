import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class MFAVerificationScreen extends StatefulWidget {
  final String? verificationId;

  const MFAVerificationScreen({super.key, this.verificationId});

  @override
  State<MFAVerificationScreen> createState() => _MFAVerificationScreenState();
}

class _MFAVerificationScreenState extends State<MFAVerificationScreen> {
  late String verificationId;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Retrieve verificationId from widget or route arguments
    verificationId = widget.verificationId ?? (ModalRoute.of(context)?.settings.arguments as String? ?? '');
    if (verificationId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification ID missing')),
        );
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verifyCode(BuildContext context) {
    if (verificationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification ID missing')),
      );
      return;
    }
    context.read<AuthBloc>().add(
      MFAVerifyEvent(
        verificationId,
        _codeController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is MFAVerificationFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is AuthAuthenticated) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Verify Your Email',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit code sent to your email',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    controller: _codeController,
                    label: 'Verification Code',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return state is AuthLoading
                          ? const Center(child: CircularProgressIndicator())
                          : AuthButton(
                        text: 'Verify',
                        onPressed: () => _verifyCode(context),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<ResetPasswordEvent>(_onResetPassword);
    on<SignOutEvent>(_onSignOut);
    on<MFAEnrollEvent>(_onMFAEnroll);
    on<MFAVerifyEvent>(_onMFAVerify);

    _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        if (state is! MFAEnrollmentRequired && state is! MFAVerificationFailed) {
          emit(AuthAuthenticated(user.uid));
        }
      } else {
        emit(AuthInitial());
      }
    });
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(user.uid));
      } else {
        emit(const AuthError('Registration failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(event.email, event.password);
      if (user != null) {
        // Skip MFA check and directly authenticate
        emit(AuthAuthenticated(user.uid));
      } else {
        emit(const AuthError('Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPassword(ResetPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPassword(event.email);
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(AuthInitial());
  }

  Future<void> _onMFAEnroll(MFAEnrollEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(const AuthError('No user logged in'));
        return;
      }

      final code = Random().nextInt(999999).toString().padLeft(6, '0');
      final verificationId = user.uid;

      await _firestore.collection('mfa_codes').doc(verificationId).set({
        'code': code,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 5))),
      });

      // Launch email client with pre-filled message (optional, can be removed if MFA is disabled)
      final emailUri = Uri(
        scheme: 'mailto',
        path: user.email,
        queryParameters: {
          'subject': 'Your FinTrack Verification Code',
          'body': 'Your verification code is: $code. It is valid for 5 minutes. Please copy this code and enter it in the FinTrack app. Do not share this code with anyone.',
        },
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        print('Could not launch email client. Please copy the code manually: $code');
      }

      emit(MFAEnrollmentRequired(verificationId));
      print('Emitted MFAEnrollmentRequired with verificationId: $verificationId');
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onMFAVerify(MFAVerifyEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(const AuthError('No user logged in'));
        return;
      }

      final doc = await _firestore.collection('mfa_codes').doc(event.verificationId).get();
      if (!doc.exists) {
        emit(MFAVerificationFailed(event.verificationId, 'Verification code not found or expired'));
        return;
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) {
        emit(MFAVerificationFailed(event.verificationId, 'Verification code expired'));
        return;
      }

      if (storedCode != event.code) {
        emit(MFAVerificationFailed(event.verificationId, 'Invalid verification code'));
        return;
      }

      await _firestore.collection('mfa').doc(user.uid).set({
        'emailVerified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('mfa_codes').doc(event.verificationId).delete();

      emit(AuthAuthenticated(user.uid));
    } catch (e) {
      emit(MFAVerificationFailed(event.verificationId, e.toString()));
    }
  }
}
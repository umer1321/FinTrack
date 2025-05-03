import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  const AuthAuthenticated(this.userId);
  @override
  List<Object> get props => [userId];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}

class MFAEnrollmentRequired extends AuthState {
  final String verificationId;
  const MFAEnrollmentRequired(this.verificationId);
  @override
  List<Object> get props => [verificationId];
}

class MFAVerificationFailed extends AuthState {
  final String verificationId;
  final String message;
  const MFAVerificationFailed(this.verificationId, this.message);
  @override
  List<Object> get props => [verificationId, message];
}
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  const RegisterEvent(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  const ResetPasswordEvent(this.email);
  @override
  List<Object> get props => [email];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

class MFAEnrollEvent extends AuthEvent {
  const MFAEnrollEvent(); // Removed phoneNumber since we'll use email
}

class MFAVerifyEvent extends AuthEvent {
  final String verificationId;
  final String code;

  const MFAVerifyEvent(this.verificationId, this.code);

  @override
  List<Object> get props => [verificationId, code];
}
part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class CodeSentState extends LoginState {}

class AccountNotFound extends LoginState {
  final String userType;

  AccountNotFound(this.userType);
}

class PhoneVerified extends LoginState {
  final User user;

  PhoneVerified(this.user);
}

class AuthenticatedState extends LoginState {
  final User user;

  AuthenticatedState(this.user);
}

class CreateUserError extends LoginState {}

class VerifyingError extends LoginState {}

part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginReset extends LoginEvent {}

class SendCode extends LoginEvent {
  final String phoneNumber;

  SendCode(this.phoneNumber);
}

class ResendCode extends LoginEvent {
  final String phoneNumber;

  ResendCode(this.phoneNumber);
}

class VerifyPhoneNumber extends LoginEvent {
  final String smsCode;
  final String userType;

  VerifyPhoneNumber(this.smsCode, this.userType);
}

class CreateUser extends LoginEvent {
  final User user;

  CreateUser(this.user);
}

part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStart extends AuthEvent {}

class AuthenticateUser extends AuthEvent {
  final User user;

  AuthenticateUser(this.user);
}

class AuthenticateRider extends AuthEvent {
  final Rider rider;

  AuthenticateRider(this.rider);
}

class SignOutUser extends AuthEvent {}

part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class UninitializedState extends AuthState {}

class AuthenticatedUserState extends AuthState {
  final User user;

  AuthenticatedUserState(this.user);
}

class AuthenticatedRiderState extends AuthState {
  final Rider rider;

  AuthenticatedRiderState(this.rider);
}

class UnAuthenticatedState extends AuthState {}

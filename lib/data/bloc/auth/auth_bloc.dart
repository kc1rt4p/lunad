import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad/data/models/rider.dart';
import 'package:lunad/data/models/user.dart';
import 'package:lunad/repositories/firebase_auth_repository.dart';
import 'package:lunad/repositories/rider_repository.dart';
import 'package:lunad/repositories/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthRepo _authRepo;
  final _riderRepo = RiderRepository();
  final _userRepo = UserRepository();

  AuthBloc(this._authRepo) : super(UninitializedState());

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AppStart) {
      yield* mapAppStartToState();
    }

    if (event is AuthenticateUser) {
      if (event.user.type == 'consumer')
        yield AuthenticatedUserState(event.user);
      else {
        final rider = await _userRepo.getRider(event.user.id);
        yield AuthenticatedRiderState(rider);
      }
    }

    if (event is AuthenticateRider) {
      yield AuthenticatedRiderState(event.rider);
    }

    if (event is SignOutUser) {
      _authRepo.signOut();
      yield UnAuthenticatedState();
    }
  }

  Stream<AuthState> mapAppStartToState() async* {
    try {
      final isAuthenticated = _authRepo.isAuthenticated();
      if (isAuthenticated) {
        print('user authenticated');
        final user = _authRepo.getUser();
        final _user = await _userRepo.getUser(user.id);
        print('user is: ${_user.type}');
        if (_user != null) {
          if (_user.type == 'consumer') {
            print('authenticating user');
            yield AuthenticatedUserState(_user);
          } else {
            final _rider = await _riderRepo.getRider(_user.id);
            yield AuthenticatedRiderState(_rider);
          }
        } else {
          yield UnAuthenticatedState();
        }
      } else {
        yield UnAuthenticatedState();
      }
    } catch (_) {
      yield UnAuthenticatedState();
    }
  }
}

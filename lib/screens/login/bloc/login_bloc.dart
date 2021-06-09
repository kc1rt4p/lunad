import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad/data/models/user.dart';
import 'package:lunad/repositories/firebase_auth_repository.dart';
import 'package:lunad/repositories/user_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuthRepo _authRepo;
  final _userRepo = UserRepository();
  LoginBloc(this._authRepo) : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    yield LoginInitial();

    if (event is LoginReset) {
      yield LoginInitial();
    }

    if (event is SendCode) {
      yield* mapSendCodeState(event);
    }

    if (event is ResendCode) {
      yield* mapResendCodeState(event);
    }

    if (event is VerifyPhoneNumber) {
      yield* mapVerifyPhoneNumberState(event);
    }

    if (event is CreateUser) {
      yield* mapCreateUserState(event);
    }
  }

  Stream<LoginState> mapSendCodeState(LoginEvent event) async* {
    yield LoginLoading();
    await _authRepo.verifyPhoneNumber((event as SendCode).phoneNumber);
    yield CodeSentState();
    //await _userRepo.authenticate((event as SendCode).phoneNumber
  }

  Stream<LoginState> mapVerifyPhoneNumberState(LoginEvent event) async* {
    yield LoginLoading();
    final userType = (event as VerifyPhoneNumber).userType;
    User _user =
        await _authRepo.signInWithSmsCode((event as VerifyPhoneNumber).smsCode);

    if (_user != null) {
      final userExists = await _userRepo.userExists(_user.id);

      if (userExists) {
        final user = await _userRepo.getUser(_user.id);

        if (user.type == userType) {
          yield AuthenticatedState(user);
        } else {
          yield AccountNotFound(userType);
        }
      } else {
        if (userType == 'rider') {
          yield AccountNotFound(userType);
        } else {
          yield PhoneVerified(_user);
        }
      }
    } else {
      yield VerifyingError();
    }
  }

  Stream<LoginState> mapCreateUserState(LoginEvent event) async* {
    yield LoginLoading();
    User _user = await _userRepo.createUser((event as CreateUser).user);

    if (_user != null) {
      yield AuthenticatedState(_user);
    } else {
      yield CreateUserError();
    }
  }

  Stream<LoginState> mapResendCodeState(LoginEvent event) async* {
    yield LoginLoading();
    await _authRepo.verifyPhoneNumber((event as ResendCode).phoneNumber);
    yield CodeSentState();
  }
}

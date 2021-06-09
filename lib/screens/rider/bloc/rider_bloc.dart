import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad/data/models/user.dart';
import 'package:lunad/repositories/rider_repository.dart';

part 'rider_event.dart';
part 'rider_state.dart';

class RiderBloc extends Bloc<RiderEvent, RiderState> {
  final riderRepository = RiderRepository();
  RiderBloc() : super(RiderInitial());

  @override
  Stream<RiderState> mapEventToState(
    RiderEvent event,
  ) async* {
    if (event is UpdateRiderProfile) {
      yield UpdatingRiderProfile();
      await riderRepository.updateRiderProfile(event.rider);
      yield UpdatedRiderProfile();
    }
  }
}

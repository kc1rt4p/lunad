import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad/data/models/completed_request.dart';
import 'package:lunad/repositories/rider_repository.dart';

part 'rider_history_event.dart';
part 'rider_history_state.dart';

class RiderHistoryBloc extends Bloc<RiderHistoryEvent, RiderHistoryState> {
  final _riderRepository = RiderRepository();
  RiderHistoryBloc() : super(RiderHistoryInitial());

  @override
  Stream<RiderHistoryState> mapEventToState(
    RiderHistoryEvent event,
  ) async* {
    if (event is LoadRiderHistory) {
      yield LoadingHistory();
      final requests =
          await _riderRepository.getCompletedRequests(event.riderId);
      if (requests == null) {
        yield ErrorLoadingHistory();
      } else {
        yield LoadedRiderHistory(requests);
      }
    }
  }
}

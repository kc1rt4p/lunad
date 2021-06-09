import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad/data/models/completed_request.dart';
import 'package:lunad/data/models/rider_earning.dart';
import 'package:lunad/repositories/rider_repository.dart';

part 'rider_earnings_event.dart';
part 'rider_earnings_state.dart';

class RiderEarningsBloc extends Bloc<RiderEarningsEvent, RiderEarningsState> {
  final riderRepository = RiderRepository();

  StreamSubscription streamRiderEarnings;

  RiderEarningsBloc() : super(RiderEarningsInitial());

  @override
  Stream<RiderEarningsState> mapEventToState(
    RiderEarningsEvent event,
  ) async* {
    if (event is StreamRiderEarnings) {
      streamRiderEarnings?.cancel();
      streamRiderEarnings = riderRepository
          .streamCompletedRequests(event.riderId, event.dateTime)
          .listen((requests) {
        add(LoadCompletedRequests(requests));
      });
    }

    if (event is LoadCompletedRequests) {
      final requests = event.requests;

      double totalTime = 0;
      double distanceTravelled = 0;
      double totalEarnings = 0;
      int completedJobs = 0;
      int completedErrand = 0;
      int completedDelivery = 0;
      double dispatcherAmount = 0;

      for (var request in requests) {
        totalTime += request.totalDuration ?? 0;
        distanceTravelled += request.totalDistance;
        totalEarnings += request.amountCollected * .93;
        dispatcherAmount += request.amountCollected * .07;
        completedJobs += 1;
        if (request.type == 'errand')
          completedErrand += 1;
        else
          completedDelivery += 1;
      }

      final earnings = RiderEarning(
        totalEarnings: totalEarnings,
        distanceTravelled: distanceTravelled,
        completedDelivery: completedDelivery,
        completedErrand: completedErrand,
        completedJobs: completedJobs,
        totalTime: totalTime,
        dispatcherAmount: dispatcherAmount,
      );

      yield LoadedEarnings(earnings, requests);
    }
  }

  @override
  Future<void> close() {
    streamRiderEarnings?.cancel();
    return super.close();
  }
}

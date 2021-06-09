part of 'rider_earnings_bloc.dart';

abstract class RiderEarningsEvent extends Equatable {
  const RiderEarningsEvent();

  @override
  List<Object> get props => [];
}

class StreamRiderEarnings extends RiderEarningsEvent {
  final String riderId;
  final DateTime dateTime;

  StreamRiderEarnings(this.riderId, this.dateTime);

  @override
  List<Object> get props => [riderId, dateTime];
}

class LoadCompletedRequests extends RiderEarningsEvent {
  final List<CompletedRequest> requests;

  LoadCompletedRequests(this.requests);

  @override
  List<Object> get props => [requests];
}

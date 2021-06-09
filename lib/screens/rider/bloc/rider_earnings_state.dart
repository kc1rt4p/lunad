part of 'rider_earnings_bloc.dart';

abstract class RiderEarningsState extends Equatable {
  const RiderEarningsState();

  @override
  List<Object> get props => [];
}

class RiderEarningsInitial extends RiderEarningsState {}

class LoadedCompletedRequests extends RiderEarningsState {
  final List<CompletedRequest> requests;

  LoadedCompletedRequests(this.requests);

  @override
  List<Object> get props => [requests];
}

class LoadedEarnings extends RiderEarningsState {
  final RiderEarning earning;
  final List<CompletedRequest> requests;

  LoadedEarnings(this.earning, this.requests);

  @override
  List<Object> get props => [earning, requests];
}

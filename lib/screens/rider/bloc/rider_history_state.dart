part of 'rider_history_bloc.dart';

abstract class RiderHistoryState extends Equatable {
  const RiderHistoryState();

  @override
  List<Object> get props => [];
}

class RiderHistoryInitial extends RiderHistoryState {}

class LoadingHistory extends RiderHistoryState {}

class LoadedRiderHistory extends RiderHistoryState {
  final List<CompletedRequest> requests;

  LoadedRiderHistory(this.requests);
}

class ErrorLoadingHistory extends RiderHistoryState {}

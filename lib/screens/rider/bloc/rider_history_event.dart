part of 'rider_history_bloc.dart';

abstract class RiderHistoryEvent extends Equatable {
  const RiderHistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadRiderHistory extends RiderHistoryEvent {
  final String riderId;

  LoadRiderHistory(this.riderId);
}

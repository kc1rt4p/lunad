part of 'rider_bloc.dart';

abstract class RiderEvent extends Equatable {
  const RiderEvent();

  @override
  List<Object> get props => [];
}

class UpdateRiderProfile extends RiderEvent {
  final User rider;

  UpdateRiderProfile(this.rider);
}

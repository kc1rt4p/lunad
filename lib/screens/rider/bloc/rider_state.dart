part of 'rider_bloc.dart';

abstract class RiderState extends Equatable {
  const RiderState();

  @override
  List<Object> get props => [];
}

class RiderInitial extends RiderState {}

class UpdatingRiderProfile extends RiderState {}

class UpdatedRiderProfile extends RiderState {}

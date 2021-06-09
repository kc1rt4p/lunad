part of 'courier_screen_bloc.dart';

abstract class CourierScreenState extends Equatable {
  const CourierScreenState();

  @override
  List<Object> get props => [];
}

class CourierScreenInitial extends CourierScreenState {}

class CreatedConsumerRequest extends CourierScreenState {}

class ErrorCreatingRequest extends CourierScreenState {}

class CourierScreenLoading extends CourierScreenState {}

class CourierScreenError extends CourierScreenState {
  final String message;

  CourierScreenError(this.message);
}

class LoadingRequests extends CourierScreenState {}

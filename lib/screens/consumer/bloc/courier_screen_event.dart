part of 'courier_screen_bloc.dart';

abstract class CourierScreenEvent extends Equatable {
  const CourierScreenEvent();

  @override
  List<Object> get props => [];
}

class CreateDeliveryRequest extends CourierScreenEvent {
  final ConsumerRequest consumerRequest;
  final DeliveryInformation deliveryInformation;

  CreateDeliveryRequest({
    this.consumerRequest,
    this.deliveryInformation,
  });
}

class ShowError extends CourierScreenEvent {
  final String message;

  ShowError(this.message);
}

part of 'rider_request_bloc.dart';

abstract class RiderRequestState extends Equatable {
  const RiderRequestState();

  @override
  List<Object> get props => [];
}

class AcceptingRequest extends RiderRequestState {}

class WaitingForRequest extends RiderRequestState {}

class RiderRequestInitial extends RiderRequestState {}

class UpdatingRequest extends RiderRequestState {}

class RequestUpdated extends RiderRequestState {}

class AcceptedErrandRequest extends RiderRequestState {
  final ConsumerRequest request;
  final ErrandInformation errandInformation;
  final List<ErrandItem> itemsToPurchase;

  AcceptedErrandRequest(
      this.request, this.errandInformation, this.itemsToPurchase);

  @override
  List<Object> get props => [request, errandInformation];
}

class AcceptedDeliveryRequest extends RiderRequestState {
  final ConsumerRequest request;
  final DeliveryInformation deliveryInformation;

  AcceptedDeliveryRequest(this.request, this.deliveryInformation);

  @override
  List<Object> get props => [request, deliveryInformation];
}

class UpdatedRiderAvailability extends RiderRequestState {}

class RejectedAssignedRequest extends RiderRequestState {}

class CompletedAssignedRequest extends RiderRequestState {}

class CompletingRequest extends RiderRequestState {}

class CompletedDeliveryRequest extends RiderRequestState {
  final ConsumerRequest request;
  final DeliveryInformation deliveryInfo;

  CompletedDeliveryRequest(this.request, this.deliveryInfo);
}

class CompletedErrandRequest extends RiderRequestState {
  final ConsumerRequest request;
  final ErrandInformation errandInfo;

  CompletedErrandRequest(this.request, this.errandInfo);
}

class PickedUpAssignedRequest extends RiderRequestState {}

class LoadedAssignedRequest extends RiderRequestState {
  final ConsumerRequest request;

  LoadedAssignedRequest(this.request);

  @override
  List<Object> get props => [request];
}

class LoadedExistingDeliveryRequest extends RiderRequestState {
  final ConsumerRequest request;
  final DeliveryInformation deliveryInformation;

  LoadedExistingDeliveryRequest(this.request, this.deliveryInformation);

  @override
  List<Object> get props => [request, deliveryInformation];
}

class LoadedExistingErrandRequest extends RiderRequestState {
  final ConsumerRequest request;
  final ErrandInformation errandInforation;
  final List<ErrandItem> itemsToPurchase;

  LoadedExistingErrandRequest(
      this.request, this.errandInforation, this.itemsToPurchase);

  @override
  List<Object> get props => [request, errandInforation];
}

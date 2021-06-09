part of 'rider_request_bloc.dart';

abstract class RiderRequestEvent extends Equatable {
  const RiderRequestEvent();

  @override
  List<Object> get props => [];
}

class UpdateRiderLocation extends RiderRequestEvent {
  final String riderId;
  final String requestId;
  final List<double> latLng;

  UpdateRiderLocation(this.requestId, this.riderId, this.latLng);
}

class UpdateRiderAvailability extends RiderRequestEvent {
  final String riderId;
  final bool availability;

  UpdateRiderAvailability(this.riderId, this.availability);
}

class AcceptAssignedRequest extends RiderRequestEvent {
  final String requestId;
  final String riderId;

  AcceptAssignedRequest(this.requestId, this.riderId);
}

class RejectAssignedRequest extends RiderRequestEvent {
  final String requestId;

  RejectAssignedRequest(this.requestId);
}

class LoadExistingRequest extends RiderRequestEvent {
  final ConsumerRequest request;

  LoadExistingRequest(this.request);
}

class CompleteAssignedRequest extends RiderRequestEvent {
  final String requestId;
  final String riderId;

  CompleteAssignedRequest(this.requestId, this.riderId);
}

class LoadRequest extends RiderRequestEvent {
  final ConsumerRequest request;

  LoadRequest(this.request);
}

class UpdateRequest extends RiderRequestEvent {
  final String requestId;
  final String status;

  UpdateRequest(this.requestId, this.status);
}

class PickUpAssignedRequest extends RiderRequestEvent {
  final String requestId;
  final String riderId;

  PickUpAssignedRequest(this.requestId, this.riderId);
}

class WaitForRequest extends RiderRequestEvent {
  final String riderId;

  WaitForRequest(this.riderId);
}

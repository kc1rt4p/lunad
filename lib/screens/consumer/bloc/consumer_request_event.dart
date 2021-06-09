part of 'consumer_request_bloc.dart';

abstract class ConsumerRequestEvent extends Equatable {
  const ConsumerRequestEvent();

  @override
  List<Object> get props => [];
}

class CreateDeliveryRequest extends ConsumerRequestEvent {
  final ConsumerRequest consumerRequest;
  final DeliveryInformation deliveryInformation;

  CreateDeliveryRequest({
    this.consumerRequest,
    this.deliveryInformation,
  });
}

class CreateErrandRequest extends ConsumerRequestEvent {
  final ConsumerRequest consumerRequest;
  final ErrandInformation errandInformation;
  final List<ErrandItem> itemsToPurchase;

  CreateErrandRequest({
    this.consumerRequest,
    this.errandInformation,
    this.itemsToPurchase,
  });
}

class CreateTransportRequest extends ConsumerRequestEvent {
  final ConsumerRequest consumerRequest;
  final TransportInformation transportInformation;

  CreateTransportRequest({
    this.consumerRequest,
    this.transportInformation,
  });
}

class GetConsumerRequests extends ConsumerRequestEvent {
  final String consumerId;

  GetConsumerRequests({this.consumerId});
}

class LoadConsumerRequests extends ConsumerRequestEvent {
  final List<ConsumerRequest> consumerRequestList;

  LoadConsumerRequests(this.consumerRequestList);
}

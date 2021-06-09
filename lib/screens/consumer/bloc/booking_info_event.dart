part of 'booking_info_bloc.dart';

abstract class BookingInfoEvent extends Equatable {
  const BookingInfoEvent();

  @override
  List<Object> get props => [];
}

class StreamRequest extends BookingInfoEvent {
  final String requestId;

  StreamRequest(this.requestId);
}

class LoadRequest extends BookingInfoEvent {
  final ConsumerRequest consumerRequest;

  LoadRequest(this.consumerRequest);
}

class StreamTransportInformation extends BookingInfoEvent {
  final String requestId;

  StreamTransportInformation(this.requestId);
}

class LoadTransportInformation extends BookingInfoEvent {
  final TransportInformation transportInformation;

  LoadTransportInformation(this.transportInformation);
}

class StreamDeliveryInformation extends BookingInfoEvent {
  final String requestId;

  StreamDeliveryInformation(this.requestId);
}

class LoadDeliveryInformation extends BookingInfoEvent {
  final DeliveryInformation deliveryInformation;

  LoadDeliveryInformation(this.deliveryInformation);
}

class StreamErrandInformation extends BookingInfoEvent {
  final String requestId;

  StreamErrandInformation(this.requestId);
}

class LoadErrandInformation extends BookingInfoEvent {
  final ErrandInformation errandInformation;

  LoadErrandInformation(this.errandInformation);
}

class StreamRiderLocation extends BookingInfoEvent {
  final String riderId;

  StreamRiderLocation(this.riderId);
}

class LoadRiderLocation extends BookingInfoEvent {
  final List<double> riderLoc;

  LoadRiderLocation(this.riderLoc);
}

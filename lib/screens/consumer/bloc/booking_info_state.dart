part of 'booking_info_bloc.dart';

abstract class BookingInfoState extends Equatable {
  const BookingInfoState();

  @override
  List<Object> get props => [];
}

class BookingInfoInitial extends BookingInfoState {}

class LoadingRequest extends BookingInfoState {}

class LoadingRequestInfo extends BookingInfoState {}

class RequestLoaded extends BookingInfoState {
  final ConsumerRequest consumerRequest;

  RequestLoaded(this.consumerRequest);

  @override
  List<Object> get props => [consumerRequest];
}

class TransportInfoLoaded extends BookingInfoState {
  final TransportInformation transportInformation;

  TransportInfoLoaded(this.transportInformation);

  @override
  List<Object> get props => [transportInformation];
}

class ErrandInfoLoaded extends BookingInfoState {
  final ErrandInformation errandInformation;
  final List<ErrandItem> items;

  ErrandInfoLoaded(this.errandInformation, this.items);

  @override
  List<Object> get props => [errandInformation, items];
}

class DeliveryInfoLoaded extends BookingInfoState {
  final DeliveryInformation deliveryInformation;

  DeliveryInfoLoaded(this.deliveryInformation);

  @override
  List<Object> get props => [deliveryInformation];
}

class RiderLocationLoaded extends BookingInfoState {
  final List<double> riderLoc;

  RiderLocationLoaded(this.riderLoc);

  @override
  List<Object> get props => [riderLoc];
}

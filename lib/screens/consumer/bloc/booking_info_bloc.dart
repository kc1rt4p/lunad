import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/data/models/delivery_information.dart';
import 'package:lunad/data/models/errand_information.dart';
import 'package:lunad/data/models/transport_information.dart';
import 'package:lunad/repositories/request_repository.dart';
import 'package:lunad/repositories/rider_repository.dart';

part 'booking_info_event.dart';
part 'booking_info_state.dart';

class BookingInfoBloc extends Bloc<BookingInfoEvent, BookingInfoState> {
  final _requestRepository = RequestRepository();
  final _riderRepository = RiderRepository();

  BookingInfoBloc() : super(BookingInfoInitial());

  StreamSubscription requestStream;
  StreamSubscription requestInfoStream;
  StreamSubscription riderLocationStream;

  @override
  Stream<BookingInfoState> mapEventToState(
    BookingInfoEvent event,
  ) async* {
    if (event is StreamRequest) {
      yield LoadingRequest();
      await requestStream?.cancel();
      requestStream = _requestRepository
          .getConsumerRequest(event.requestId)
          .listen((request) {
        add(LoadRequest(request));
      });
    }

    if (event is LoadRequest) {
      yield RequestLoaded(event.consumerRequest);
    }

    if (event is StreamDeliveryInformation) {
      yield LoadingRequestInfo();
      await requestInfoStream?.cancel();
      requestInfoStream = _requestRepository
          .getDeliveryInformation(event.requestId)
          .listen((deliveryInfo) {
        add(LoadDeliveryInformation(deliveryInfo));
      });
    }

    if (event is LoadDeliveryInformation) {
      yield DeliveryInfoLoaded(event.deliveryInformation);
    }

    if (event is StreamErrandInformation) {
      yield LoadingRequestInfo();
      await requestInfoStream?.cancel();
      requestInfoStream = _requestRepository
          .getErrandInformation(event.requestId)
          .listen((errandInfo) {
        add(LoadErrandInformation(errandInfo));
      });
    }

    if (event is LoadErrandInformation) {
      final items =
          await _requestRepository.getErrandItems(event.errandInformation.id);
      yield ErrandInfoLoaded(event.errandInformation, items);
    }

    if (event is StreamTransportInformation) {
      yield LoadingRequestInfo();
      await requestInfoStream?.cancel();
      requestInfoStream = _requestRepository
          .getTransportInformation(event.requestId)
          .listen((transportInfo) {
        add(LoadTransportInformation(transportInfo));
      });
    }

    if (event is StreamRiderLocation) {
      await riderLocationStream?.cancel();
      if (event.riderId.isNotEmpty) {
        riderLocationStream =
            _riderRepository.streamRiderLocation(event.riderId).listen((loc) {
          add(LoadRiderLocation(loc));
        });
      }
    }

    if (event is LoadRiderLocation) {
      yield RiderLocationLoaded(event.riderLoc);
    }

    if (event is LoadTransportInformation) {
      yield TransportInfoLoaded(event.transportInformation);
    }
  }

  @override
  Future<void> close() {
    requestStream?.cancel();
    requestInfoStream?.cancel();
    riderLocationStream?.cancel();
    return super.close();
  }
}

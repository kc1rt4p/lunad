import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad/data/models/delivery_information.dart';
import 'package:lunad/data/models/errand_information.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/data/models/transport_information.dart';
import 'package:lunad/repositories/request_repository.dart';

part 'consumer_request_event.dart';
part 'consumer_request_state.dart';

class ConsumerRequestBloc
    extends Bloc<ConsumerRequestEvent, ConsumerRequestState> {
  final _requestRepository = RequestRepository();
  StreamSubscription requestList;

  ConsumerRequestBloc() : super(ConsumerRequestInitial());

  @override
  Stream<ConsumerRequestState> mapEventToState(
    ConsumerRequestEvent event,
  ) async* {
    if (event is CreateDeliveryRequest) {
      yield CreatingRequest();
      var deliveryRequest = event.consumerRequest;
      var deliveryInformation = event.deliveryInformation;
      await _requestRepository.createDeliveryRequest(
          deliveryRequest, deliveryInformation);
      yield CreatedRequest();
    }

    if (event is CreateErrandRequest) {
      yield CreatingRequest();
      var errandRequest = event.consumerRequest;
      var errandInformation = event.errandInformation;
      var itemsToPurchase = event.itemsToPurchase;
      await _requestRepository.createErrandRequest(
        errandRequest,
        errandInformation,
        itemsToPurchase,
      );
      yield CreatedRequest();
    }

    if (event is CreateTransportRequest) {
      yield CreatingRequest();
      var errandRequest = event.consumerRequest;
      var errandInformation = event.transportInformation;
      await _requestRepository.createTransportRequest(
          errandRequest, errandInformation);
      yield CreatedRequest();
    }

    if (event is GetConsumerRequests) {
      await requestList?.cancel();
      requestList = _requestRepository
          .getConsumerRequests(event.consumerId)
          .listen((list) {
        add(LoadConsumerRequests(list));
      });
    }

    if (event is LoadConsumerRequests) {
      yield LoadedRequests(event.consumerRequestList);
    }
  }

  @override
  Future<void> close() {
    requestList?.cancel();
    return super.close();
  }
}

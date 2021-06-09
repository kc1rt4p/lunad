import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad/data/models/delivery_information.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/repositories/request_repository.dart';

part 'courier_screen_event.dart';
part 'courier_screen_state.dart';

class CourierScreenBloc extends Bloc<CourierScreenEvent, CourierScreenState> {
  final _requestRepository = RequestRepository();
  CourierScreenBloc() : super(CourierScreenInitial());

  @override
  Stream<CourierScreenState> mapEventToState(
    CourierScreenEvent event,
  ) async* {
    if (event is CreateDeliveryRequest) {
      yield CourierScreenLoading();
      var request = event.consumerRequest;
      var information = event.deliveryInformation;
      await _requestRepository.createDeliveryRequest(request, information);
      yield CreatedConsumerRequest();
    }

    if (event is ShowError) {
      yield CourierScreenError(event.message);
      yield CourierScreenInitial();
    }
  }
}

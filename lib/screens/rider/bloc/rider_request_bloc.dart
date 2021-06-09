import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/data/models/delivery_information.dart';
import 'package:lunad/data/models/errand_information.dart';
import 'package:lunad/repositories/request_repository.dart';
import 'package:lunad/repositories/rider_repository.dart';

part 'rider_request_event.dart';
part 'rider_request_state.dart';

class RiderRequestBloc extends Bloc<RiderRequestEvent, RiderRequestState> {
  StreamSubscription assignedRequestStream;
  final riderRepository = RiderRepository();
  final requestRepository = RequestRepository();

  RiderRequestBloc() : super(RiderRequestInitial());

  @override
  Stream<RiderRequestState> mapEventToState(
    RiderRequestEvent event,
  ) async* {
    if (event is UpdateRiderLocation) {
      await riderRepository.updateRiderLocation(event.riderId, event.latLng);
      if (event.requestId != null) {
        await requestRepository.updateRequestRiderLocation(
            event.requestId, event.latLng);
      }
    }

    if (event is UpdateRiderAvailability) {
      await riderRepository.setRiderAvailability(
          event.riderId, event.availability);
      yield UpdatedRiderAvailability();
      if (event.availability) {
        yield WaitingForRequest();
      }
    }

    if (event is RejectAssignedRequest) {
      await riderRepository.riderRejectRequest(event.requestId);
      yield RejectedAssignedRequest();
      yield WaitingForRequest();
    }

    if (event is WaitForRequest) {
      yield WaitingForRequest();
      assignedRequestStream?.cancel();
      assignedRequestStream = riderRepository
          .streamAssignedRequest(event.riderId)
          .listen((request) {
        if (request.status == 'assigned') {
          add(LoadRequest(request));
        } else if (request.status != 'placed') {
          add(LoadExistingRequest(request));
        }
      });
    }

    if (event is UpdateRequest) {
      yield UpdatingRequest();
      await requestRepository.updateRequest(event.requestId, event.status);
      yield RequestUpdated();
    }

    if (event is LoadExistingRequest) {
      final request = event.request;
      if (request.type == 'errand') {
        final errandInfo = await requestRepository.getErrandInfo(request.id);
        final itemsToPurchase =
            await requestRepository.getErrandItems(request.id);
        yield AcceptedErrandRequest(request, errandInfo, itemsToPurchase);
      }

      if (request.type == 'delivery') {
        final deliveryInfo =
            await requestRepository.getDeliveryInfo(request.id);

        yield AcceptedDeliveryRequest(request, deliveryInfo);
      }
    }

    if (event is AcceptAssignedRequest) {
      yield AcceptingRequest();
      await riderRepository.riderAcceptRequest(event.requestId, event.riderId);
      final request = await requestRepository.getRequest(event.requestId);
      if (request.type == 'errand') {
        final errandInfo = await requestRepository.getErrandInfo(request.id);
        final itemsToPurchase =
            await requestRepository.getErrandItems(request.id);
        yield AcceptedErrandRequest(request, errandInfo, itemsToPurchase);
      }

      if (request.type == 'delivery') {
        final deliveryInfo =
            await requestRepository.getDeliveryInfo(request.id);

        yield AcceptedDeliveryRequest(request, deliveryInfo);
      }
    }

    if (event is CompleteAssignedRequest) {
      await riderRepository.riderCompleteRequest(
          event.requestId, event.riderId);

      final request = await requestRepository.getRequest(event.requestId);

      if (request.type == 'delivery') {
        final deliveryInfo =
            await requestRepository.getDeliveryInfo(event.requestId);
        yield CompletedDeliveryRequest(request, deliveryInfo);
      }

      if (request.type == 'errand') {
        final errandInfo =
            await requestRepository.getErrandInfo(event.requestId);
        yield CompletedErrandRequest(request, errandInfo);
      }

      yield WaitingForRequest();
    }

    if (event is PickUpAssignedRequest) {
      await riderRepository.riderPickedUpRequest(
          event.requestId, event.riderId);
      yield PickedUpAssignedRequest();
    }

    if (event is LoadRequest) {
      final request = event.request;
      yield LoadedAssignedRequest(request);
    }
  }

  @override
  Future<void> close() {
    assignedRequestStream?.cancel();
    return super.close();
  }
}

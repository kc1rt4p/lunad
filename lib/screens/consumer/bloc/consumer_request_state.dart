part of 'consumer_request_bloc.dart';

abstract class ConsumerRequestState extends Equatable {
  const ConsumerRequestState();

  @override
  List<Object> get props => [];
}

class ConsumerRequestInitial extends ConsumerRequestState {}

class CreatedRequest extends ConsumerRequestState {}

class CreatingRequest extends ConsumerRequestState {}

class ErrorCreatingRequest extends ConsumerRequestState {}

class LoadingRequests extends ConsumerRequestState {}

class LoadedRequests extends ConsumerRequestState {
  final List<ConsumerRequest> consumerRequests;

  LoadedRequests(this.consumerRequests);

  @override
  List<Object> get props => [consumerRequests];
}

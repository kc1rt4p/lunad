import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/data/models/user.dart';
import 'package:lunad/services/notification_service.dart';
import 'package:lunad/screens/consumer/bloc/consumer_request_bloc.dart';
import 'package:lunad/screens/consumer/booking_information_screen.dart';
import 'package:lunad/screens/consumer/widgets/loading.dart';
import 'package:lunad/screens/consumer/widgets/request_item.dart';

class ConsumerBookingsScreen extends StatefulWidget {
  final User user;

  const ConsumerBookingsScreen({Key key, this.user}) : super(key: key);

  @override
  _ConsumerBookingsScreenState createState() => _ConsumerBookingsScreenState();
}

class _ConsumerBookingsScreenState extends State<ConsumerBookingsScreen>
    with WidgetsBindingObserver {
  bool justOpened = true;

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      height: screenHeight,
      width: screenWidth,
      padding: EdgeInsets.fromLTRB(10.0, statusBarHeight * 1.5, 10.0, 10.0),
      color: Colors.red.shade600,
      child: Column(
        children: [
          Text(
            'BOOKINGS',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Tap on a booking to view more info',
            style: TextStyle(color: Colors.white54),
          ),
          SizedBox(height: 20.0),
          Expanded(
            child: BlocProvider<ConsumerRequestBloc>(
              create: (context) => ConsumerRequestBloc()
                ..add(GetConsumerRequests(consumerId: widget.user.id)),
              child: BlocListener<ConsumerRequestBloc, ConsumerRequestState>(
                listener: (context, state) {
                  if (state is LoadedRequests) {
                    if (_notification == AppLifecycleState.paused ||
                        _notification == AppLifecycleState.inactive) {
                      NotificationService().showRequestsUpdateNotification();
                    }
                  }
                },
                child: BlocBuilder<ConsumerRequestBloc, ConsumerRequestState>(
                  builder: (context, state) {
                    if (state is LoadedRequests) {
                      if (state.consumerRequests.isNotEmpty)
                        return buildLoadedRequests(
                            context, state.consumerRequests);
                      else
                        return buildEmptyDeliveries(context);
                    }

                    return buildLoading(context, screenHeight, screenWidth);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildLoadedRequests(BuildContext context, List<ConsumerRequest> requests) {
    return ListView(
      padding: EdgeInsets.zero,
      children: requests.map((request) {
        return GestureDetector(
          onTap: () => _onRequestTap(request),
          child: buildRequestItem(request),
        );
      }).toList(),
    );
  }

  _onRequestTap(ConsumerRequest request) async {
    WidgetsBinding.instance.removeObserver(this);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return BookingInformationScreen(request: request);
        },
      ),
    );
    WidgetsBinding.instance.addObserver(this);
  }

  buildEmptyDeliveries(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: FaIcon(
            FontAwesomeIcons.ghost,
            size: 90.0,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10.0),
        Text(
          'You have no active deliveries',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.2,
            height: 1.2,
            wordSpacing: 1.2,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}

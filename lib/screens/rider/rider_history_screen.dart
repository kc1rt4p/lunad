import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lunad/data/models/completed_request.dart';
import 'package:lunad/data/models/rider.dart';
import 'package:lunad/screens/rider/widgets/history_item.dart';

import 'bloc/rider_history_bloc.dart';

class RiderHistoryScreen extends StatefulWidget {
  final Rider rider;

  const RiderHistoryScreen({Key key, this.rider}) : super(key: key);
  @override
  _RiderHistoryScreenState createState() => _RiderHistoryScreenState();
}

class _RiderHistoryScreenState extends State<RiderHistoryScreen> {
  Rider _rider;

  @override
  void initState() {
    _rider = widget.rider;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Column(
          children: [
            Text('Job History'),
            Text(
              '${_rider.firstName} ${_rider.lastName}',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: BlocProvider<RiderHistoryBloc>(
        create: (context) =>
            RiderHistoryBloc()..add(LoadRiderHistory(_rider.id)),
        child: BlocBuilder<RiderHistoryBloc, RiderHistoryState>(
          builder: (context, state) {
            print(state);
            if (state is LoadedRiderHistory) {
              return buildLoadedRiderHistory(context, state.requests);
            }
            return Text('');
          },
        ),
      ),
    );
  }

  buildLoadedRiderHistory(
      BuildContext context, List<CompletedRequest> requests) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight,
      child: ListView(
        children: requests.map((request) {
          return buildHistoryItem(
            request,
            Colors.red.shade600,
            Colors.white,
            true,
          );
        }).toList(),
      ),
    );
  }
}

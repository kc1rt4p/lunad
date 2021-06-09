import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lunad/data/models/completed_request.dart';
import 'package:lunad/data/models/rider.dart';
import 'package:lunad/data/models/rider_earning.dart';
import 'package:lunad/screens/rider/bloc/rider_earnings_bloc.dart';
import 'package:lunad/screens/rider/widgets/history_item.dart';
import 'package:lunad/widgets/styled_icon_button.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class RiderEarningsScreen extends StatefulWidget {
  final Rider rider;

  const RiderEarningsScreen({Key key, this.rider}) : super(key: key);

  @override
  _RiderEarningsScreenState createState() => _RiderEarningsScreenState();
}

class _RiderEarningsScreenState extends State<RiderEarningsScreen> {
  Rider _rider;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    _rider = widget.rider;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: screenHeight,
        color: Colors.red.shade600,
        child: Stack(
          children: [
            BlocProvider<RiderEarningsBloc>(
              create: (context) => RiderEarningsBloc()
                ..add(StreamRiderEarnings(_rider.id, DateTime.now())),
              child: BlocListener<RiderEarningsBloc, RiderEarningsState>(
                listener: (context, state) {
                  if (state is LoadedEarnings) {
                    print('Earnings Updated');
                  }
                },
                child: BlocBuilder<RiderEarningsBloc, RiderEarningsState>(
                  builder: (context, state) {
                    print(state);
                    if (state is LoadedEarnings) {
                      return buildLoadedEarnings(
                          context, state.earning, state.requests);
                    }
                    return buildLoading(context);
                  },
                ),
              ),
            ),
            Positioned(
              top: 50.0,
              left: 10.0,
              child: buildIconButton(
                onTap: () => Navigator.pop(context),
                icon: Icons.arrow_back_outlined,
                tooltip: 'GO BACK',
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildLoading(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight,
      child: Center(
        child: HeartbeatProgressIndicator(
          child: SizedBox(
            width: 100.0,
            child: Image.asset('assets/images/logo_white.png'),
          ),
        ),
      ),
    );
  }

  Widget buildLoadedEarnings(BuildContext context, RiderEarning earning,
      List<CompletedRequest> requests) {
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.red.shade600,
      height: screenHeight,
      margin: EdgeInsets.only(top: paddingTop),
      width: double.infinity,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Your Earnings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                fontSize: 25.0,
              ),
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: () => _onDatePicked(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.yMMMd().format(_selectedDate),
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppin',
                      fontSize: 16.0,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
          Text(
            'You can view earnings from different date',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 15.0),
          Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.only(
              bottom: 15.0,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        color: Colors.red.shade400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Earned',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Center(
                              child: Text(
                                '₱ ${earning.totalEarnings.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        color: Colors.red.shade400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distance Travelled',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Center(
                              child: Text(
                                '${earning.distanceTravelled.toStringAsFixed(2)} km',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        color: Colors.red.shade400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dispatcher Fee',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Center(
                              child: Text(
                                '₱ ${earning.dispatcherAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        color: Colors.red.shade400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Time',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Center(
                              child: Text(
                                '${(earning.totalTime / 60).toStringAsFixed(2)} mins',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        color: Colors.red.shade400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Completed Jobs',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Center(
                              child: Text(
                                earning.completedJobs.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        color: Colors.red.shade400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Jobs',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Center(
                              child: Text(
                                earning.completedDelivery.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        color: Colors.red.shade400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Errand Jobs',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Center(
                              child: Text(
                                earning.completedErrand.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Completed Requests for ${DateFormat.yMMMd().format(_selectedDate)}:',
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    children: requests.isNotEmpty
                        ? requests.map((request) {
                            return buildHistoryItem(
                              request,
                              Colors.white,
                              Colors.black,
                              false,
                            );
                          }).toList()
                        : [
                            SizedBox(height: 30.0),
                            Center(
                              child: Text(
                                'You have not completed any jobs for this day',
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _onDatePicked(BuildContext context) async {
    final selectedDate = await DatePicker.showDatePicker(
      context,
      currentTime: DateTime.now(),
    );

    if (selectedDate == null) return;

    setState(() {
      _selectedDate = selectedDate;
    });

    BlocProvider.of<RiderEarningsBloc>(context)
        .add(StreamRiderEarnings(_rider.id, _selectedDate));
  }
}

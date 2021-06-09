import 'package:flutter/material.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/repositories/request_repository.dart';
import 'package:lunad/screens/consumer/widgets/loading.dart';
import 'package:lunad/screens/consumer/widgets/request_item.dart';

class ConsumerHistoryScreen extends StatefulWidget {
  final String consumerId;

  const ConsumerHistoryScreen({Key key, this.consumerId}) : super(key: key);

  @override
  _ConsumerHistoryScreenState createState() => _ConsumerHistoryScreenState();
}

class _ConsumerHistoryScreenState extends State<ConsumerHistoryScreen> {
  final _requestRepository = RequestRepository();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight,
      padding: EdgeInsets.fromLTRB(10.0, statusBarHeight * 1.5, 10.0, 10.0),
      color: Colors.red.shade600,
      child: Column(
        children: [
          Text(
            'BOOKINGS HISTORY',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'These are your past bookings',
            style: TextStyle(color: Colors.white54),
          ),
          Expanded(
            child: FutureBuilder<List<ConsumerRequest>>(
              future:
                  _requestRepository.getPastConsumerRequests(widget.consumerId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final requests = snapshot.data;
                  if (requests.isNotEmpty)
                    return ListView(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      children: requests
                          .map((request) => buildRequestItem(request))
                          .toList(),
                    );
                  else {
                    return Center(
                      child: Text(
                        'No past bookings found',
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.3,
                        ),
                      ),
                    );
                  }
                }

                return buildLoading(context, screenHeight, screenWidth);
              },
            ),
          ),
        ],
      ),
    );
  }
}

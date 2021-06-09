import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/data/models/transport_information.dart';
import 'package:lunad/repositories/request_repository.dart';
import 'package:lunad/screens/consumer/widgets/loading.dart';
import 'package:lunad/screens/consumer/widgets/request_created.dart';
import 'package:lunad/widgets/filled_button.dart';

import 'bloc/consumer_request_bloc.dart';

class TransportInformationScreen extends StatefulWidget {
  final ConsumerRequest consumerRequest;

  const TransportInformationScreen({Key key, this.consumerRequest})
      : super(key: key);

  @override
  _TransportInformationScreenState createState() =>
      _TransportInformationScreenState();
}

class _TransportInformationScreenState
    extends State<TransportInformationScreen> {
  var formKey = GlobalKey<FormState>();
  ConsumerRequest consumerRequest;

  double distance = 0;
  double transportFee = 0;
  double serviceFee = 10;

  @override
  void initState() {
    consumerRequest = widget.consumerRequest;
    _computeDistance();
    _computeFare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Transport Information'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: BlocProvider<ConsumerRequestBloc>(
        create: (context) => ConsumerRequestBloc(),
        child: BlocListener<ConsumerRequestBloc, ConsumerRequestState>(
          listener: (context, state) {
            // listen here for state changes
          },
          child: BlocBuilder<ConsumerRequestBloc, ConsumerRequestState>(
            builder: (context, state) {
              if (state is CreatingRequest)
                return buildLoading(context, screenHeight, screenWidth);

              if (state is CreatedRequest)
                return buildRequestCreated(context, screenHeight, screenWidth);

              return buildInitial(context);
            },
          ),
        ),
      ),
    );
  }

  buildInitial(BuildContext context) {
    return Container(
      color: Colors.red.shade600,
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 20.0,
      ),
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          buildTransportInfoItem(
                            label: 'Pick-up Location',
                            value: consumerRequest.pickUpAddress,
                          ),
                          SizedBox(height: 15.0),
                          buildTransportInfoItem(
                            label: 'Drop-off Location',
                            value: consumerRequest.dropOffAddress,
                          ),
                          SizedBox(height: 15.0),
                          buildTransportInfoItem(
                            label: 'Distance',
                            value: '${distance.toStringAsFixed(2)} km',
                          ),
                          SizedBox(height: 15.0),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Transport Fee',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      '₱ ${transportFee.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Service Fee',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      '₱ ${serviceFee.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  children: [
                                    Text(
                                      'Total Amount',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      '₱ ${(serviceFee + transportFee).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.0),
                          buildFilledButton(
                            labelColor: Colors.red.shade600,
                            label: 'Submit',
                            onPressed: () => _onSubmitTapped(context),
                          ),
                          buildFilledButton(
                            labelColor: Colors.black,
                            label: 'Cancel',
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onSubmitTapped(BuildContext context) {
    final _consumerRequestBloc = BlocProvider.of<ConsumerRequestBloc>(context);

    final ConsumerRequest consumerRequest = widget.consumerRequest;

    final transportInformation = TransportInformation(
      distance: distance,
      serviceFee: serviceFee,
      transportFee: transportFee,
      totalAmount: serviceFee + transportFee,
    );

    _consumerRequestBloc.add(CreateTransportRequest(
      consumerRequest: consumerRequest,
      transportInformation: transportInformation,
    ));
  }

  _computeDistance() {
    setState(() {
      distance = Geolocator.distanceBetween(
            consumerRequest.pickUpLatLng[0],
            consumerRequest.pickUpLatLng[1],
            consumerRequest.dropOffLatLng[0],
            consumerRequest.dropOffLatLng[1],
          ) /
          1000;
    });
  }

  _computeFare() {
    transportFee += 50;
    if (distance > 2.5) {
      transportFee += (distance - 2.5) * 10;
    }
  }

  Column buildTransportInfoItem({String label, String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 5.0),
          child: Text(
            label ?? '',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: EdgeInsets.all(10.0),
          child: Text(
            value ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }
}

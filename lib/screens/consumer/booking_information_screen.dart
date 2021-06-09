import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/data/models/delivery_information.dart';
import 'package:lunad/data/models/errand_information.dart';
import 'package:lunad/data/models/transport_information.dart';
import 'package:lunad/screens/consumer/bloc/booking_info_bloc.dart';
import 'package:lunad/services/location_service.dart';
import 'package:lunad/services/notification_service.dart';
import 'package:lunad/widgets/item_list_dialog.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:timeline_tile/timeline_tile.dart';

class BookingInformationScreen extends StatefulWidget {
  final ConsumerRequest request;

  const BookingInformationScreen({Key key, this.request}) : super(key: key);

  @override
  _BookingInformationScreenState createState() =>
      _BookingInformationScreenState();
}

class _BookingInformationScreenState extends State<BookingInformationScreen>
    with WidgetsBindingObserver {
  GoogleMapController _googleMapController;
  ConsumerRequest _consumerRequest;
  Map<MarkerId, Marker> _markers = {};

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    _consumerRequest = widget.request;
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${_consumerRequest.type.toUpperCase()} INFORMATION'),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        color: Colors.red.shade600,
        height: screenHeight,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              child: Text(
                'You can track ${_consumerRequest.type} on this screen in realtime',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Container(
              height: screenHeight * .25,
              child: buildMap(context),
            ),
            BlocProvider<BookingInfoBloc>(
              create: (context) =>
                  BookingInfoBloc()..add(StreamRequest(_consumerRequest.id)),
              child: BlocListener<BookingInfoBloc, BookingInfoState>(
                listener: (context, state) {
                  if (state is RequestLoaded) {
                    if (_notification == AppLifecycleState.paused ||
                        _notification == AppLifecycleState.inactive) {
                      NotificationService()
                          .showRequestUpdateNotification(state.consumerRequest);
                    }
                    final request = state.consumerRequest;
                    if (request.riderCurrentLocation.isNotEmpty) {
                      _updateRiderLocation(request.riderCurrentLocation[0],
                          request.riderCurrentLocation[1]);
                    }
                  }
                },
                child: BlocBuilder<BookingInfoBloc, BookingInfoState>(
                  builder: (context, state) {
                    if (state is RequestLoaded) {
                      return buildRequestDetail(context, state.consumerRequest);
                    }

                    return Center(
                      child: JumpingDotsProgressIndicator(
                        color: Colors.white,
                        fontSize: 50.0,
                      ),
                    );
                  },
                ),
              ),
            ),
            BlocProvider<BookingInfoBloc>(
              create: (context) =>
                  BookingInfoBloc()..add(_determineInfoEvent()),
              child: BlocListener<BookingInfoBloc, BookingInfoState>(
                listener: (context, state) {
                  //
                },
                child: BlocBuilder<BookingInfoBloc, BookingInfoState>(
                  builder: (context, state) {
                    return buildRequestInformation(context, state);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BookingInfoEvent _determineInfoEvent() {
    switch (_consumerRequest.type) {
      case 'delivery':
        return StreamDeliveryInformation(_consumerRequest.id);
        break;
      case 'errand':
        return StreamErrandInformation(_consumerRequest.id);
        break;
      default:
        return StreamTransportInformation(_consumerRequest.id);
    }
  }

  buildRequestDetail(BuildContext context, ConsumerRequest request) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildStatusTimeline(context, request.status),
        Visibility(
          visible: request.type != 'errand',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: buildInfoItem(
                      label: 'Pick-up Date',
                      value: request.pickUpDate != null
                          ? DateFormat.yMMMd()
                              .add_jm()
                              .format(request.pickUpDate.toDate())
                          : 'ASAP',
                    ),
                  ),
                  Expanded(
                    child: buildInfoItem(
                      label: 'Date Booked',
                      value: DateFormat.yMMMd()
                          .add_jm()
                          .format(request.dateRequested.toDate()),
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.white54),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: buildInfoItem(
                label: 'Rider',
                value: request.riderName ?? 'Not assigned yet',
              ),
            ),
            Expanded(
              child: buildInfoItem(
                label: 'Phone Number',
                value: request.riderPhoneNumber ?? 'Not assigned yet',
              ),
            ),
          ],
        ),
        Divider(color: Colors.white54),
      ],
    );
  }

  buildStatusTimeline(BuildContext context, String status) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 22.0),
      width: double.infinity,
      height: 100.0,
      child: Row(
        children: [
          Expanded(
            child: TimelineTile(
              isFirst: true,
              axis: TimelineAxis.horizontal,
              alignment: TimelineAlign.start,
              indicatorStyle: IndicatorStyle(
                color: status == 'placed' ||
                        status == 'assigned' ||
                        status == 'processing' ||
                        status == 'intransitdropoff' ||
                        status == 'intransitpickup' ||
                        status == 'arriveddropoff' ||
                        status == 'arrivedpickup' ||
                        status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
                height: 30.0,
                width: 30.0,
                iconStyle: IconStyle(
                  iconData: Icons.assignment_turned_in,
                  color: Colors.white,
                ),
              ),
              afterLineStyle: LineStyle(
                thickness: 3,
                color: status == 'intransitdropoff' ||
                        status == 'assigned' ||
                        status == 'intransitpickup' ||
                        status == 'processing' ||
                        status == 'arriveddropoff' ||
                        status == 'arrivedpickup' ||
                        status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
              ),
              beforeLineStyle: LineStyle(thickness: 3),
              endChild: Container(
                padding: EdgeInsets.only(top: 5.0),
                child: status == 'placed'
                    ? Text(
                        'Placed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: TimelineTile(
              alignment: TimelineAlign.start,
              axis: TimelineAxis.horizontal,
              indicatorStyle: IndicatorStyle(
                color: status == 'processing' ||
                        status == 'assigned' ||
                        status == 'intransitpickup' ||
                        status == 'arrivedpickup' ||
                        status == 'intransitdropoff' ||
                        status == 'arriveddropoff' ||
                        status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
                height: 30.0,
                width: 30.0,
                iconStyle: IconStyle(
                  iconData: Icons.print,
                  color: Colors.white,
                ),
              ),
              afterLineStyle: LineStyle(
                thickness: 3,
                color: status == 'intransitdropoff' ||
                        status == 'arriveddropoff' ||
                        status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
              ),
              beforeLineStyle: LineStyle(
                thickness: 3,
                color: status == 'processing' ||
                        status == 'assigned' ||
                        status == 'intransitpickup' ||
                        status == 'arrivedpickup' ||
                        status == 'intransitdropoff' ||
                        status == 'arriveddropoff' ||
                        status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
              ),
              endChild: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: status == 'processing' ||
                        status == 'assigned' ||
                        status == 'intransitpickup' ||
                        status == 'arrivedpickup'
                    ? Text(
                        'Processing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: TimelineTile(
              alignment: TimelineAlign.start,
              axis: TimelineAxis.horizontal,
              indicatorStyle: IndicatorStyle(
                color: status == 'intransitdropoff' ||
                        status == 'arriveddropoff' ||
                        status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
                height: 30.0,
                width: 30.0,
                iconStyle: IconStyle(
                  iconData: Icons.two_wheeler,
                  color: Colors.white,
                ),
              ),
              afterLineStyle: LineStyle(
                thickness: 3,
                color: status == 'arriveddropoff' || status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
              ),
              beforeLineStyle: LineStyle(
                thickness: 3,
                color: status == 'arriveddropoff' ||
                        status == 'intransitdropoff' ||
                        status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
              ),
              endChild: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: status == 'intransitdropoff'
                    ? Text(
                        'In Transit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: TimelineTile(
              alignment: TimelineAlign.start,
              axis: TimelineAxis.horizontal,
              indicatorStyle: IndicatorStyle(
                color: status == 'arriveddropoff' || status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
                height: 30.0,
                width: 30.0,
                iconStyle: IconStyle(
                  iconData: Icons.pin_drop,
                  color: Colors.white,
                ),
              ),
              afterLineStyle: LineStyle(
                thickness: 3,
                color: status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
              ),
              beforeLineStyle: LineStyle(
                thickness: 3,
                color: status == 'arriveddropoff' || status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
              ),
              endChild: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: status == 'arriveddropoff'
                    ? Text(
                        'At Drop-off',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: TimelineTile(
              alignment: TimelineAlign.start,
              axis: TimelineAxis.horizontal,
              isLast: true,
              indicatorStyle: IndicatorStyle(
                color: status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
                height: 30.0,
                width: 30.0,
                iconStyle: IconStyle(
                  iconData: Icons.check_circle,
                  color: Colors.white,
                ),
              ),
              afterLineStyle: LineStyle(
                thickness: 3,
                color: status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
              ),
              beforeLineStyle: LineStyle(
                thickness: 3,
                color: status == 'completed'
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
              ),
              endChild: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: status == 'completed'
                    ? Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildRequestInformation(BuildContext context, BookingInfoState state) {
    if (state is DeliveryInfoLoaded) {
      return buildDeliveryInfo(context, state.deliveryInformation);
    }

    if (state is TransportInfoLoaded) {
      return buildTransportInfo(context, state.transportInformation);
    }

    if (state is ErrandInfoLoaded) {
      return buildErrandInfo(context, state.errandInformation, state.items);
    }

    return Text('');
  }

  buildTransportInfo(
      BuildContext context, TransportInformation transportInformation) {
    return ListView(
      children: [
        buildInfoItem(
          label: 'Total Distance',
          value: '${transportInformation.distance.toStringAsFixed(2)}km',
        ),
        buildInfoItem(
          label: 'Total Amount',
          value: '₱${transportInformation.totalAmount.toStringAsFixed(2)}',
        ),
      ],
    );
  }

  buildErrandInfo(BuildContext context, ErrandInformation errandInformation,
      List<ErrandItem> items) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: buildInfoItem(
                label: 'Store Name',
                value: errandInformation.storeName,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => showItemsToPurchase(
                    context, items, errandInformation.storeName),
                child: buildInfoItem(
                  label: 'Items to Purchase',
                  value: 'VIEW ITEMS',
                ),
              ),
            ),
          ],
        ),
        Divider(color: Colors.white60),
        Row(
          children: [
            Expanded(
              child: buildInfoItem(
                label: 'Collect Amount',
                value: '₱${errandInformation.totalFee.toStringAsFixed(2)}',
              ),
            ),
            Expanded(
              child: buildInfoItem(
                label: 'Purchase Amount',
                value:
                    '₱${errandInformation.estimatedPrice.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0),
        Text(
          'Please prepare amount before the assigned rider arrives',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.3,
          ),
        ),
      ],
    );
  }

  buildDeliveryInfo(
      BuildContext context, DeliveryInformation deliveryInformation) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: buildInfoItem(
                    label: 'Payment From',
                    value: deliveryInformation.paymentFrom.toUpperCase(),
                  ),
                ),
                Expanded(
                  child: buildInfoItem(
                    label: 'Total Amount',
                    value:
                        '₱${deliveryInformation.totalAmount.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              deliveryInformation.paymentFrom == 'sender'
                  ? 'Please prepare amount before the assigned rider arrives'
                  : 'Please tell receiver to prepare amount while waiting for the assigned rider',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  GoogleMap buildMap(BuildContext context) {
    return GoogleMap(
      zoomControlsEnabled: false,
      zoomGesturesEnabled: false,
      compassEnabled: false,
      scrollGesturesEnabled: false,
      mapToolbarEnabled: false,
      tiltGesturesEnabled: false,
      mapType: MapType.terrain,
      initialCameraPosition: CameraPosition(
        target: LatLng(
          _consumerRequest.pickUpLatLng[0],
          _consumerRequest.pickUpLatLng[1],
        ),
        zoom: 16.0,
      ),
      onMapCreated: _onMapCreated,
      markers: Set<Marker>.of(_markers.values),
    );
  }

  _updateRiderLocation(double lat, double lng) async {
    final _riderMarkerIcon = BitmapDescriptor.fromBytes(
      await getBytesFromAsset(
        'assets/images/markers/marker-rider.png',
        70,
      ),
    );

    final riderMarkerId = MarkerId('rider');

    final riderMarker = Marker(
      markerId: riderMarkerId,
      position: LatLng(lat, lng),
      icon: _riderMarkerIcon,
    );

    setState(() {
      _markers[riderMarkerId] = riderMarker;
    });
  }

  _addRequestMarkers() async {
    var originMarkerPath =
        'assets/images/markers/marker-${_consumerRequest.type == 'errand' ? 'store' : 'user'}.png';
    var destinationMarkerPath = 'assets/images/markers/marker-dest.png';

    final _originMarkerIcon = BitmapDescriptor.fromBytes(
      await getBytesFromAsset(
        originMarkerPath,
        70,
      ),
    );

    final originMarkerId = MarkerId('origin');

    final originMarker = Marker(
      markerId: originMarkerId,
      position: LatLng(
          _consumerRequest.pickUpLatLng[0], _consumerRequest.pickUpLatLng[1]),
      icon: _originMarkerIcon,
    );

    final destinationMarkerId = MarkerId('destination');

    final _destinationMarkerIcon = BitmapDescriptor.fromBytes(
      await getBytesFromAsset(
        destinationMarkerPath,
        70,
      ),
    );

    final destinationMarker = Marker(
      markerId: destinationMarkerId,
      position: LatLng(
          _consumerRequest.dropOffLatLng[0], _consumerRequest.dropOffLatLng[1]),
      icon: _destinationMarkerIcon,
    );

    setState(() {
      _markers[originMarkerId] = originMarker;
      _markers[destinationMarkerId] = destinationMarker;
    });
    _setCameraPosition();
  }

  _setCameraPosition() {
    _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(
      getCurrentBounds(_markers[MarkerId('origin')].position,
          _markers[MarkerId('destination')].position),
      30,
    ));
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Container buildInfoItem({
    String label,
    String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 10.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white54),
          ),
          SizedBox(height: 3.0),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  _onMapCreated(controller) {
    _googleMapController = controller;
    _addRequestMarkers();
  }
}

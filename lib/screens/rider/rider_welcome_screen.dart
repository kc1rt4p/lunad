import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lunad/data/bloc/auth/auth_bloc.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/data/models/delivery_information.dart';
import 'package:lunad/data/models/errand_information.dart';
import 'package:lunad/data/models/rider.dart';
import 'package:lunad/screens/rider/bloc/rider_request_bloc.dart';
import 'package:lunad/screens/rider/rider_earnings_screen.dart';
import 'package:lunad/screens/rider/rider_history_screen.dart';
import 'package:lunad/screens/profile_screen.dart';
import 'package:lunad/services/file_service.dart';
import 'package:lunad/services/location_service.dart';
import 'package:lunad/services/notification_service.dart';

import 'package:lunad/widgets/filled_button.dart';
import 'package:lunad/widgets/item_list_dialog.dart';
import 'package:lunad/widgets/styled_icon_button.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RiderWelcomeScreen extends StatefulWidget {
  final Rider rider;

  const RiderWelcomeScreen({Key key, this.rider}) : super(key: key);

  @override
  _RiderWelcomeScreenState createState() => _RiderWelcomeScreenState();
}

class _RiderWelcomeScreenState extends State<RiderWelcomeScreen>
    with WidgetsBindingObserver {
  GoogleMapController _googleMapController;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Rider _rider;
  int acceptTimer = 0;
  Timer _timer;
  ConsumerRequest _request;

  StreamSubscription<Position> positionStream;

  AppLifecycleState _notification;

  bool isAvailable = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
  }

  @override
  void initState() {
    _rider = widget.rider;
    setState(() {
      isAvailable = _rider.isAvailable ?? false;
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    positionStream?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider<RiderRequestBloc>(
      create: (context) => RiderRequestBloc()..add(WaitForRequest(_rider.id)),
      child: Scaffold(
        appBar: AppBar(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Builder(
                builder: (context) => buildIconButton(
                  icon: Icons.menu,
                  tooltip: 'Show menu',
                  onTap: () => _openDrawer(context),
                ),
              ),
            ],
          ),
          centerTitle: true,
          title: Container(
            width: screenWidth * .4,
            child: Image.asset(
              'assets/images/lunad-banner.png',
              color: Colors.white,
            ),
          ),
          actions: [
            // Switch(
            //   activeColor: Colors.green.shade600,
            //   value: isAvailable,
            //   onChanged: (val) {
            //     BlocProvider.of<RiderRequestBloc>(context)
            //         .add(UpdateRiderAvailability(_rider.id, val));
            //     setState(() => isAvailable = val);
            //   },
            // ),
          ],
        ),
        body: BlocListener<RiderRequestBloc, RiderRequestState>(
          listener: (context, state) async {
            // listen to rider request states
            if (state is CompletedDeliveryRequest) {
              showCompletedDeliveryDialog(
                context,
                state.request,
                state.deliveryInfo,
              ).show();

              setState(() {
                _markers.clear();
              });
            }

            if (state is CompletedErrandRequest) {
              showCompletedErrandDialog(
                context,
                state.request,
                state.errandInfo,
              ).show();

              setState(() {
                _markers.clear();
              });
            }

            if (state is LoadedAssignedRequest) {
              if (_notification == AppLifecycleState.paused ||
                  _notification == AppLifecycleState.inactive) {
                await NotificationService()
                    .showAssignedNotification(state.request);
                buildRequestAlert(context, state.request);
              }

              if (_notification == AppLifecycleState.resumed ||
                  _notification == null) {
                buildRequestAlert(context, state.request);
              }
            }

            if (state is RejectedAssignedRequest) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'You have rejected the assigned request, waiting for a new one',
                    style: TextStyle(
                      color: Colors.red.shade900,
                    ),
                  ),
                  backgroundColor: Colors.white,
                ),
              );
            }

            if (state is AcceptedErrandRequest) {
              final request = state.request;
              setState(() {
                _request = request;
              });
              _addRequestMarkers(
                'store',
                request.pickUpLatLng[0],
                request.pickUpLatLng[1],
              );

              _addRequestMarkers(
                'dropoff',
                request.dropOffLatLng[0],
                request.dropOffLatLng[1],
              );

              _updateMapBounds(
                LatLng(
                  request.pickUpLatLng[0],
                  request.pickUpLatLng[1],
                ),
                LatLng(
                  request.dropOffLatLng[0],
                  request.dropOffLatLng[1],
                ),
              );
            }

            if (state is AcceptedDeliveryRequest) {
              final request = state.request;
              setState(() {
                _request = request;
              });
              _addRequestMarkers(
                'pickup',
                request.pickUpLatLng[0],
                request.pickUpLatLng[1],
              );

              _addRequestMarkers(
                'dropoff',
                request.dropOffLatLng[0],
                request.dropOffLatLng[1],
              );

              _updateMapBounds(
                LatLng(
                  request.pickUpLatLng[0],
                  request.pickUpLatLng[1],
                ),
                LatLng(
                  request.dropOffLatLng[0],
                  request.dropOffLatLng[1],
                ),
              );
            }
          },
          child: Container(
            height: screenHeight,
            color: Colors.red.shade600,
            child: Column(
              children: [
                Container(
                  height: screenHeight * .4,
                  color: Colors.grey,
                  child: Builder(
                    builder: (context) {
                      return GoogleMap(
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(13.6407274, 123.2354445),
                          zoom: 17,
                        ),
                        onMapCreated: (controller) =>
                            _onMapCreated(controller, context),
                        markers: Set<Marker>.of(_markers.values),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: BlocBuilder<RiderRequestBloc, RiderRequestState>(
                    builder: (context, state) {
                      if (state is AcceptingRequest ||
                          state is UpdatingRequest ||
                          state is CompletingRequest) {
                        return buildAcceptingRequest(context);
                      }

                      if (state is AcceptedDeliveryRequest) {
                        return buildAcceptedDeliveryRequest(
                          context,
                          state.request,
                          state.deliveryInformation,
                        );
                      }

                      if (state is LoadedExistingDeliveryRequest) {
                        return buildAcceptedDeliveryRequest(
                          context,
                          state.request,
                          state.deliveryInformation,
                        );
                      }

                      if (state is AcceptedErrandRequest) {
                        return buildAcceptedErrandRequest(
                          context,
                          state.request,
                          state.errandInformation,
                          state.itemsToPurchase,
                        );
                      }

                      if (state is LoadedExistingErrandRequest) {
                        return buildAcceptedErrandRequest(
                          context,
                          state.request,
                          state.errandInforation,
                          state.itemsToPurchase,
                        );
                      }

                      return buildWaitingForRequest(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                ),
                child: SizedBox(
                  child: Image.asset(
                    'assets/images/logo_white.png',
                    width: 35.0,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        user: _rider,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.payments),
                title: Text('My Earnings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RiderEarningsScreen(
                        rider: _rider,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('Job History'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RiderHistoryScreen(
                        rider: _rider,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () => _handleLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Alert showCompletedErrandDialog(BuildContext context, ConsumerRequest request,
      ErrandInformation errandInfo) {
    final totalDuration = request.dateCompleted
        .toDate()
        .difference(request.dateAccepted.toDate());
    return Alert(
      context: context,
      title: 'Congratulations',
      desc: 'You have completed a job!',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 15.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${totalDuration.inMinutes}mins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Duration',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${request.totalDistance.toStringAsFixed(2)}km',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Distance',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'PABILI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Job Type',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '₱${errandInfo.totalFee.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Amount Collected',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      buttons: [
        DialogButton(
          color: Colors.red.shade600,
          child: Text(
            'OK',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      style: AlertStyle(
        isCloseButton: false,
        buttonAreaPadding: EdgeInsets.all(10.0),
        alertPadding: EdgeInsets.all(10.0),
      ),
    );
  }

  Alert showCompletedDeliveryDialog(
    BuildContext context,
    ConsumerRequest request,
    DeliveryInformation deliveryInfo,
  ) {
    final totalDuration = request.dateCompleted
        .toDate()
        .difference(request.dateAccepted.toDate());
    return Alert(
      context: context,
      title: 'Congratulations',
      desc: 'You have completed a delivery job!',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 15.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${totalDuration.inMinutes}mins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Duration',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${request.totalDistance.toStringAsFixed(2)}km',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Distance',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'PADELIVER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Job Type',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '₱${deliveryInfo.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Amount Collected',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      buttons: [
        DialogButton(
          color: Colors.red.shade600,
          child: Text(
            'OK',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      style: AlertStyle(
        isCloseButton: false,
        buttonAreaPadding: EdgeInsets.all(10.0),
        alertPadding: EdgeInsets.all(10.0),
      ),
    );
  }

  buildAcceptingRequest(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.red.shade600,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: HeartbeatProgressIndicator(
                child: Image.asset(
                  'assets/images/logo_white.png',
                  width: 60.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildRequestAlert(BuildContext parentContext, ConsumerRequest request) {
    StreamController<int> dialogTimer;

    BuildContext dialogContext;
    dialogTimer = new StreamController<int>();
    dialogTimer.add(30);
    var _counter = 30;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        _counter--;
        dialogTimer.add(_counter);
      } else {
        _timer.cancel();
        Navigator.pop(dialogContext);
        _rejectRequest(parentContext, request.id);
        setState(() {
          _counter = 30;
        });
      }
    });

    showDialog(
      barrierDismissible: false,
      context: parentContext,
      builder: (context) {
        dialogContext = context;
        return StreamBuilder<int>(
          stream: dialogTimer.stream,
          builder: (context, snapshot) {
            return AlertDialog(
              title: Text(
                'Job Information',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.red.shade600,
              contentPadding: EdgeInsets.all(10.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            request.type.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Service Type',
                            style: TextStyle(
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(
                            '${request.totalDistance.toStringAsFixed(2) ?? 0}km',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Total Distance',
                            style: TextStyle(
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text(
                      request.pickUpAddress,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${request.type == 'errand' ? 'Store Location' : 'Pick-up Address'}',
                      style: TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      request.dropOffAddress,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Drop-off Address',
                      style: TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * .8,
                    child: buildFilledButton(
                      label: 'ACCEPT JOB (${_counter.toString()})',
                      onPressed: () {
                        _acceptAssignedRequest(parentContext, request.id);
                        Navigator.pop(dialogContext);
                        _timer.cancel();
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  _acceptAssignedRequest(BuildContext context, String requestId) {
    BlocProvider.of<RiderRequestBloc>(context)
        .add(AcceptAssignedRequest(requestId, _rider.id));
  }

  _rejectRequest(BuildContext context, String requestId) {
    BlocProvider.of<RiderRequestBloc>(context)
        .add(RejectAssignedRequest(requestId));
  }

  buildAcceptedDeliveryRequest(BuildContext context, ConsumerRequest request,
      DeliveryInformation deliveryInfo) {
    return Container(
      color: Colors.red.shade600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JOB INFORMATION (PADELIVER)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      buildJobInstruction(context, request),
                    ],
                  ),
                ),
                Text(
                  '₱${request.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  buildLocationItem(
                    imagePath: 'assets/images/markers/marker-user.png',
                    label: 'Pick-up Address',
                    value: request.pickUpAddress,
                  ),
                  Divider(color: Colors.black54),
                  buildLocationItem(
                    imagePath: 'assets/images/markers/marker-dest.png',
                    label: 'Drop-off Address',
                    value: request.dropOffAddress,
                  ),
                  Divider(color: Colors.black54),
                  // buildInfoItem(
                  //   icon: FaIcon(
                  //     FontAwesomeIcons.receipt,
                  //     size: 20.0,
                  //   ),
                  //   label: 'Total Amount',
                  //   value: '₱${deliveryInfo.totalAmount.toStringAsFixed(2)}',
                  // ),
                  // Divider(color: Colors.black54),
                  Row(
                    children: [
                      Expanded(
                        child: buildInfoItem(
                          icon: FaIcon(
                            FontAwesomeIcons.user,
                            size: 20.0,
                          ),
                          label: 'Receiver\'s Name',
                          value: deliveryInfo.receiverName,
                        ),
                      ),
                      Expanded(
                        child: buildInfoItem(
                          icon: FaIcon(
                            FontAwesomeIcons.phone,
                            size: 20.0,
                          ),
                          label: 'Phone Number',
                          value: deliveryInfo.receiverPhoneNumber,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.black54),
                  buildInfoItem(
                    icon: FaIcon(
                      FontAwesomeIcons.stickyNote,
                      size: 20.0,
                    ),
                    label: 'Remarks',
                    value: deliveryInfo.deliveryRemarks,
                  ),
                  Divider(color: Colors.black54),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: buildUpdateButton(context, request),
          ),
        ],
      ),
    );
  }

  Row buildInfoItem({Widget icon, String label, String value}) {
    return Row(
      children: [
        icon,
        SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }

  Row buildLocationItem({String imagePath, String label, String value}) {
    return Row(
      children: [
        Image.asset(
          imagePath,
          width: 15.0,
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.black54,
                ),
              ),
              Text(
                value,
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildJobInstruction(BuildContext context, ConsumerRequest request) {
    final status = request.status;
    var instruction;
    switch (status) {
      case 'intransitpickup':
        instruction =
            'Go to ${request.type == 'delivery' ? 'pick-up' : 'store'} location';
        break;
      case 'intransitdropoff':
        instruction = 'Go to drop-off location';
        break;
      case 'arriveddropoff':
        instruction =
            '${request.type == 'errand' ? 'Collect amount from receipt and service fee' : 'Give item and collect payment'}';
        break;
      case 'arrivedpickup':
        instruction = request.type == 'delivery'
            ? 'Call the sender, ask for exact location'
            : 'Buy items to purchase in store';
        break;
      default:
        instruction =
            'Update ${request.type == 'delivery' ? 'sender' : 'customer'} that you\'re on your way';
        break;
    }
    return Text(
      instruction,
      style: TextStyle(
        color: Colors.white60,
        fontSize: 14.0,
      ),
    );
  }

  buildUpdateButton(BuildContext pcontext, ConsumerRequest request) {
    final status = request.status;
    var label;
    switch (status) {
      case 'intransitpickup':
        label = 'ARRIVED: ${request.type == 'delivery' ? 'PICK-UP' : 'STORE'}';
        break;
      case 'arrivedpickup':
        label = 'IN TRANSIT: DROP OFF';
        break;
      case 'intransitdropoff':
        label = 'ARRIVED: DROP-OFF';
        break;
      case 'arriveddropoff':
        label = 'COMPLETED';
        break;
      default:
        label =
            'IN TRANSIT: ${request.type == 'delivery' ? 'PICK-UP' : 'STORE'}';
        break;
    }
    return buildFilledButton(
      label: 'UPDATE - $label',
      onPressed: () => _promptUpdate(pcontext, request),
    );
  }

  _promptUpdate(BuildContext parentContext, ConsumerRequest request) {
    String desc;

    switch (request.status) {
      case 'intransitpickup':
        desc =
            'Updating job status to: Arrived at ${request.type == 'errand' ? 'store' : 'pick-up'}';
        break;
      case 'arrivedpickup':
        desc =
            'Updating job status to: In transit to ${request.type == 'errand' ? 'receiver' : 'drop-off'}';
        break;
      case 'intransitdropoff':
        desc =
            'Updating job status to: Arrived at ${request.type == 'errand' ? 'receiver\'s location' : 'drop-off'}';
        break;
      case 'arriveddropoff':
        desc = 'Updating job status to: Job completed - amount collected';
        break;
      default:
        desc =
            'Updating job status to: In transit to ${request.type == 'errand' ? 'store' : 'pick-up'}';
        break;
    }

    Alert(
      context: parentContext,
      title: 'Job Update',
      desc: desc + '\nDo you want to continue?',
      type: AlertType.info,
      style: AlertStyle(
        isCloseButton: false,
        descStyle: TextStyle(
          fontSize: 14.0,
          color: Colors.black54,
        ),
      ),
      buttons: [
        DialogButton(
          color: Colors.green.shade600,
          child: Text(
            'YES',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            _updateRequest(parentContext, request);
          },
        ),
        DialogButton(
          color: Colors.red.shade600,
          child: Text(
            'NO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ).show();
  }

  _updateRequest(BuildContext parentContext, ConsumerRequest request) {
    final requestBloc = BlocProvider.of<RiderRequestBloc>(parentContext);

    if (request.status == 'placed' || request.status == 'accepted')
      requestBloc.add(UpdateRequest(request.id, 'intransitpickup'));

    if (request.status == 'arrivedpickup')
      requestBloc.add(UpdateRequest(request.id, 'intransitdropoff'));

    if (request.status == 'intransitpickup')
      requestBloc.add(UpdateRequest(request.id, 'arrivedpickup'));

    if (request.status == 'intransitdropoff')
      requestBloc.add(UpdateRequest(request.id, 'arriveddropoff'));

    if (request.status == 'arriveddropoff') {
      requestBloc.add(CompleteAssignedRequest(request.id, _rider.id));
    }
  }

  buildAcceptedErrandRequest(BuildContext context, ConsumerRequest request,
      ErrandInformation errandInfo, List<ErrandItem> items) {
    return Container(
      color: Colors.red.shade600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JOB INFORMATION (PABILI)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      buildJobInstruction(context, request),
                    ],
                  ),
                ),
                SizedBox(width: 5.0),
                Column(
                  children: [
                    Text(
                      '₱${request.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Service Fee',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  buildLocationItem(
                    imagePath: 'assets/images/markers/marker-store.png',
                    label: 'Store Address',
                    value: request.pickUpAddress,
                  ),
                  Divider(color: Colors.black54),
                  buildLocationItem(
                    imagePath: 'assets/images/markers/marker-dest.png',
                    label: 'Drop-off Address',
                    value: request.dropOffAddress,
                  ),
                  Divider(color: Colors.black54),
                  Row(
                    children: [
                      Expanded(
                        child: buildInfoItem(
                          icon: FaIcon(
                            FontAwesomeIcons.userAlt,
                            size: 20.0,
                          ),
                          label: 'Receiver\'s Name',
                          value: errandInfo.receiverName,
                        ),
                      ),
                      Expanded(
                        child: buildInfoItem(
                          icon: FaIcon(
                            FontAwesomeIcons.phone,
                            size: 20.0,
                          ),
                          label: 'Phone Number',
                          value: errandInfo.receriverPhoneNumber,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.black54),
                  Row(
                    children: [
                      Expanded(
                        child: buildInfoItem(
                            icon: FaIcon(
                              FontAwesomeIcons.store,
                              size: 18.0,
                            ),
                            label: 'Store Name',
                            value: errandInfo.storeName),
                      ),
                      Expanded(
                        child: buildInfoItem(
                          icon: FaIcon(
                            FontAwesomeIcons.tag,
                            size: 20.0,
                          ),
                          label: 'Item Description',
                          value: errandInfo.itemDescription,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.black54),
                  buildInfoItem(
                    icon: FaIcon(
                      FontAwesomeIcons.stickyNote,
                      size: 20.0,
                    ),
                    label: 'Remarks',
                    value: errandInfo.remarks,
                  ),
                  Divider(color: Colors.black54),
                  Center(
                    child: GestureDetector(
                      onTap: () => showItemsToPurchase(
                          context, items, errandInfo.storeName),
                      child: Text(
                        'VIEW ITEMS',
                        textScaleFactor: 1.2,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.0),
            child: buildUpdateButton(context, request),
          ),
        ],
      ),
    );
  }

  _updateMapBounds(LatLng pos1, LatLng pos2) {
    _googleMapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        getCurrentBounds(pos1, pos2),
        80,
      ),
    );
  }

  buildWaitingForRequest(context) {
    return Container(
      padding: EdgeInsets.all(18.0),
      color: Colors.red.shade600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${_rider.firstName} ${_rider.lastName}',
            textScaleFactor: 1.1,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
          Text(
            'A job will be assigned to you soon',
            textScaleFactor: 1.3,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Center(
              child: JumpingText(
                'Waiting for dispatcher...',
                style: TextStyle(
                  letterSpacing: 1.2,
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          Text(
            'Please stay alert, you only have 30 seconds to accept a job',
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  _onMapCreated(GoogleMapController controller, BuildContext context) {
    _googleMapController = controller;
    _determineUserPosition(context);
  }

  _determineUserPosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    positionStream = Geolocator.getCurrentPosition().asStream().listen((pos) {
      _addRiderMarker(pos.latitude, pos.longitude);

      if (_markers.length < 1) {
        _updateCameraPosition(pos.latitude, pos.longitude);
      }

      BlocProvider.of<RiderRequestBloc>(context).add(UpdateRiderLocation(
          _request?.id, _rider.id, [pos.latitude, pos.longitude]));
    });
  }

  _updateCameraPosition(double lat, double lng) async {
    await _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 17.0,
        ),
      ),
    );
  }

  _addRequestMarkers(String type, double lat, double lng) async {
    final markerId = MarkerId(type);

    BitmapDescriptor _markerIcon;

    switch (type) {
      case 'pickup':
        _markerIcon = BitmapDescriptor.fromBytes(
          await getBytesFromAsset(
            'assets/images/markers/marker-user.png',
            60,
          ),
        );
        break;
      case 'dropoff':
        _markerIcon = BitmapDescriptor.fromBytes(
          await getBytesFromAsset(
            'assets/images/markers/marker-dest.png',
            60,
          ),
        );
        break;
      default:
        _markerIcon = BitmapDescriptor.fromBytes(
          await getBytesFromAsset(
            'assets/images/markers/marker-store.png',
            60,
          ),
        );
        break;
    }

    final marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      icon: _markerIcon,
      zIndex: 10.0,
      alpha: 0.8,
    );

    setState(() {
      _markers[markerId] = marker;
    });
  }

  _addRiderMarker(double lat, double lng) async {
    final _markerIcon = BitmapDescriptor.fromBytes(
      await getBytesFromAsset(
        'assets/images/markers/marker-rider.png',
        60,
      ),
    );

    final markerId = MarkerId('rider');

    final marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      icon: _markerIcon,
    );

    setState(() {
      _markers[markerId] = marker;
    });
  }

  _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  _handleLogout(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      desc: 'Are you sure you want to logout?',
      title: 'Confirm Logout',
      style: AlertStyle(
        isCloseButton: false,
        backgroundColor: Colors.red.shade600,
        titleStyle: TextStyle(
          color: Colors.white,
        ),
        descStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
          fontSize: 14.0,
        ),
      ),
      buttons: [
        DialogButton(
          child: Text(
            'Yes',
          ),
          onPressed: () {
            BlocProvider.of<AuthBloc>(context).add(SignOutUser());
            Navigator.of(context).pop();
          },
        ),
        DialogButton(
          child: Text(
            'No',
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ).show();
  }
}

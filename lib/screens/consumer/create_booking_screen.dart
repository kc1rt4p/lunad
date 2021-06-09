import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lunad/data/models/consumer_request.dart';
import 'package:lunad/data/models/user.dart';
import 'package:lunad/screens/consumer/bloc/courier_screen_bloc.dart';
import 'package:lunad/screens/consumer/delivery_information_screen.dart';
import 'package:lunad/screens/consumer/errand_information_screen.dart';
import 'package:lunad/screens/consumer/transport_information_screen.dart';
import 'package:lunad/services/file_service.dart';
import 'package:lunad/services/location_service.dart';
import 'package:lunad/widgets/filled_button.dart';
import 'package:lunad/widgets/styled_icon_button.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../search_address_screen.dart';

class CreateBookingScreen extends StatefulWidget {
  final requestType;
  final user;

  const CreateBookingScreen({Key key, this.requestType, this.user})
      : super(key: key);

  @override
  _CreateBookingScreenState createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  String requestType;
  DateTime pickUpDate;
  Position _currentUserPosition;
  GoogleMapController _googleMapController;
  String selectedPickUpTime = 'ASAP';
  DateTime selectedPickUpDateTime;

  User _user;

  LatLng pickUpLatLng;
  LatLng dropOffLatLng;

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  bool _selectingOrigin = false;
  bool _selectingDestination = false;

  String originAddress;
  String destinationAddress;

  @override
  void initState() {
    requestType = widget.requestType;
    _user = widget.user;
    _setMapCameraToUserPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: BlocProvider<CourierScreenBloc>(
        create: (context) => CourierScreenBloc(),
        child: BlocListener<CourierScreenBloc, CourierScreenState>(
          listener: (context, state) {
            if (state is CourierScreenError) {
              Alert(
                context: context,
                type: AlertType.error,
                title: 'Request Error',
                desc: state.message,
                style: AlertStyle(
                  isCloseButton: false,
                ),
                buttons: [
                  DialogButton(
                    child: Text(
                      'OK',
                      style:
                          TextStyle(color: Colors.red.shade600, fontSize: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                    width: 120,
                  ),
                ],
              ).show();
            }
          },
          child: Builder(
              builder: (context) => buildInitial(
                  screenHeight, screenWidth, statusBarHeight, context)),
        ),
      ),
    );
  }

  Container buildInitial(double screenHeight, double screenWidth,
      double statusBarHeight, BuildContext context) {
    return Container(
      color: Colors.white,
      height: screenHeight,
      width: screenWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                color: Colors.red.shade600,
                height: statusBarHeight * 4,
                width: screenWidth,
                padding: EdgeInsets.fromLTRB(10.0, statusBarHeight, 10.0, 10.0),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey.shade300,
                  width: double.infinity,
                  child: GoogleMap(
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(13.6407274, 123.2354445),
                      zoom: 17,
                    ),
                    onMapCreated: _onMapCreated,
                    markers: Set<Marker>.of(_markers.values),
                    onTap: (latLng) => _onMapTapped(context, latLng),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: statusBarHeight + 10,
            left: 15,
            child: buildIconButton(
              onTap: () {
                Navigator.pop(context);
              },
              icon: FontAwesomeIcons.angleLeft,
              tooltip: 'Menu',
            ),
          ),
          Positioned(
            top: statusBarHeight + 10,
            child: Container(
              width: screenWidth * .4,
              child: Image.asset(
                'assets/images/lunad-banner.png',
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: statusBarHeight + 70,
            child: Column(
              children: [
                Visibility(
                  visible: requestType == 'delivery',
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                    ),
                    width: screenWidth * .95,
                    child: GestureDetector(
                      onTap: () => _onPickUpTimeTapped(context),
                      child: Row(
                        children: [
                          Text('Pick-up Time:'),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Text(
                              selectedPickUpTime == 'ASAP'
                                  ? 'ASAP'
                                  : DateFormat.yMEd()
                                      .add_jms()
                                      .format(selectedPickUpDateTime),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black26,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectingOrigin = true;
                            _selectingDestination = false;
                          });
                          _selectAddress(context, 'pickup');
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          width: screenWidth * .95,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                            ),
                            border: _selectingOrigin
                                ? Border.all(
                                    color: Colors.yellow.shade600,
                                    width: 2.5,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32.0,
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 10.0),
                                child: Image.asset(
                                    'assets/images/markers/marker-${requestType != 'errand' ? 'user' : 'store'}.png'),
                              ),
                              SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      requestType != 'errand'
                                          ? 'Pick-up'
                                          : 'Store Location',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    _selectingOrigin == false
                                        ? Text(
                                            originAddress ??
                                                'Tap here to select ${requestType != 'errand' ? 'pick-up' : 'store'} location',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey.shade600,
                                            ),
                                          )
                                        : Text(
                                            originAddress ??
                                                'Tap exact location from map',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectingOrigin = false;
                            _selectingDestination = true;
                          });
                          _selectAddress(context, 'dropoff');
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          width: screenWidth * .95,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                            ),
                            border: _selectingDestination
                                ? Border.all(
                                    color: Colors.green.shade600,
                                    width: 2.5,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 31.0,
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 10.0),
                                child: Image.asset(
                                    'assets/images/markers/marker-dest.png'),
                              ),
                              SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Drop-off',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    !_selectingDestination
                                        ? Text(
                                            destinationAddress ??
                                                'Tap here to select drop-off location',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey.shade600,
                                            ),
                                          )
                                        : Text(
                                            'Tap exact location from map',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: requestType == 'errand',
            child: Positioned(
              bottom: 10,
              child: Container(
                width: screenWidth * .85,
                child: buildFilledButton(
                  label: 'Errand Details',
                  onPressed: () => _onDetailsTapped(context),
                ),
              ),
            ),
          ),
          Visibility(
            visible: requestType == 'delivery',
            child: Positioned(
              bottom: 10,
              child: Container(
                width: screenWidth * .85,
                child: buildFilledButton(
                  label: 'Delivery Details',
                  onPressed: () => _onDetailsTapped(context),
                ),
              ),
            ),
          ),
          Visibility(
            visible: requestType == 'transport',
            child: Positioned(
              bottom: 10,
              child: Container(
                width: screenWidth * .85,
                child: buildFilledButton(
                  label: 'Transport Details',
                  onPressed: () => _onDetailsTapped(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onDetailsTapped(BuildContext context) {
    final _courierScreenBloc = BlocProvider.of<CourierScreenBloc>(context);

    if (originAddress == null || destinationAddress == null) {
      _courierScreenBloc.add(ShowError(
          'Select ${requestType == 'errand' ? 'store' : 'pick-up'} or drop-off location'));
      return;
    }

    final consumerRequest = ConsumerRequest(
      type: requestType,
      pickUpAddress: originAddress,
      pickUpLatLng: [pickUpLatLng.latitude, pickUpLatLng.longitude],
      dropOffAddress: destinationAddress,
      dropOffLatLng: [dropOffLatLng.latitude, dropOffLatLng.longitude],
      consumerId: _user.id,
      consumerName: '${_user.firstName} ${_user.lastName}',
      pickUpDate: selectedPickUpTime != 'ASAP'
          ? Timestamp.fromDate(selectedPickUpDateTime)
          : null,
      totalDistance: Geolocator.distanceBetween(
            pickUpLatLng.latitude,
            pickUpLatLng.longitude,
            dropOffLatLng.latitude,
            dropOffLatLng.longitude,
          ) /
          1000,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          switch (requestType) {
            case 'delivery':
              return DeliveryInformationScreen(
                consumerRequest: consumerRequest,
              );
              break;
            case 'errand':
              return ErrandInformationScreen(
                consumerRequest: consumerRequest,
              );
              break;
            default:
              return TransportInformationScreen(
                consumerRequest: consumerRequest,
              );
              break;
          }
        },
      ),
    );
  }

  _onPickUpTimeTapped(BuildContext context) {
    Alert(
      context: context,
      title: 'Pick-up Time',
      style: AlertStyle(
        backgroundColor: Colors.red.shade600,
        titleStyle: TextStyle(
          color: Colors.white,
        ),
        isCloseButton: false,
        titleTextAlign: TextAlign.left,
        isOverlayTapDismiss: false,
        isButtonVisible: true,
        buttonsDirection: ButtonsDirection.column,
      ),
      buttons: [
        DialogButton(
          child: Text(
            'ASAP',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              selectedPickUpTime = 'ASAP';
            });
          },
        ),
        DialogButton(
          child: Text(
            'SELECT DATE/TIME',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          color: Colors.white,
          onPressed: () async {
            Navigator.pop(context);

            await _onSelectDateTimeTapped(context);
          },
        ),
        DialogButton(
          child: Text(
            'CANCEL',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.red.shade600,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ).show();
  }

  _onSelectDateTimeTapped(BuildContext context) async {
    final selectedDateTime = await DatePicker.showDateTimePicker(
      context,
      minTime: DateTime.now(),
      currentTime: DateTime.now(),
    );

    if (selectedDateTime == null) {
      setState(() {
        selectedPickUpTime = 'ASAP';
      });
      return;
    }

    setState(() {
      selectedPickUpDateTime = selectedDateTime;
      selectedPickUpTime = 'selectDateTime';
    });
  }

  _onMapTapped(BuildContext context, LatLng latLng) async {
    final _courierScreenBloc = BlocProvider.of<CourierScreenBloc>(context);

    if (!_selectingDestination && !_selectingOrigin) {
      _courierScreenBloc.add(ShowError(requestType == 'errand'
          ? 'Tap on either Store Location or Drop-off to select location'
          : 'Tap on either Pick-up or Drop-off to select location'));
    }

    if (_selectingOrigin) {
      final originPlace = await _getLatLngPlace(latLng);
      _addMarker('origin', latLng);
      setState(() {
        originAddress =
            '${originPlace.street}, ${originPlace.subAdministrativeArea}, ${originPlace.administrativeArea}';
      });
    }

    if (_selectingDestination) {
      final destinationPlace = await _getLatLngPlace(latLng);
      _addMarker('dest', latLng);

      setState(() {
        destinationAddress =
            '${destinationPlace.street}, ${destinationPlace.subAdministrativeArea}, ${destinationPlace.administrativeArea}';
      });
    }

    setState(() {
      _selectingDestination = false;
      _selectingOrigin = false;
    });
  }

  _selectAddress(BuildContext context, String locationType) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchAddressScreen(_currentUserPosition),
      ),
    );

    if (result != null) {
      await _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              result['latLng'].latitude,
              result['latLng'].longitude,
            ),
            zoom: 17.0,
          ),
        ),
      );
    }
  }

  Future<Placemark> _getLatLngPlace(LatLng latLng) async {
    final places = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );

    if (places.isNotEmpty)
      return places[0];
    else
      return null;
  }

  _setMapCameraToUserPosition() async {
    final position = await _determineUserPosition();

    if (position == null) return;

    setState(() {
      _currentUserPosition = position;
    });

    await _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 17.0,
        ),
      ),
    );

    if (_markers.isEmpty) {
      final originPlacemark =
          await _getLatLngPlace(LatLng(position.latitude, position.longitude));
      final address =
          '${originPlacemark.street}, ${originPlacemark.subAdministrativeArea}, ${originPlacemark.administrativeArea}';
      setState(() {
        if (requestType != 'errand') {
          _addMarker('origin', LatLng(position.latitude, position.longitude));
          originAddress = address;
        } else {
          _addMarker('dest', LatLng(position.latitude, position.longitude));
          destinationAddress = address;
        }
      });
    }
  }

  _addMarker(String locationType, LatLng latLng) async {
    var markerIconPath =
        'assets/images/markers/marker-${locationType == 'origin' ? 'user' : 'dest'}.png';

    if (requestType == 'errand') {
      if (locationType == 'origin') {
        markerIconPath = 'assets/images/markers/marker-store.png';
      }
    }

    final _markerIcon = BitmapDescriptor.fromBytes(
      await getBytesFromAsset(
        markerIconPath,
        70,
      ),
    );

    final markerId = MarkerId(locationType);

    final marker = Marker(
      markerId: markerId,
      position: latLng,
      icon: _markerIcon,
    );

    setState(() {
      _markers[markerId] = marker;
      if (locationType == 'origin') {
        pickUpLatLng = latLng;
      } else {
        dropOffLatLng = latLng;
      }
    });

    if (_markers.length > 1) {
      _googleMapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          getCurrentBounds(_markers[MarkerId('origin')].position,
              _markers[MarkerId('dest')].position),
          100,
        ),
      );
    }
  }

  Future<Position> _determineUserPosition() async {
    try {
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
        Alert(
          title: 'Location Disabled',
          context: context,
          type: AlertType.error,
          desc:
              'Please allow app to use your location to have better experience',
          style: AlertStyle(
            buttonAreaPadding: EdgeInsets.zero,
          ),
        ).show();
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('just happened: ${e.toString()}');
      return null;
    }
  }

  _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lunad/services/mapbox_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mapbox_api/mapbox_api.dart';

class SearchAddressScreen extends StatefulWidget {
  final Position currentUserPosition;
  SearchAddressScreen(this.currentUserPosition);
  @override
  _SearchAddressScreenState createState() => _SearchAddressScreenState();
}

class _SearchAddressScreenState extends State<SearchAddressScreen> {
  final autoCompleteController = TextEditingController();
  List<GeocoderFeature> result;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng userLatLng = widget.currentUserPosition != null
        ? LatLng(widget.currentUserPosition.latitude,
            widget.currentUserPosition.longitude)
        : null;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: TextFormField(
          cursorColor: Colors.white,
          controller: autoCompleteController,
          onEditingComplete: () => _onSearchTapped(userLatLng),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search location',
            hintStyle: TextStyle(
              color: Colors.white60,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.searchLocation,
              color: Colors.white,
            ),
            onPressed: () => _onSearchTapped(userLatLng),
          ),
        ],
      ),
      body: Container(
        height: screenHeight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          shrinkWrap: true,
          children: result != null
              ? result.isNotEmpty
                  ? result.map((feature) {
                      return ListTile(
                        title: Text(feature.placeName ?? ''),
                        onTap: () => _onAddressTap(feature),
                      );
                    }).toList()
                  : [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            'No address matched your search query',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 1.1,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ]
              : [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        'You can go back, tap the exact location on the map or search the address here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 1.1,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  _onSearchTapped(LatLng userLatLng) async {
    final query = autoCompleteController.text.trim();
    if (query.isEmpty) return;
    MapBoxService _mapBoxService = MapBoxService();
    result = await _mapBoxService.findPlaces(
      query,
      userLatLng != null ? [userLatLng.latitude, userLatLng.longitude] : null,
    );
    setState(() {});
  }

  _onAddressTap(GeocoderFeature feature) {
    print(feature.geometry.coordinates);
    Navigator.pop(context, {
      'address': feature.placeName,
      'latLng': LatLng(
        feature.geometry.coordinates[1],
        feature.geometry.coordinates[0],
      ),
    });
  }
}

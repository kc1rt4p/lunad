import 'package:mapbox_api/mapbox_api.dart';

class MapBoxService {
  MapboxApi _mapbox = MapboxApi(
      accessToken:
          'pk.eyJ1IjoibHVuYWQtZGV2IiwiYSI6ImNrb3I5c3NveTByeTAyb2todGcyemx4MzgifQ.PXrSi-aOBANvt4gScRlyOQ');

  Future<List<GeocoderFeature>> findPlaces(
      String query, List<double> proximity) async {
    final res = await _mapbox.forwardGeocoding.request(
      searchText: query,
      language: 'en',
      country: ['ph'],
      proximity: proximity ?? [13.6403192, 123.24065104861],
      autocomplete: true,
      limit: 10,
      types: [
        GeocoderPlaceType.POI,
        GeocoderPlaceType.ADDRESS,
        GeocoderPlaceType.NEIGHBORHOOD,
        GeocoderPlaceType.PLACE,
        GeocoderPlaceType.LOCALITY,
      ],
    );

    return res.features;
  }

  Future<List<NavigationWaypoint>> getRoute(
      List<double> originLatLng, List<double> destinationLatLng) async {
    final res = await _mapbox.directions.request(
        profile: NavigationProfile.DRIVING_TRAFFIC,
        overview: NavigationOverview.NONE,
        geometries: NavigationGeometries.POLYLINE,
        steps: true,
        coordinates: [
          originLatLng,
          destinationLatLng,
        ]);

    if (res.error == null) {
      print('error getting route: ${res.error.toString()}');
      return [];
    } else {
      return res.waypoints;
    }
  }
}

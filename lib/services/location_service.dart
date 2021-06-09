import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

double getBoundsZoomLevel(LatLngBounds bounds, Size mapDimensions) {
  var worldDimension = Size(1024, 1024);

  double latRad(lat) {
    var sinValue = sin(lat * pi / 180);
    var radX2 = log((1 + sinValue) / (1 - sinValue)) / 2;
    return max(min(radX2, pi), -pi) / 2;
  }

  double zoom(mapPx, worldPx, fraction) {
    return (log(mapPx / worldPx / fraction) / ln2).floorToDouble();
  }

  var ne = bounds.northeast;
  var sw = bounds.southwest;

  var latFraction = (latRad(ne.latitude) - latRad(sw.latitude)) / pi;

  var lngDiff = ne.longitude - sw.longitude;
  var lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;

  var latZoom = zoom(mapDimensions.height, worldDimension.height, latFraction);
  var lngZoom = zoom(mapDimensions.width, worldDimension.width, lngFraction);

  if (latZoom < 0) return lngZoom;
  if (lngZoom < 0) return latZoom;

  return min(latZoom, lngZoom);
}

LatLng getCentralLatlng(List<LatLng> geoCoordinates) {
  if (geoCoordinates.length == 1) {
    return geoCoordinates.first;
  }

  double x = 0;
  double y = 0;
  double z = 0;

  for (var geoCoordinate in geoCoordinates) {
    var latitude = geoCoordinate.latitude * pi / 180;
    var longitude = geoCoordinate.longitude * pi / 180;

    x += cos(latitude) * cos(longitude);
    y += cos(latitude) * sin(longitude);
    z += sin(latitude);
  }

  var total = geoCoordinates.length;

  x = x / total;
  y = y / total;
  z = z / total;

  var centralLongitude = atan2(y, x);
  var centralSquareRoot = sqrt(x * x + y * y);
  var centralLatitude = atan2(z, centralSquareRoot);

  return LatLng(centralLatitude * 180 / pi, centralLongitude * 180 / pi);
}

LatLngBounds getCurrentBounds(LatLng position1, LatLng position2) {
  double _southWestLat;
  double _southWestLong;
  double _northEastLat;
  double _northEastLong;

  if (position1.latitude <= position2.latitude) {
    _southWestLat = position1.latitude;
    _northEastLat = position2.latitude;
  } else {
    _northEastLat = position1.latitude;
    _southWestLat = position2.latitude;
  }

  if (position1.longitude <= position2.longitude) {
    _southWestLong = position1.longitude;
    _northEastLong = position2.longitude;
  } else {
    _northEastLong = position1.longitude;
    _southWestLong = position2.longitude;
  }

  return LatLngBounds(
    southwest: LatLng(_southWestLat, _southWestLong),
    northeast: LatLng(_northEastLat, _northEastLong),
  );
}

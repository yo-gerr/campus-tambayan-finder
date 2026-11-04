import 'place.dart';

Uri? googleMapsDirectionsUri(Place place) {
  if (!place.locationVerified) return null;
  final coordinates = place.coordinates;
  if (coordinates == null) return null;

  return Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '${coordinates.latitude},${coordinates.longitude}',
  });
}

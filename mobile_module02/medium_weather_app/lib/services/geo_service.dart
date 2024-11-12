import 'package:geolocator/geolocator.dart';

class GeoService {
  Future<Position> fetchPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
          'Geolocation is not available, please enable it in your App settings');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(
            'Geolocation is not available, please enable it in your App settings');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Geolocation is not available, please enable it in your App settings');
    }
    return await Geolocator.getCurrentPosition();
  }
}

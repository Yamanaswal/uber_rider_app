import 'package:geolocator/geolocator.dart';

class CommonUtils {
  static Future<Position> getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}

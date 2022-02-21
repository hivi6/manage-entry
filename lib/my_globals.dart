import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:manage_entry/models/vehicleinfo.dart';

class MyGlobals {
  static List<CameraDescription> cameras = [];
  static TextDetector? textDetector;
  static VehicleProvider? vehicleProvider;
  static CloudVehicleProvider? cloudVehicleProvider;
}

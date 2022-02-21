import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:manage_entry/my_globals.dart';

import 'package:manage_entry/screens/homepage.dart';
import 'package:manage_entry/models/vehicleinfo.dart';

Future<void> main() async {
  // initialization
  WidgetsFlutterBinding.ensureInitialized();

  // get all the available cameras
  MyGlobals.cameras = await availableCameras();

  // also initialize the textdetector
  MyGlobals.textDetector = GoogleMlKit.vision.textDetector();

  // initialize the database
  MyGlobals.vehicleProvider = VehicleProvider();
  // open the database
  await MyGlobals.vehicleProvider!.open();

  // initialize firebase app
  await Firebase.initializeApp();

  // initialize cloud data base
  MyGlobals.cloudVehicleProvider = CloudVehicleProvider();
  MyGlobals.cloudVehicleProvider!.databaseReference =
      FirebaseDatabase.instance.reference();
  MyGlobals.cloudVehicleProvider!.firebaseStorage = FirebaseStorage.instance;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

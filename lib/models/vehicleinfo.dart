import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_database/firebase_database.dart';

final String dbVehicle = "vehicle_database.db"; // database name
final String tableName = "vehicles"; // table name
final String columnId = "id"; // id column
final String columnMillisecondsFromEpoch = "millisecondsFromEpoch";
final String columnVehicleNumber = "vehicleNumber";
final String columnImagePath = "imagePath";

// Vehicle Model
class Vehicle {
  final int id;
  final int millisecondsFromEpoch;
  final String vehicleNumber;
  final String imagePath;

  Vehicle({
    required this.id,
    required this.millisecondsFromEpoch,
    required this.vehicleNumber,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      columnId: id,
      columnMillisecondsFromEpoch: millisecondsFromEpoch,
      columnVehicleNumber: vehicleNumber,
      columnImagePath: imagePath,
    };
  }

  @override
  String toString() {
    return 'Vehicle{id: $id, millisecondsFromEpoch: $millisecondsFromEpoch, vehicleNumber: $vehicleNumber, imagePath: $imagePath}';
  }
}

// access the vehicle database(i.e. local database)
class VehicleProvider {
  late Database database;

  Future<void> open() async {
    WidgetsFlutterBinding.ensureInitialized();
    database = await openDatabase(
      join(await getDatabasesPath(), dbVehicle),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY, $columnMillisecondsFromEpoch INTEGER, $columnVehicleNumber TEXT, $columnImagePath TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertVehicle(Vehicle vehicle) async {
    await database.insert(
      tableName,
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Vehicle>> vehicles() async {
    final List<Map<String, dynamic>> maps = await database.query(tableName);

    return List.generate(maps.length, (i) {
      return Vehicle(
        id: maps[i][columnId],
        millisecondsFromEpoch: maps[i][columnMillisecondsFromEpoch],
        vehicleNumber: maps[i][columnVehicleNumber],
        imagePath: maps[i][columnImagePath],
      );
    });
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await database.update(
      tableName,
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<void> deleteVehicle(int id) async {
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class CloudVehicleProvider {
  late DatabaseReference databaseReference;
  late FirebaseStorage firebaseStorage;

  Future<void> insert(Vehicle v) async {
    await databaseReference.child("vehicle${v.id}").set({
      columnMillisecondsFromEpoch: v.millisecondsFromEpoch,
      columnVehicleNumber: v.vehicleNumber,
      columnImagePath: v.imagePath,
    });
  }
}

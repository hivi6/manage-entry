import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:manage_entry/models/vehicleinfo.dart';
import 'package:manage_entry/my_globals.dart';
import 'package:manage_entry/screens/detectionpage.dart';

Future<void> _myResetSystemChrome() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIOverlays([
    SystemUiOverlay.bottom,
    SystemUiOverlay.top,
  ]);
}

// This is the homepage of the app
// This shows information like:
// how many cars came and went,
// do we need to detect a vehicle, etc
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key) {
    _myResetSystemChrome();
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<DataTable> _getDataTable() async {
    List<Vehicle> vehicles = await MyGlobals.vehicleProvider!.vehicles();
    return DataTable(
      showCheckboxColumn: false,
      columns: [
        DataColumn(
          label: Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: Text("Time Stamp"),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: Text("Vechicle number"),
            ),
          ),
        ),
      ],
      rows: vehicles.map((e) {
        DateTime timeStamp =
            DateTime.fromMillisecondsSinceEpoch(e.millisecondsFromEpoch);
        String timeInString =
            "${timeStamp.day}-${timeStamp.month}-${timeStamp.year}\n${timeStamp.hour}:${timeStamp.minute}:${timeStamp.second}";
        return DataRow(
          onSelectChanged: (value) async {
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Image.file(File(e.imagePath)),
                );
              },
            );
          },
          cells: [
            // Time Stamp
            DataCell(
              GestureDetector(
                onLongPress: () async {
                  // prompt before deleting
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        actions: [
                          ElevatedButton(
                            onPressed: () async {
                              await MyGlobals.vehicleProvider!
                                  .deleteVehicle(e.id);
                              Navigator.pop(context);
                            },
                            child: Text("Delete"),
                          ),
                        ],
                        content: Text("Are you sure you want to delete?"),
                      );
                    },
                  );
                  setState(() {});
                },
                child: Text(
                  timeInString,
                  softWrap: true,
                ),
              ),
            ),
            // Vehicle Number Plate
            DataCell(
              Text(
                e.vehicleNumber,
                softWrap: true,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // This is the custom shape in the back ground
          ClipPath(
            clipper: CustomShapeClass(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.green.shade600,
            ),
          ),
          // This is everything above of that shape, all under a safe area
          SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  // Title and Main Icon
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Neepco Logo
                        SvgPicture.asset(
                          "assets/logo/neepco_logo.svg",
                          width: 80,
                          height: 80,
                          color: Colors.red.shade900.withAlpha(100),
                        ),
                        VerticalDivider(
                          width: 20,
                        ),
                        // Title of the App
                        Text(
                          "Vehicle\nManagement",
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // This shows the information of the amount of cars today(testing data)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: 20.0,
                        bottom: 40.0,
                      ),
                      width: double.infinity,
                      height: 450,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green.shade600,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        // The Data Table
                        child: FutureBuilder<DataTable>(
                          future: _getDataTable(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data != null) return snapshot.data!;
                            return CircularProgressIndicator();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Move to the detection page
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetectionPage(),
            ),
          );
          // reset system config, i.e. orientation and stuff
          await _myResetSystemChrome();
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: BottomNavigationBar(
          elevation: 0,
          enableFeedback: true,
          iconSize: 30,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: "More info",
            ),
          ],
        ),
      ),
    );
  }
}

// This is the Custom Clipper for the shape in the background
class CustomShapeClass extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height / 4.25);
    var firstControlPoint = Offset(size.width / 4, size.height / 3);
    var firstEndPoint = Offset(size.width / 2, size.height / 3 - 60);
    var secondControlPoint =
        Offset(size.width - (size.width / 4), size.height / 4 - 65);
    var secondEndPoint = Offset(size.width, size.height / 3 - 40);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height / 3);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

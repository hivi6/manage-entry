import 'dart:math' as math;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:manage_entry/models/vehicleinfo.dart';

import 'package:manage_entry/my_globals.dart';

typedef void CallBack();

_setPageSettings() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  SystemChrome.setEnabledSystemUIOverlays([]);
}

class Camera extends StatefulWidget {
  final bool isManual;
  const Camera(this.isManual, {Key? key}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController? controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    _setPageSettings();
    // check for cameras
    if (MyGlobals.cameras.length < 1)
      print("No Cameras found");
    else {
      // choose the back camera
      controller = CameraController(
        MyGlobals.cameras.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.back,
        ),
        ResolutionPreset.medium,
      );
      // set the camera direction of orrientation
      // now initialize the controller
      // streaming is for only automatic detection
      controller?.initialize().then((value) async {
        if (!mounted) return;
        // TODO: FOR SOME REASON THIS WORKS! IDK WHY??
        await controller!
            .lockCaptureOrientation(DeviceOrientation.landscapeRight);
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !(controller!.value.isInitialized))
      return Container();
    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller!.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return GestureDetector(
      // Nothing is there for now
      onTap: () async {
        // only for manual camera
        if (!widget.isManual) return;
        // get image from camera
        XFile _imgData = await controller!.takePicture();
        // convert to input image
        final inputImage = InputImage.fromFilePath(_imgData.path);
        // get the recognize text
        final RecognisedText recognisedText =
            await MyGlobals.textDetector!.processImage(inputImage);
        print(recognisedText.text);
        // get the bounding box
        Rect rect = Rect.zero;
        TextBlock largestBlock = recognisedText.blocks.first;
        // get the largest block
        for (TextBlock block in recognisedText.blocks) {
          var temp = block.rect;
          var area = temp.width * temp.height;
          if (area > (rect.width * rect.height)) {
            rect = block.rect;
            largestBlock = block;
          }
        }
        // now get the ui image
        final data = await File(_imgData.path).readAsBytes();
        ui.Image uiImage = await decodeImageFromList(data);
        bool _isSaved = false;
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Given Text"),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    // get the timestamp
                    int millisecondsFromEpoch =
                        DateTime.now().millisecondsSinceEpoch;
                    // get vehicle number
                    String vehicleNumber = largestBlock.text;
                    // get the directory
                    Directory directory =
                        await getApplicationDocumentsDirectory();
                    int id = millisecondsFromEpoch; // use time for unique id
                    String path = "${directory.path}/saved_image_$id.png";
                    // Now save the image
                    await _imgData.saveTo(path);
                    // Now create the new vehicle
                    Vehicle v = Vehicle(
                      id: id,
                      millisecondsFromEpoch: millisecondsFromEpoch,
                      vehicleNumber: vehicleNumber,
                      imagePath: path,
                    );
                    // now entry a new vehicle
                    await MyGlobals.vehicleProvider!.insertVehicle(v);
                    // now entry it to the cloud
                    await MyGlobals.cloudVehicleProvider!.insert(v);
                    // Save the image to cloud storage
                    TaskSnapshot snapshot = await MyGlobals
                        .cloudVehicleProvider!.firebaseStorage
                        .ref()
                        .child(path)
                        .putFile(File(path));

                    if (snapshot.state == TaskState.success) {
                      print("Done!!!!!!");
                    }

                    _isSaved = true;
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
              content: Row(
                children: [
                  // Paint the bounding box
                  FittedBox(
                    child: SizedBox(
                      width: uiImage.width.toDouble(),
                      height: uiImage.height.toDouble(),
                      child: CustomPaint(
                        painter: TextPainter(uiImage, rect),
                      ),
                    ),
                  ),
                  // print the recognised text
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      largestBlock.text,
                    ),
                  ),
                ],
              ),
            );
          },
        );
        if (_isSaved) Navigator.pop(context);
      },
      // Show the camera preview
      child: OverflowBox(
        maxHeight: screenRatio > previewRatio
            ? screenH
            : screenW / previewW * previewH,
        maxWidth: screenRatio > previewRatio
            ? screenH
            : screenW / previewW * previewH,
        child: CameraPreview(controller!),
      ),
    );
  }
}

// Painter for painting on top of image
class TextPainter extends CustomPainter {
  final ui.Image image;
  final Rect boundingText;
  TextPainter(this.image, this.boundingText);

  @override
  void paint(Canvas canvas, Size size) {
    final myPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawImage(image, Offset.zero, myPaint);
    canvas.drawRect(boundingText, myPaint);
  }

  @override
  bool shouldRepaint(TextPainter oldDelegate) {
    return image != oldDelegate.image ||
        boundingText != oldDelegate.boundingText;
  }
}

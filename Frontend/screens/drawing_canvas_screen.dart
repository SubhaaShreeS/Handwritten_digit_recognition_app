import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/api_service.dart';

class DrawingCanvasScreen extends StatefulWidget {
  const DrawingCanvasScreen({super.key});

  @override
  State<DrawingCanvasScreen> createState() => DrawingCanvasScreenState();
}

class DrawingCanvasScreenState extends State<DrawingCanvasScreen> {
  GlobalKey canvasKey = GlobalKey();
  List<Offset> points = [];
  String prediction = '';

  void clearCanvas() {
    setState(() {
      points.clear();
      prediction = '';
    });
  }

  Future<void> predictDigit() async {
    BuildContext? context = canvasKey.currentContext;
    if (context != null) {
      RenderObject? renderObject = context.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        RenderRepaintBoundary boundary = renderObject;
        ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          Uint8List pngBytes = byteData.buffer.asUint8List();
          Directory tempDir = await getTemporaryDirectory();
          String filePath = '${tempDir.path}/digit.png';
          File imageFile = File(filePath);
          await imageFile.writeAsBytes(pngBytes);

          String result = await ApiService.predictDigit(imageFile);
          setState(() {
            prediction = result;
          });
        }
      }
    }
  }

  Widget buildCanvas() {
    return RepaintBoundary(
      key: canvasKey,
      child: Container(
        width: 300,
        height: 300,
        color: Colors.white,
        child: CustomPaint(
          painter: CanvasPainter(points),
        ),
      ),
    );
  }

  Widget buildButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: predictDigit,
          child: Text('Predict'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: clearCanvas,
          child: Text('Clear'),
        ),
        SizedBox(height: 10),
        Text('Prediction: $prediction'),
      ],
    );
  }

  Widget buildDrawingArea() {
    return GestureDetector(
      onPanUpdate: (details) {
        Offset localPos = details.localPosition;
        setState(() {
          points.add(localPos);
        });
      },
      onPanEnd: (details) {
        setState(() {
          points.add(Offset.infinite);
        });
      },
      child: buildCanvas(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Draw Digit')),
      body: getCenter(),
    );
  }

  Center getCenter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildDrawingArea(),
          SizedBox(height: 20),
          buildButtons(),
        ],
      ),
    );
  }
}

class CanvasPainter extends CustomPainter {
  List<Offset> points;

  CanvasPainter(this.points);

  Paint getPaint() {
    Paint paint = Paint();
    paint.color = Colors.black;
    paint.strokeCap = StrokeCap.round;
    paint.strokeWidth = 16;
    return paint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = getPaint();

    for (int i = 0; i < points.length - 1; i++) {
      if (!points[i].dx.isInfinite && !points[i + 1].dx.isInfinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

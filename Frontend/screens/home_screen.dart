import 'package:flutter/material.dart';
import '../screens/drawing_canvas_screen.dart';
import '../screens/upload_image_screen.dart';

class HomeScreen extends StatelessWidget {
  Widget buildOptionButton(BuildContext context, String label, Widget screen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
        child: Text(label, style: TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return getScaffold(context);
  }

  Scaffold getScaffold(BuildContext context) {
    return Scaffold(
    appBar: getAppBar(),
    body: Center( // ✅ Center entire column
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ Only take necessary space vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Optional
        children: [
          buildOptionButton(context, 'Draw Digit', DrawingCanvasScreen()),
          buildOptionButton(context, 'Upload Image', ImageUploadScreen()),
        ],
      ),
    ),
  );
  }

  AppBar getAppBar() => AppBar(title: Text('Digit Recognition App'));
}

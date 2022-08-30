import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'classifier.dart';
import 'classifier_quant.dart';

class App extends StatefulWidget{
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App>{

  late Classifier _classifier;

  var logger = Logger();

  File? _image;
  final picker = ImagePicker();

  Image? _imageWidget;

  img.Image? fox;

  Category? category;

  @override
  void initState() {
    super.initState();
    _classifier = ClassifierQuant();
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Emotion Recognition"),
        centerTitle: true,
      ),

      body: ListView(
        children: <Widget>[
          Text(
            category != null ? category!.label : '',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700)
          ),

          Text(
            category != null
                ? 'Confidence: ${category!.score.toStringAsFixed(3)}'
                : '',
            style: TextStyle(fontSize: 16),
          ),

          Center(
            child: _image == null
                ? Text('Select Image from Camera or Gallery')
                : Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.50,
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                ),

              decoration: BoxDecoration(
                border: Border.all(),
              ),

              child: _imageWidget,
            ),
          ),

        Row(
          children: <Widget>[
             TextButton(
                onPressed: selectFromCamera,
                child: Text(
                    "Camera",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400
                    ),
                ),
                style: TextButton.styleFrom(backgroundColor: Colors.grey),
            ),

            TextButton(
              onPressed: selectFromGallery,
              child: Text(
                "Gallery",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400
                ),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.grey),
            ),

            // FlatButton.icon(
            //     onPressed: selectFromGallery,
            //     icon: Icon(Icons.file_upload),
            //     label: Text("Gallery")
            // ),

            // FlatButton.icon(
            //     onPressed: selectFromCamera,
            //     icon: Icon(Icons.camera_alt),
            //     label: Text("Camera")
            // ),

            ],
          )
        ]
      )
    );

  }

  selectFromGallery() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery
    );

    // if(pickedFile == null)
    //   return;

    setState(() {
      _image = File(pickedFile!.path);
      _imageWidget = Image.file(_image!);

      _predict();
    });
  }

  Future selectFromCamera() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.camera
    );

    // if(pickedFile == null)
    //   return;

    setState(() {
      _image = File(pickedFile!.path);
      _imageWidget = Image.file(_image!);

      _predict();
    });
  }

  void _predict() async {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    var pred = _classifier.predict(imageInput);

    setState(() {
      this.category = pred;
    });
  }


}
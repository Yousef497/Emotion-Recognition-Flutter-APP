import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_detector/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class App extends StatefulWidget{
  const App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App>{

  bool isWorking = false;
  String result = "";
  CameraController cameraController;
  CameraImage cameraImage;
  CameraDescription description;
  CameraLensDirection cameraDirection = CameraLensDirection.front;

  bool _loading = true;
  bool _stream = false;
  bool _cam = false;
  File _image;
  List _output;
  Image _imageWidget;
  final picker = ImagePicker();

  static Future<CameraDescription> getCamera(CameraLensDirection cameraLensDirection) async{
    return await availableCameras().then(
            (List<CameraDescription> cameras) => cameras.firstWhere(
                (CameraDescription cameraDescription) => cameraDescription.lensDirection == cameraLensDirection)
    );
  }

  void loadModel() async {
    await Tflite.loadModel(
        model: "assets/FER13.tflite",
        labels: "assets/FER13.txt",
    );
  }

  void initCamera() async {
    description = await getCamera(cameraDirection);
    cameraController = CameraController(description, ResolutionPreset.medium);

    await cameraController.initialize().then((value){
      if(!mounted){
        return;
      }

      // cameraController.startImageStream((imageFromStream) => {
      // if(!isWorking){
      //   isWorking = true,
      //   cameraImage = imageFromStream,
      // }

      setState(() {
        cameraController.startImageStream((imageFromStream) => {
          if(!isWorking){
            isWorking = true,
            cameraImage = imageFromStream,
            runModelOnStreamFrames(),
          }
        });
      });
    });
  }

  void runModelOnStreamFrames() async {
    if(cameraImage != null){
      final recognitions = await Tflite.runModelOnFrame(
          bytesList: cameraImage.planes.map((plane) {
            return plane.bytes;
          }).toList(),

        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 1, //change to 1 in future
        threshold: 0.1,
        asynch: true,
      );

      result = "";
      
      recognitions.forEach((dynamic response) {
        result += response["label"].toString() + " " + (response["confidence"] as double).toStringAsFixed(2) + "\n\n";
      });

      setState(() {
        result;
      });

      isWorking = false;
    }
  }

  void runModelOnImages(File image) async {
    final recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 7,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.1,
        asynch: true,
    );

    result = "";

    result += recognitions[0]["label"].toString() + " " + (recognitions[0]["confidence"] as double).toStringAsFixed(2) + "\n\n";

    setState(() {
      _output = recognitions;
      _loading = false;
      result;
    });
  }

  void selectFromGallery() async {
    final pickedFile = await ImagePicker.pickImage(
      source: ImageSource.gallery
    );

    // if(pickedFile == null)
    //   return;

    setState(() {
      _image = File(pickedFile.path);
      _imageWidget = Image.file(_image);

    });

    runModelOnImages(_image);
  }

  void selectFromCamera() async {
    final pickedFile = await ImagePicker.pickImage(
        source: ImageSource.camera
    );

    // if(pickedFile == null)
    //   return;

    setState(() {
      _image = File(pickedFile.path);
      _imageWidget = Image.file(_image);

    });

    runModelOnImages(_image);
  }

  void toggleCameraToFrontOrBack() async {
    if(cameraDirection == CameraLensDirection.back)
      cameraDirection = CameraLensDirection.front;
    else
      cameraDirection = CameraLensDirection.back;

    await cameraController.stopImageStream();
    await cameraController.dispose();

    setState(() {
      cameraController = null;
    });

    initCamera();
  }

  void startLiveStream() async {
    initCamera();
  }

  @override
  void initState() {
    super.initState();
    //initCamera();
    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
              title: const Center(
                child: Text("Emotion Recognition"),
              )
          ),

          body: Container(
            child: Column(
              children: [

                Stack(
                  children: <Widget>[

                    // add some code if image widget == null ? live stream : image widget

                    (_imageWidget == null) ? Center(
                        child: (_stream == true) ? Container(
                          height: 410,
                          width: 330,
                          //child: Image.asset("assets/1.jpg"), // change this photo
                          child: AspectRatio(
                            aspectRatio: cameraController.value.aspectRatio,
                            child: CameraPreview(cameraController),
                              ),
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                      )

                      : Container(
                          height: 410,
                          width: 330,
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                        ),
                    )

                    : Center(
                      child: (_cam == true) ? Container(
                        height: 410,
                        width: 330,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),

                        child: _imageWidget,
                      )

                      : Container(
                        height: 410,
                        width: 330,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                      ),
                    ),

                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                //here put the widgets of the prediction and confidence

                ((_stream == false) && (_cam == false)) ? Center(           // condition to be improved
                  child: Container(
                    child: SingleChildScrollView(
                      child: Text(
                        "Press any button\n\n",
                        style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.black
                        ),

                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )

                : Center(
                  child: Container(
                    child: SingleChildScrollView(
                      child: Text(
                        result,
                        style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.black
                        ),

                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: (){
                          selectFromGallery();
                          _stream = false;
                          _cam = true;
                          cameraController.dispose();              // to be coded photo from gallery
                        },
                        backgroundColor: Colors.teal,
                        elevation: 3.0,
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(
                        width: 30,
                      ),

                      FloatingActionButton(
                        onPressed: () {
                          selectFromCamera();
                          _stream = false;
                          _cam = true;
                          cameraController.dispose();
                        },                     // to be coded photo from camera
                        backgroundColor: Colors.teal,
                        elevation: 3.0,
                        child: Icon(
                          Icons.camera,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(
                        width: 30,
                      ),

                      FloatingActionButton(
                        onPressed: (){
                          _imageWidget = null;
                          _cam = false;
                          _stream = true;
                          startLiveStream();
                        },
                        backgroundColor: Colors.teal,
                        elevation: 3.0,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(
                        width: 30,
                      ),

                      FloatingActionButton(
                        onPressed: (){
                          _imageWidget = null;
                          _cam = false;
                          _stream = true;
                          toggleCameraToFrontOrBack();
                          startLiveStream();
                        },
                        backgroundColor: Colors.teal,
                        elevation: 3.0,
                        child: const Icon(
                          Icons.cached_outlined,
                          color: Colors.white,
                        ),
                      ),

                    ]
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

}
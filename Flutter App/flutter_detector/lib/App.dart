import 'package:camera/camera.dart';
import 'package:flutter_detector/main.dart';
import 'package:flutter/material.dart';
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
      var recognitions = await Tflite.runModelOnFrame(
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

  @override
  void initState() {
    super.initState();
    initCamera();
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
              title: Center(
                child: Text("Emotion Recognition"),
              )
          ),

          body: Container(
            child: Column(
              children: [

                Stack(
                  children: [
                    Center(
                        child: Container(
                          height: 410,
                          width: 330,
                          //child: Image.asset("assets/1.jpg"), // change this photo
                          child: AspectRatio(
                            aspectRatio: cameraController.value.aspectRatio,
                            child: CameraPreview(cameraController),
                              ),
                          color: Colors.black,
                      ),
                    ),

                  ],
                ),

                SizedBox(
                  height: 40,
                ),

                //here put the widgets of the prediction and confidence
                Center(
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

                SizedBox(
                  height: 10,
                ),

                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: null,
                        backgroundColor: Colors.teal,
                        elevation: 3.0,
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(
                        width: 60,
                      ),

                      FloatingActionButton(
                        onPressed: null,
                        backgroundColor: Colors.teal,
                        elevation: 3.0,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(
                        width: 60,
                      ),

                      FloatingActionButton(
                        onPressed: (){
                          toggleCameraToFrontOrBack();
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
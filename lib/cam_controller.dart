

import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';


class CamController extends GetxController{
  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var isCameraOK = false.obs;
  var camCount=0;
  var isProcessing = false.obs;
  var label = "";

  @override
  void onInit(){
    super.onInit();
    initModel();
    //initCamera();
  }

  @override
  void dispose(){
    super.dispose();
    cameraController.dispose();
    Tflite.close();
  }

  void initCamera() async{
    if(await Permission.camera.request().isGranted){
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.max);
      await cameraController.initialize().then((value){
         cameraController.startImageStream((image) {
          camCount++;
          if(camCount%10==0){
            camCount=0;
            detectObjects(image);
          }
          update();
        });
      });
      isCameraOK(true);
      update();
    }else{
      //print('Permission denied');
    }
  }

  void initModel() async{
    try{
      await Tflite.loadModel(
        model: 'assets/model3.tflite',
        labels: 'assets/labels3.txt',
      ).then((value) => initCamera());
    }catch(e){
      //print('ERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRLOADMODEL + $e');
    }
  }

  void detectObjects(CameraImage image) async {
    if (isProcessing.value) return; // Check if inference is already in progress
    isProcessing(true);

    try {
      List<dynamic>? results = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        threshold: 0.2,
        numResults: 1,
        imageMean: 0,
        imageStd: 255
      );

      if (results != null && results.isNotEmpty) {
        if(results.first['confidence']*100>45){
          label=results.first['label'];
          if(label.contains('cat')||label.contains('dog')){
            cameraController.setZoomLevel(2);
          }
          //print('YEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEES $results');
        }else{
          cameraController.setZoomLevel(await cameraController.getMinZoomLevel());
        }
      } else {
        //print("No objects detected.");
      }
    } catch (e) {
      //print("ERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR $e");
    } finally {
      isProcessing(false); // Reset flag after inference is completed
    }
  }



}
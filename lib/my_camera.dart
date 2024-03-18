
import 'package:camera/camera.dart';
import 'package:camera_app/cam_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyCamera extends StatelessWidget{
  const MyCamera({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<CamController>(
        init: CamController(),
        builder: (camController){
          return camController.isCameraOK.value?
          Stack(
            children: [
              CameraPreview(camController.cameraController),
              /*if (camController.label!="") Positioned(
                top: (camController.y*100),
                right: (camController.x*100),
                child: Container(
                  width: (camController.w*100),
                  height: (camController.h*100),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green,width: 0.4)
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: Colors.white,
                        child: Text(camController.label),
                      )
                    ],
                  ),
                ),
              )*/
              Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.white,
                  child: Center(child: Text(camController.label))
                ),
              )
            ],
          )
          :const Center(child: Text('Loading camera'));
        },
      ),
    );
  }

}
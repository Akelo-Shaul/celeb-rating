import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isRearCamera = true;
  XFile? imageFile;
  final ImagePicker imagePicker = ImagePicker();


  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async{
    cameras = await availableCameras();
    if(cameras != null && cameras!.isNotEmpty){
      _cameraController = CameraController(cameras![0], ResolutionPreset.high);
      await _cameraController!.initialize();
      setState(() {

      });
    }
  }

  void switchCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose(); // Dispose of the old controller
    }

    setState(() {
      isRearCamera = !isRearCamera; // Toggle the camera
      _cameraController = CameraController(
        cameras![isRearCamera ? 0 : 1],
        ResolutionPreset.high,
      );
      _cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    });
  }


  Future<void> capturePhoto() async{
    if(_cameraController != null && _cameraController!.value.isInitialized){
      imageFile = await _cameraController!.takePicture();
      // print(imageFile);
      setState(() {});
      print('The IMaGe PatH');
      print(imageFile!.path);
      Navigator.pop(context,imageFile);
    }
  }

  Future<void> pickGalleryImage() async{
    print('Image Picker Start');
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if(pickedFile != null){

      setState(() {
        imageFile = pickedFile;
      });
      Navigator.pop(context, pickedFile);
      print('ROuting HOOME');
      print(pickedFile);
    }
  }

  @override
  void dispose() {
    _cameraController!.dispose();
    imageFile = null;
    // imagePicker;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: _cameraController != null &&
                  _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : const Center(child: CircularProgressIndicator()),
            ),
            // Bottom section with gallery and camera controls
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.white,size: 35,),
                      onPressed: pickGalleryImage, // Open gallery picker
                    ),
                    GestureDetector(
                      onTap: capturePhoto, // Capture photo
                      child: const Icon(Icons.circle, size: 80, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.switch_camera, color: Colors.white,size: 35,),
                      onPressed: switchCamera, // Switch camera
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
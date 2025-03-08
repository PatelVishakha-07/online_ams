import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:online_ams/studentScreens/Attendance.dart';
import 'package:online_ams/studentScreens/SudentHome.dart';
import 'package:permission_handler/permission_handler.dart';

class StudentCameraScreen extends StatefulWidget {
  final String username;
  const StudentCameraScreen({super.key, required this.username});

  @override
  State<StudentCameraScreen> createState() => _StudentCameraScreenState();
}

class _StudentCameraScreenState extends State<StudentCameraScreen> {

  XFile? capturedImage;
  final ImagePicker imagePicker = ImagePicker();

  Future<void> CaptureImage() async{

    var status = await Permission.camera.request();
    if(status.isDenied){
      await Permission.camera.request();
    }else if(status.isPermanentlyDenied){
      openAppSettings();
      return;
    }

    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if(pickedFile != null){
      setState(() {
        capturedImage = pickedFile;
        DetectFace();
      });
    }
  }

  Future<void> DetectFace() async{
    if(capturedImage == null) return;
    final uri = Uri.parse(URL+"/detectFace");
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', capturedImage!.path));

    final response = await request.send();
    if(response.statusCode == 200){
      setState(() {
        SaveImage();
      });
    }else {
      setState(() {
        Navigator.pop(context);
      });
    }

  }

  Future<void> SaveImage() async{

    final uri = Uri.parse(URL+"/saveImage");
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', capturedImage!.path));
    request.fields['username'] = widget.username;

    final response = await request.send();
    if(response.statusCode == 200){
      setState(() {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentHomeScreen(username: widget.username)));
      });
    }else {
      setState(() {
        Navigator.pop(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    CaptureImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class AttendanceCameraScreen extends StatefulWidget {
  final String student_id;
  const AttendanceCameraScreen({super.key, required this.student_id});

  @override
  State<AttendanceCameraScreen> createState() => _AttendanceCameraScreenState();
}

class _AttendanceCameraScreenState extends State<AttendanceCameraScreen> {

  XFile? capturedPhoto;
  ImagePicker imagePicker = ImagePicker();
  Uint8List? imageBytes;
  bool isProcessing = false;
  @override
  void initState() {
    CaptureFace();
    super.initState();
  }

  Future<dynamic> CaptureFace() async{
    var status = await Permission.camera.request();
    if(status.isDenied){
      await Permission.camera.request();
    } else if(status.isPermanentlyDenied){
      openAppSettings();
      return;
    }
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    if(pickedImage != null){
      print("----------Captured-------- face");
      setState(() {
        capturedPhoto = pickedImage;
        isProcessing = true;
      });
       String msg = await DetectFace();
       if(context.mounted){
         Navigator.pop(context, msg);
       }else {
         if (mounted) {
           Navigator.pop(context, "No Face Found");
         }
       }
    }
  }

  Future<String> DetectFace() async{

    if (capturedPhoto == null) {
      return "No Face Scanned";
    }

    print("-------Detect face");
    final uri = Uri.parse(URL+"/detectFace");
    final request = http.MultipartRequest("POST",uri);
    request.files.add(await http.MultipartFile.fromPath("image",capturedPhoto!.path));
    final response = await request.send();
    if(response.statusCode == 200){
     return await VerifyFace();
    }else{
      return "No Face Found";
    }
  }

  Future<String> VerifyFace() async{
    print("---------verify face");
    final uri = Uri.parse(URL+"/compareFace");
    final request = http.MultipartRequest("POST",uri);
    request.files.add(await http.MultipartFile.fromPath("image",capturedPhoto!.path));
    request.fields["student_id"] = widget.student_id;

    final response = await request.send();

    if(response.statusCode == 200){
      return "Face Matched";
    }else{
      return "Face Did Not Matched";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isProcessing
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Processing face recognition...")
          ],
        )
            : Container(), // Empty container while capturing image
      ),
    );
  }
}



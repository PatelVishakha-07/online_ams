import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
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
  bool isLoading = false;

  Future<void> CaptureImage() async{
    await ShowWarningDialog(context);
    var status = await Permission.camera.request();
    if(status.isDenied){
      await Permission.camera.request();
    }else if(status.isPermanentlyDenied){
      await openAppSettings();
      return;
    }

    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if(pickedFile != null){
      if(mounted){
        setState(() {
          capturedImage = pickedFile;
          isLoading = true;
        });
      }
      await DetectFace();
    }else{
      if(mounted){setState(() {});}
      Navigator.pop(context);
    }
  }

  Future<void> DetectFace() async{
    if(capturedImage == null) return;
    final uri = Uri.parse(URL+"/detectFace");
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', capturedImage!.path));

    try{
      final response = await request.send();
      if(response.statusCode == 200){
        if(mounted){
          setState(() {
            SaveImage();
          });
        }
      }else {
        throw Exception("Face Detection Failed");
      }
    }catch(e){
      if(mounted){
        setState(() {
          isLoading = false;
        });
      }
      showErrorDialog("Connection issue. Please check your network.");
    }

  }

  Future<void> SaveImage() async{

    final uri = Uri.parse(URL+"/saveImage");
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', capturedImage!.path));
    request.fields['username'] = widget.username;

    try{
      final response = await request.send();
      if(response.statusCode == 200){
        if(mounted){
          setState(() {
            isLoading = false;
          });
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentHomeScreen(username: widget.username)));
      }else {
        throw Exception("Saving Image Failed");
        }
    }catch(e){
      if(mounted){
        setState(() {
          isLoading = false;
        });
      }
      showErrorDialog("Connection issue. Please check your network.");
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error",style: TextStyle(color: Colors.red),),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: (){Navigator.pop(context); },
                child: Text("OK")
            ),
            TextButton(
                onPressed: (){
                  CaptureImage();
                },
                child: Text("Retry")
            )
          ],
        )
    );
  }

  @override
  void initState() {
    super.initState();
    //CaptureImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CaptureImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(
        children: [
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
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
    //CaptureFace();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CaptureFace();
    });
  }

  Future<dynamic> CaptureFace() async{
    await ShowWarningDialog(context);
    var status = await Permission.camera.request();
    if(status.isDenied){
      await Permission.camera.request();
    } else if(status.isPermanentlyDenied){
      openAppSettings();
      return;
    }
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    if(pickedImage != null){
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
            : Container(),
      ),
    );
  }
}

Future<void> ShowWarningDialog(BuildContext context) async{
  await showDialog(
    barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Warning!!!"),
        content: Text("Please remove spectacles or goggles or mask before capturing image"),
        icon: Icon(Icons.warning_amber_outlined, color: Colors.red,),
        actions: [
          TextButton(
              onPressed: (){Navigator.pop(context); },
              child: Text("OK")
          )
        ],
      )
  );
}



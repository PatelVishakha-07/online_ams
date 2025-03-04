import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:online_ams/studentScreens/SudentHome.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  final String username;
  const CameraScreen({super.key, required this.username});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  late FaceCameraController cameraController;

  Uint8List fixImageOrientation(Uint8List imageBytes) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) throw Exception("Failed to decode image.");

    // Flip the image horizontally
    img.Image fixedImage = img.flipHorizontal(image);

    return Uint8List.fromList(img.encodeJpg(fixedImage));
  }

  Future<int> saveImage(BuildContext context,String username, String base64Image) async{
    final uri=Uri.parse(URL+"/upload_image");
    final response=await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "username":username,
          "image":base64Image
        })
    );
    return response.statusCode;
  }

  Future<void> SendImagetoServer(File image) async{
    final uri = Uri.parse(URL + "/analyzeImage");
    List<int> imageBytes = await image.readAsBytes();
    Uint8List correctedBytes = fixImageOrientation(Uint8List.fromList(imageBytes));
    String base64Image = base64Encode(correctedBytes);
    final response=await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "image":base64Image
        })
    );
    var jsonResponse = json.decode(response.body);

    bool glassesDetected = jsonResponse["glasses_detected"];
//    print("----------------------------------------------$glassesDetected");

    if(glassesDetected){
      WidgetsBinding.instance.addPostFrameCallback((_){
        if(mounted){
          showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: Text("Warning"),
                  icon: Icon(Icons.warning_amber_outlined, color: Colors.red,),
                  content: Text("Please Remove The Googles or Spectacles"),
                  actions: [
                    TextButton(
                        onPressed: (){ Navigator.pop(context); },
                        child: Text("OK")
                    )
                  ],
                );}
          );
          Navigator.pop(context);
        }
      });
    }else{
      if(mounted){
        saveImage(context, widget.username, base64Image);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentHomeScreen(username: widget.username)));
      }
    }
  }

  @override
  void initState() {
    cameraController=FaceCameraController(
        onCapture: (File? image){
          print("Image Captured: ${image?.path}");
          if(image != null){
            SendImagetoServer(image);
          }else {
            print("No Image Captured!");
          }
        },
      autoCapture: true,
      orientation: CameraOrientation. values[1],
      defaultCameraLens: CameraLens.front,
    );
    super.initState();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartFaceCamera(
          controller: cameraController,
        message: "Please Center your face in the square",
        showCaptureControl: true,showCameraLensControl: false,
      ),
    );
  }
}



// Another Camera Screen

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
    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if(pickedFile != null){
      setState(() {
        capturedImage = pickedFile;
        SaveImage();
      });
    }
  }

  Future<void> SaveImage() async{
    if(capturedImage == null) return;

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
    return Scaffold(
    );
  }
}


import 'dart:convert';
import 'dart:io';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:online_ams/facultyScreens/FacultyHome.dart';
import 'package:online_ams/studentScreens/Camera.dart';
import 'package:online_ams/studentScreens/SudentHome.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await FaceCamera.initialize();
  runApp( MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.amber
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget{
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {

  final formKey=GlobalKey<FormState>();
  bool obscurePassword = true;
  String selectedRole = "Admin";

  final usernameController=TextEditingController();
  final passwordController=TextEditingController();

  void validateField() async{
    String username=usernameController.text.toString();
    String password=passwordController.text.toString();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Logging in..."),
            ],
          ),
        );
      },
    );


    if(selectedRole=="Admin"){
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminScreen()));
      /*
        int statusCode= await CheckCredentials(username,password,selectedRole);
        if(statusCode == 200){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminScreen()));
        }else{
        }
      */
    }
    else if(selectedRole=="Faculty" || selectedRole=="Student"){

      int statusCode= await CheckCredentials(username, password,selectedRole);
      if(statusCode == 200){
        if(selectedRole == "Student"){
          var value = await FetchImage(username, password);
          Navigator.pop(context);
          if(value){
            Navigator.push(context, MaterialPageRoute(builder: (context) => StudentHomeScreen(username: username,)));
          }else{
            Navigator.push(context, MaterialPageRoute(builder: (context) => StudentCameraScreen(username: username,)));
          }
        }else if(selectedRole == "Faculty") {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => FacultyHomeScreen(username: username)));
        }
      }else{
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid Credentials")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 400,
                    height: 350,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.indigoAccent.shade100,Colors.white54]
                      ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 2
                          )
                        ]
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(" Attendance \nManagement \nSystem",
                            style: TextStyle(fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),),
                          Container(width: 200,height: 250,
                            child: Image.asset("asset/images/attendance_logo.png", fit: BoxFit.contain,),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),

                  Text("Select Your Role: ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                  Row(
                    children: [
                      buildRadioButton("Admin"),
                      buildRadioButton("Faculty"),
                      buildRadioButton("Student"),
                    ],
                  ),

                  SizedBox(height: 20),

                  if(selectedRole == "Admin")...[
                    buildTextField("Enter Username", Icons.person, usernameController),
                    SizedBox(height: 15,),
                    buildTextField("Enter Password", Icons.lock, passwordController, isPassword: true)
                  ] else
                    ...[
                      buildTextField("Enter Username", Icons.person, usernameController),
                      SizedBox(height: 15,),
                      buildTextField("Enter Password", Icons.lock, passwordController, isPassword: true),
                    ],

                  SizedBox(height: 25,),

                  // Log in button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if(formKey.currentState!.validate()){
                          validateField();
                        }
                      },
                      child: Text("Login", style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hintText, IconData leadingIcon, TextEditingController controller,{IconData? trailingIcon, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(leadingIcon, color: Colors.redAccent,),
        suffixIcon: isPassword ?
        IconButton(
            onPressed: (){
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
            icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
        ) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
      obscureText: isPassword ? obscurePassword : false,
      validator: (value){
        if(value!.isEmpty || value == null){
          return hintText;
        }
        return null;
      },
    );
  }

  Widget buildPhoneField(TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400)
      ),
      child: IntlPhoneField(
        keyboardType: TextInputType.number,
        controller: controller,
        initialValue: "IN",
      ),
    );
  }

  Widget buildRadioButton(String role) {
    return Row(
      children: [
        Radio(
          value: role,
          groupValue: selectedRole,
          onChanged: (value) {
            setState(() {
              selectedRole = value.toString();
            });
          },
          activeColor: Colors.redAccent,
        ),
        Text(role)
      ],
    );
  }
  
}

Future<bool> FetchImage(String username, String password) async{
  final uri = Uri.parse(URL + "/getImage");
  final response = await http.post(
      uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "username":username,
        "password":password,
        "role":"Student"
      })
  );
  if(response.statusCode == 200){
    return true;
  }else{
    return false;
  }
}

Future<int> CheckCredentials(String name, String password, String role) async{

  final uri=Uri.parse("$URL/login");
  var response=await http.post(
    uri,
    headers: {"Content-Type":"application/json"},
    body:jsonEncode({
      "username":name,
      "password":password,
      "role":role
    }),
  );
  return response.statusCode.toInt();
}


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
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await FaceCamera.initialize();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool isLoggedIn = sharedPreferences.getBool("isLoggedIn") ?? false;
  String? username = sharedPreferences.getString("username");
  String? role = sharedPreferences.getString("role");

  late Widget homeScreen;
  if(isLoggedIn && username != null && role != null){
    if(role == "Admin"){
      homeScreen = AdminScreen();
    }else if(role == "Faculty"){
      homeScreen = FacultyHomeScreen(username: username);
    }else{
      homeScreen = StudentHomeScreen(username: username);
    }
  }else{
    homeScreen = LoginScreen();
  }
  runApp( MyApp(homeScreen: homeScreen,));
}

class MyApp extends StatelessWidget{
  final Widget homeScreen;
  const MyApp({super.key, required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.amber
      ),
      debugShowCheckedModeBanner: false,
      home: homeScreen,
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
    String username=usernameController.text.toString().trim();
    String password=passwordController.text.toString().trim();

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

    int statusCode= await CheckCredentials(username, password,selectedRole);
    if (!mounted) return;
    Widget nextScreen = LoginScreen();
    if(statusCode == 200){

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setBool("isLoggedIn", true);
      await sharedPreferences.setString("username", username);
      await sharedPreferences.setString("role", selectedRole);

      if(selectedRole=="Admin"){
        nextScreen = AdminScreen();
      }
      else if(selectedRole == "Student"){
        var value = await FetchImage(username, password);
        if(value){
          nextScreen = StudentHomeScreen(username: username);
        }else{
          nextScreen = StudentCameraScreen(username: username);
        }
      }else if(selectedRole == "Faculty") {
        nextScreen = FacultyHomeScreen(username: username);
      }
      if(!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => nextScreen), (route) => false);
    }else{
      if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid Credentials"), backgroundColor: Colors.red),
        );
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
              child: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
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
                      child: Row(
                        children: [
                          Text("Attendance \nManagement \nSystem",
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),),
                          Flexible(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 250,
                              child: Image.asset("asset/images/attendance_logo.png", fit: BoxFit.contain,),
                            ),
                          ),
                        ],
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
                      buildTextField("Enter Username", Icons.person, usernameController, keyboardType: TextInputType.text),
                      SizedBox(height: 15,),
                      buildTextField("Enter Password", Icons.lock, passwordController, isPassword: true,
                          keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false))
                    ] else
                      ...[
                        buildTextField("Enter Username", Icons.person, usernameController, keyboardType: TextInputType.text),
                        SizedBox(height: 15,),
                        buildTextField("Enter Password", Icons.lock, passwordController, isPassword: true,
                            keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false)),
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
      ),
    );
  }

  Widget buildTextField(String hintText, IconData leadingIcon, TextEditingController controller,
      {IconData? trailingIcon, bool isPassword = false, TextInputType?  keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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


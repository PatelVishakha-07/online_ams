import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;
import 'package:online_ams/studentScreens/Camera.dart';

 class Modules {

   //FUNCTION TO SAVE OTP CODE IN OTP_TABLE
  static Future<void> SaveOtp(BuildContext context, String otpCode, int class_id, int faculty_id, int division_id, String created_at,
      String expiry_time, int subject_id) async{
    final uri = Uri.parse(URL+"/");
    final response = await http.post(
        uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "otp_code":otpCode,
        "class_id":class_id,
        "faculty_id":faculty_id,
        "division_id":division_id,
        "subject_id":subject_id,
        "created_at":created_at,
        "expiry_time":expiry_time
      })
    );
    if(response.statusCode == 200){
      Navigator.pop(context);
    }
  }

  // FUNCTION TO FETCH STUDENT OR FACULTY DATA
  static Future<List<dynamic>> FetchData(String choice, {String? dept,String? year, String? division, String? faculty_id}) async{
    final uri=Uri.parse(URL+"/fetchData");
    final response=await http.post(uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "department":dept,
          "option":choice,
          "year":year,
          "division":division,
          "faculty_id":faculty_id
        })
    );
    if(response.statusCode == 200){
      return json.decode(response.body);
    }else{
      throw Exception("Failed to Load $choice Details");
    }
  }

  // FUNCTION TO UPDATE STUDENT OR FACULTY DATA
  static Future<void> updateStudentFacultyData(BuildContext context, String? dept, String name, String contact, String dob,
      String role, {String? roll_no, String? year, String? division, String? student_id, String? faculty_id}) async{
    final uri=Uri.parse(URL+"/updateFacultyStudentData");
    final response=await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "role":role,
          "name":name,
          "department":dept,
          "contact":contact,
          "dob":dob,
          "roll_no":roll_no,
          "year":year,
          "division":division,
          "student_id":student_id,
          "faculty_id":faculty_id
        })
    );
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Record Updated Successfully")));
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Update Record")));
    }
  }

  // FUNCTION TO FETCH DIVISION TABLE DATA
  static Future<List<dynamic>> FetchDivision(String studentClass) async{
    final uri =Uri.parse(URL+"/fetchDivisionNameId");
    final response = await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({"class_id":studentClass})
    );
    if(response.statusCode == 200){
      return json.decode(response.body);
    }else{
      return [];
    }
  }

  // FUNCTION TO FETCH CLASS_TABLE DATA
  static Future<List<dynamic>> FetchYear(String studentDepartment) async{
    final uri =Uri.parse(URL+"/fetchYearNameId");
    final response = await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({"department":studentDepartment})
    );
    if(response.statusCode == 200){
      return json.decode(response.body);

    }else{
      return [];
    }
  }

  // FUNCTION TO FETCH SUBJECT TABLE DATA
  static Future<List<dynamic>> FetchSubjectList({String? role,String? dept, String? year, int? faculty_id}) async{
    final uri = Uri.parse(URL + "/fetchSubject");
    final response = await http.post(uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "role":role,
          "department":dept,
          "year":year,
          "faculty_id":faculty_id
        })
    );

    if ( response.statusCode == 200){
      return json.decode(response.body);
    }else{
      throw Exception("Failed to Load Details");
    }
  }

  // FUNCTION TO GET STUDENT CURRENT LOCATION
  static Future<Position?> GetStudentLocation()  async{
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if(!serviceEnabled){ return null; }

    permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.deniedForever){ return null; }
    }

    return await Geolocator.getCurrentPosition();
  }

  // FUNCTION TO VERIFY STUDENT LOCATION
  static bool CheckStudentArea(double facultyLatitude, double facultyLongitude,
      double studentLatitude, double studentLongitude, double allowedRadius){
    double distance = Geolocator.distanceBetween(facultyLatitude, facultyLongitude, studentLatitude, studentLongitude);
    return distance <= allowedRadius;
  }

  //FUNCTION TO VERIFY OTP CODE ENTERED BY STUDENT
  static void ValidateOtp(BuildContext context, String OtpCode, String class_id, String division_id, String subject_id) async{
    Position? studentPosition = await GetStudentLocation();

    if(studentPosition == null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location Permission Required")));
      return;
    }
    double faculty_latitude = 0.0;
    double faculty_longitude = 0.0;
    double allowed_radius = 0.0;

    if(CheckStudentArea(faculty_latitude, faculty_longitude, studentPosition.latitude, studentPosition.longitude, allowed_radius)){
      final uri = Uri.parse(URL+"/");
      final response = await http.post(
          uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "otp_code":OtpCode,
          "class_id":class_id,
          "division_id":division_id,
          "subject_id":subject_id
        })
      );
      if(response.statusCode == 200){
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
        CameraScreen(username: "")));
      }
      else if (response.statusCode == 400){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Missing required fields!")));
      }
    }else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You are not in the allowed area!")));
    }

  }

  // FUNCTION TO SHOW DIALOGBOX TO MARK ATTENDANCE FOR STUDENT
  static void ShowMarkAttendanceDialog(BuildContext context, String student_id){
    String selectedSubject;
    Future<List<dynamic>> subjectList = FetchSubjectList(dept: "", role: "Student", year: "");

    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Mark Attendance"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField(
                    items: subjectList,
                    onChanged: onChanged
                )
              ],
            ),
          );
        }
    );
  }
}
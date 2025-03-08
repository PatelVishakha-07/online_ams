import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;

class Attendance{

  //FETCH FACULTY LOCATION
  static Future<dynamic> FetchFacultyLocation(String class_id, String division_id) async{
    final uri = Uri.parse(URL+"/fetchFacultyLocation");
    final response = await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "class_id":class_id,
          "division_id":division_id
        })
    );
    if(response.statusCode == 200){
      return json.decode(response.body);
    }
    return null;
  }

  // FUNCTION TO VERIFY STUDENT LOCATION
  static bool CheckStudentArea(double facultyLatitude, double facultyLongitude,
      double studentLatitude, double studentLongitude, double allowedRadius){
    double distance = Geolocator.distanceBetween(facultyLatitude, facultyLongitude, studentLatitude, studentLongitude);
    return distance <= allowedRadius;
  }

  //FUNCTION TO VERIFY OTP CODE ENTERED BY STUDENT
  static Future<String> ValidateOtp(BuildContext context, String OtpCode, String class_id, String division_id, String subject_id) async{

    final uri = Uri.parse(URL+"/checkOTP");
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
    if(response.statusCode != 200){
      return "Invalid";
    }

    Position? studentPosition = await Modules.GetCurrentLocation();
    if(studentPosition == null){
      return "Location Permission Required";
    }

    final facultyLocationList = await FetchFacultyLocation(class_id, division_id);

    double faculty_latitude =0.0, faculty_longitude=0.0, allowed_radius=0.0;

    if (facultyLocationList != null && facultyLocationList.isNotEmpty) {
      final facultyLocation = facultyLocationList[0]; // Get first item if list
      faculty_latitude = double.parse(facultyLocation["faculty_latitude"].toString());
      faculty_longitude = double.parse(facultyLocation["faculty_longitude"].toString());
      allowed_radius = double.parse(facultyLocation["area"].toString());
    }else{
      return "Time to Mark Attendance is Over.";
    }

    if(!CheckStudentArea(faculty_latitude, faculty_longitude, studentPosition.latitude, studentPosition.longitude, allowed_radius)){
      return "You are not in the allowed area!";
    }

    return "Valid";

  }

  // FUNCTION TO SHOW DIALOGBOX TO MARK ATTENDANCE FOR STUDENT
  static Future<Map> ShowMarkAttendanceDialog(BuildContext context, String student_id, String department, String year,
      String division_id, String class_id) async{
    String? selectedSubject;

    final formKey = GlobalKey<FormState>();

    Future<List<dynamic>> subjectList = Modules.FetchSubjectList(dept: department, role: "Student", year: year);
    TextEditingController codeController = TextEditingController();
    return await showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(
              builder: (context, setState){
                return AlertDialog(
                  title: Text("Mark Attendance"),
                  content: FutureBuilder<List<dynamic>>(
                      future: subjectList,
                      builder: (context, snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);
                        else if(snapshot.hasError) return Center(child: Text("Error ${snapshot.error}"),);
                        else if(!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No Subject Found"),);

                        List<dynamic> items = snapshot.data!;

                        return Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButtonFormField<dynamic>(
                                value: selectedSubject,
                                items: items.map((subject){
                                  return DropdownMenuItem<String>(
                                    value: subject["subject_id"].toString(),
                                    child: Text(subject["sub_name"].toString()),
                                  );
                                }).toList(),
                                onChanged: (value){
                                  setState((){
                                    selectedSubject = value;
                                  });
                                },
                                validator: (value){
                                  if(value == null){
                                    return "Select Subject";
                                  }
                                },
                                decoration: const InputDecoration(labelText: "Select Subject"),
                              ),

                              SizedBox(height: 20,),
                              Pinput(
                                validator: (value){
                                  if(value!.isEmpty || value == null){
                                    return "Enter the Code";
                                  }
                                },
                                controller: codeController,
                                length: 4,
                                keyboardType: TextInputType.number,
                                defaultPinTheme: PinTheme(
                                  width: 50, height: 50,
                                  textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, ""),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        if(formKey.currentState!.validate()){
                          String otpCode = codeController.text.trim().toString();
                          String subject_id = selectedSubject.toString();
                          String msg = await ValidateOtp(context, otpCode, class_id, division_id, subject_id);
                          Navigator.pop(context, {"msg":msg, "sub_id":subject_id ?? "0"});
                        }
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                );
              }
          );
        }
    );
  }

  static Future<dynamic> MarkAttendance(BuildContext context, String student_id, String class_id, String division_id, String subject_id,
      String semester_id, String academic_year_id) async {
    final uri = Uri.parse(URL+"/markAttendance");
    final response = await http.post(
        uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "student_id":student_id,
        "class_id":class_id,
        "division_id":division_id,
        "subject_id":subject_id,
        "semester_id":semester_id,
        "academic_year_id":academic_year_id
      })
    );
    if(response.statusCode == 200){
      Navigator.pop(context,"Marked");
    }else{
      Navigator.pop(context,"Not Marked");
    }
  }
}
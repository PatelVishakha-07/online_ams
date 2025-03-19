import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;
import 'package:online_ams/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

 class Modules {

   // FUNCTION TO FETCH STUDENT OR FACULTY DATA
   static Future<List<dynamic>> FetchData(String choice,
       {String? dept, String? year, String? division,
         String? faculty_id, String? student_id}) async {
     final uri = Uri.parse(URL + "/fetchData");
     final response = await http.post(uri,
         headers: {"Content-Type": "application/json"},
         body: jsonEncode({
           "department": dept,
           "option": choice,
           "year": year,
           "division": division,
           "faculty_id": faculty_id
         })
     );
     if (response.statusCode == 200) {
       return json.decode(response.body);
     } else {
       return [];
     }
   }

   // FUNCTION TO FETCH SINGLE STUDENT OR FACULTY DATA
   static Future<List<dynamic>> FetchSingleData(String choice,
       {String? faculty_id, String? student_id}) async {
     final uri = Uri.parse(URL + "/fetchSingleRecord");
     final response = await http.post(uri,
         headers: {"Content-Type": "application/json"},
         body: jsonEncode({
           "role": choice,
           "faculty_id": faculty_id,
           "student_id": student_id
         })
     );
     if (response.statusCode == 200) {
       return json.decode(response.body);
     } else {
       throw Exception("Failed to Load $choice Details");
     }
   }


   // FUNCTION TO UPDATE STUDENT OR FACULTY DATA
   static Future<bool> updateStudentFacultyData(BuildContext context,
       String? dept, String name, String contact, String dob,
       String role,
       {String? roll_no, String? year, String? division, String? student_id, String? faculty_id,
         String? studentAcademicYear, String? studentSemester}) async {
     final uri = Uri.parse(URL + "/updateFacultyStudentData");
     final response = await http.post(
         uri,
         headers: {"Content-Type": "application/json"},
         body: jsonEncode({
           "role": role,
           "name": name,
           "department": dept,
           "contact": contact,
           "dob": dob,
           "roll_no": roll_no,
           "class_id": year,
           "division_id": division,
           "student_id": student_id,
           "faculty_id": faculty_id,
           "academic_year": studentAcademicYear,
           "semester": studentSemester
         })
     );
     if (response.statusCode == 200) {
       return true;
     } else {
       return false;
     }
   }

   // FUNCTION TO FETCH DIVISION TABLE DATA
   static Future<List<dynamic>> FetchDivision(String studentClass) async {
     final uri = Uri.parse(URL + "/fetchDivisionNameId");
     final response = await http.post(
         uri,
         headers: {"Content-Type": "application/json"},
         body: jsonEncode({"class_id": studentClass})
     );
     if (response.statusCode == 200) {
       return json.decode(response.body);
     } else {
       return [];
     }
   }

   // FUNCTION TO FETCH CLASS_TABLE DATA
   static Future<List<dynamic>> FetchYear(String studentDepartment) async {
     final uri = Uri.parse(URL + "/fetchYearNameId");
     final response = await http.post(
         uri,
         headers: {"Content-Type": "application/json"},
         body: jsonEncode({"department": studentDepartment})
     );
     if (response.statusCode == 200) {
       return json.decode(response.body);
     } else {
       return [];
     }
   }

   // FUNCTION TO FETCH SUBJECT TABLE DATA
   static Future<List<dynamic>> FetchSubjectList({String? role, String? dept, String? year, int? faculty_id,
     String? semester_id, String? option, String? subject_id}) async {

     final uri;
     if(role == "Subject"){
     uri = Uri.parse(URL + "/fetchSingleRecord");
     }else{
       uri = Uri.parse(URL + "/fetchSubject");
     }

     final response = await http.post(uri,
         headers: {"Content-Type": "application/json"},
         body: jsonEncode({
           "role": role,
           "department": dept,
           "year": year,
           "faculty_id": faculty_id,
           "semester_id":semester_id,
           "subject_id":subject_id
         })
     );

     if (response.statusCode == 200) {
       return json.decode(response.body);
     } else {
       throw Exception("Failed to Load Details");
     }
   }

   // FUNCTION TO FETCH STUDENT OR FACULTY ID THROUGH USER_ID
   static Future<int> FetchId(String username, String role) async {
     final uri = Uri.parse("$URL/fetchId");
     final response = await http.post(
         uri,
         headers: {"Content-Type": "application/json"},
         body: jsonEncode({
           "username": username,
           "role": role
         })
     );
     if (response.statusCode == 200) {
       return json.decode(response.body);
     }
     return 0;
   }

   // FUNCTION TO REMOVE FACULTY
   static Future<void> DeleteData(BuildContext context,
       { String? option, String? student_id, String? faculty_id, String? subject_id,
         String? class_id, String? division_id}) async {
     final uri = Uri.parse(URL + "/deleteRecord");
     final response = await http.post(
         uri,
         headers: {"Content-Type": "application/json"},
         body: jsonEncode({
           "option": option,
           "student_id": student_id.toString(),
           "faculty_id": faculty_id.toString(),
           "class_id": class_id.toString(),
           "division_id": division_id.toString(),
           "subject_id":subject_id
         })
     );
     if (response.statusCode == 200) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Record Deleted Successfully")));
     } else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Delete Record")));
     }
   }

   // FUNCTION TO GET STUDENT OR FACULTY CURRENT LOCATION
   static Future<Position?> GetCurrentLocation() async {
     bool serviceEnabled;
     LocationPermission permission;
     serviceEnabled = await Geolocator.isLocationServiceEnabled();

     if (!serviceEnabled) {
       await Geolocator.openLocationSettings();
       return null;
     }

     permission = await Geolocator.checkPermission();

     if (permission == LocationPermission.denied) {
       permission = await Geolocator.requestPermission();
       if (permission == LocationPermission.denied) {
         return null;
       }
     }
     if (permission == LocationPermission.deniedForever) return null;

     return await Geolocator.getCurrentPosition(
         desiredAccuracy: LocationAccuracy.high);
   }

   //FUNCTION TO SAVE OTP CODE IN OTP_TABLE
   static Future<void> SaveOtp(BuildContext context, String otpCode,
       int class_id, int faculty_id, int division_id, String created_at,
       String expiry_time, int subject_id, String faculty_latitude,
       String faculty_longitude, String area) async {
     final uri = Uri.parse(URL + "/addOtp");
     final response = await http.post(
         uri,
         headers: {"Content-Type": "application/json"},
         body: jsonEncode({
           "otp_code": otpCode,
           "class_id": class_id,
           "faculty_id": faculty_id,
           "division_id": division_id,
           "subject_id": subject_id,
           "created_at": created_at,
           "expiry_time": expiry_time,
           "faculty_latitude": faculty_latitude,
           "faculty_longitude": faculty_longitude,
           "area": area
         })
     );
     if (response.statusCode == 200) {
       Navigator.pop(context);
     }
   }

   static Future<dynamic> FetchAcademicYearList() async {
     final uri = Uri.parse(URL + "/fetchAcademicYear");
     final response = await http.post(uri,headers: {"Content-Type": "application/json"},);
     if (response.statusCode == 200) {
         return jsonDecode(response.body);
     } else {
       return [];
     }
   }

   static Future<List<dynamic>> FetchSemesterList({String? academicYearId}) async {
     final uri = Uri.parse(URL + "/fetchSemesters");
     final response = await http.post(
       uri,
       headers: {"Content-Type": "application/json"},
       body: jsonEncode({"academic_year_id": academicYearId}),
     );
     if (response.statusCode == 200) {
      return jsonDecode(response.body);

     } else {
       return [];
     }
   }

   static void showLogoutDialog(BuildContext context){
     showDialog(
       barrierDismissible: false,
         context: context,
         builder: (context) => AlertDialog(
           elevation: 4,
           shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
           title: Text("Logout", style: TextStyle(color: Colors.redAccent),),
           icon: Icon(Icons.warning_amber_outlined, color: Colors.red,),
           content: Text("Are You Sure You Want to Logout?", style: TextStyle(fontSize: 20),),
           actions: [
             TextButton(
               onPressed: (){
                 Navigator.pop(context);
               },
               child: Text("Cancel", style: TextStyle(color: Colors.green),),
             ),
             TextButton(
                 onPressed: () async{
                   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                   await sharedPreferences.clear();
                   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
                 },
                 child: Text("Logout",),
             )
           ],
         )
     );
   }

 }

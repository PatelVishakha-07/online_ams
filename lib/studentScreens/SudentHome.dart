import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;
import 'package:online_ams/studentScreens/Attendance.dart';
import 'package:online_ams/studentScreens/Camera.dart';

class StudentHomeScreen extends StatefulWidget {
  final String username;
  const StudentHomeScreen({super.key, required this.username});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {

  List<Map<String,dynamic>> studentDashboardItems=[
    {"Title":"Mark Attendance", "Icon":Icons.co_present, "route": "mark_attendance"},
    {"Title":"            View\n Attendance Report", "Icon":Icons.report, "route": ""},
  ];
  String todayDate=DateFormat('dd MMMM yyyy').format(DateTime.now());
  String todayDay=DateFormat('EEEE').format(DateTime.now());

  bool isLoading = false;
  Uint8List? imageBytes;
  int? student_id;
  late Future<List<dynamic>> studentDetails = Future.value([]);
  String? stdDept, stdYear, stdDiv, stdName, stdContact, stdDob;
  String? classId, divId, semester_id, academic_year_id;

  Future<void> FetchImage() async{
    setState(() {
      isLoading = true;
    });
    final uri = Uri.parse(URL + "/getImage");
    final response = await http.post(
      uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "username":widget.username,
        "role":"Student"
      }),
    );
    if(response.statusCode == 200) {
      setState(() {
        imageBytes = response.bodyBytes;
        isLoading = false;
      });
    }else{
      setState(() {
        isLoading = false;
      });
      // Optionally handle errors here
      debugPrint("Failed to fetch image: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    FetchImage();
    super.initState();
    Modules.FetchId(widget.username,"Student").then((id){
      setState(() {
        student_id = id;
        studentDetails = Modules.FetchSingleData("Student", student_id: student_id.toString());
        studentDetails.then((values){
          if(values.isNotEmpty){
            stdDept = values[0]["department"];
            stdName = values[0]["name"];
            stdContact = values[0]["contact_no"];
            stdYear = values[0]["year"];
            stdDiv = values[0]["division"];
            stdDob = values[0]["dob"];
            classId = values[0]["class_id"].toString();
            divId = values[0]["division_id"].toString();
            semester_id = values[0]["semester_id"].toString();
            academic_year_id = values[0]["academic_year_id"].toString();
          }
        });

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard \n  (Student)",style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pink.shade50,
        centerTitle: true,
      ),
      backgroundColor: Colors.pink.shade50,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
              elevation: 4,
              color: Colors.blue.shade100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10,),
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[300],
                    child: ClipOval(
                      child: isLoading ? CircularProgressIndicator() : imageBytes != null
                          ? SizedBox( width: 160, height: 160,
                        child: FittedBox( fit: BoxFit.cover, child: Image.memory(imageBytes!), ),)
                          : Text("No image found"),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text("  Welcome ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 25,),

                  Center(
                      child: Text("         "+todayDay+"\n  "+todayDate,style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                  ),
                ],
              ),
            ),

            SizedBox(height: 30,),

            Expanded(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16
                  ),
                  itemCount: studentDashboardItems.length,
                  itemBuilder: (context,index){
                    return GestureDetector(
                      child: Card(
                        color: Colors.blue.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(studentDashboardItems[index]["Icon"],size: 50,color: Colors.redAccent,),
                            SizedBox(height: 15,),
                            Text(studentDashboardItems[index]["Title"],style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      onTap: () async{
                        if(studentDashboardItems[index]["route"] == "mark_attendance"){

                          if(stdDept == null || stdYear == null || divId == null || classId == null){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Loading Student details, please wait...")));
                            return;
                          }
                          Map result = await Attendance.ShowMarkAttendanceDialog(context, student_id.toString(),
                              stdDept!, stdYear!, divId!, classId!);
                          String subject_id = result["subject_id"];
                          String status = result["msg"];

                          if(status == "Valid"){
                            String msg = await Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceCameraScreen(student_id: student_id.toString())));
                            if(msg == "Face Matched"){
                              String option = await Attendance.MarkAttendance(context, student_id.toString(), classId.toString(),
                                  divId.toString(), subject_id ,semester_id.toString(), academic_year_id.toString());

                              if(option == "Marked"){
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Attendance marked successfully")));
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to marked Attendance")));
                              }
                            }
                            else if(msg == "Face Did Not Matched"){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Face Did Not Matched")));
                            }
                            else if (msg == "No Face Found"){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Face Found")));
                            }
                          }
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP Code is Not Valid")));
                        }
                      },
                    );
                  }
              ),
            ),
          ],
        ),
      )
      );
  }
}





import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class StudentDetailScreen extends StatefulWidget {
  final int student_id;
  const StudentDetailScreen({super.key, required this.student_id});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {

  late List<dynamic> studentDetail = [];

  Uint8List? stdImage;
  bool isLoading = false;
  String? stdName, stdDept, stdContact, stdDob, year, division, academic_year, semester, stdRollNo;
  List<dynamic> attendanceData = [];
  String? firstName;

  @override
  void initState() {
    super.initState();
    FetchImage();
    FetchStudentOldData();
    FetchAttendanceDetails();
  }

  Future<void> FetchAttendanceDetails() async{
    final uri = Uri.parse(URL + "/fetchAttendanceReport");
    final response = await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body:jsonEncode({
          "student_id":widget.student_id,
          "role":"Admin"
        })
    );
    if(response.statusCode == 200){
      var data = json.decode(response.body);
      setState(() {
        attendanceData = data;
      });
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Loas Attendance Details")));
    }
  }


  Future<void> FetchImage() async{
    setState(() {
      isLoading = true;
    });
    final uri = Uri.parse(URL + "/getImage");
    final response = await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "student_id":widget.student_id,
          "role":"Admin"
        })
    );
    if(response.statusCode == 200){
      setState(() {
        stdImage = response.bodyBytes;
        isLoading = false;
      });
    }else{
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch image")));
    }
  }

  Future<void> FetchStudentOldData() async{
    final uri=Uri.parse(URL+"/fetchSingleRecord");
    final response=await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "role":"Student",
          "student_id":widget.student_id
        })
    );
    if(response.statusCode == 200){
      setState(() {
        studentDetail = json.decode(response.body);
        if(studentDetail.isNotEmpty){
          var student = studentDetail.firstWhere((e) => e["student_id"] == widget.student_id, orElse: () =>null);
          stdName = student["name"];
          var fullName = stdName!.split(" ");
          firstName = fullName[0].toString();
          stdDept = student["department"];
          stdContact = student["contact_no"];
          stdRollNo = student["student_id"].toString();
          DateFormat inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
          DateTime parsedDate = inputFormat.parse(student["dob"]);
          stdDob = DateFormat('dd-MM-yyyy').format(parsedDate);
          year = student["year"];
          division = student["division"];
          academic_year = student["academic_year"].toString();
          semester = student["semester_no"].toString();
        }
      });
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load Student Data")));
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalClasses = attendanceData.length;
    int presentCount = attendanceData.where((entry) => entry["status"] == "Present").length;
    int absentCount = totalClasses - presentCount;
    double attendancePercentage = totalClasses > 0 ? (presentCount / totalClasses) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${firstName != null ? "$firstName's" : "Student's"} Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
      backgroundColor: Colors.pink.shade50,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Card(
                color: Colors.blue.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey[300],
                        child: ClipOval(
                          child: isLoading ? CircularProgressIndicator() : stdImage != null ?
                          SizedBox( width: 160, height: 160,
                            child: FittedBox( fit: BoxFit.cover, child: Image.memory(stdImage!), ),
                          ) : Icon(Icons.image, size: 50, color: Colors.grey,),
                        ),
                      ),
                      SizedBox(height: 50,),

                      Text("Name: " + (stdName ?? "N/A"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      Text("Date of Birth: " + (stdDob ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                      Text("Roll No: " + (stdRollNo ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                      Text("Academic Year: " + (academic_year ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                      Text("Class: " + (year ?? "N/A") + ( stdDept ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                      Text("Semester: " + (semester ?? "N/A") , style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                      Text("Division: " + (division ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                      Text("Contact Number: " + (stdContact ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30,),
              buildCard("Total Classes", totalClasses.toString(), Icons.check_circle),
              SizedBox(height: 20,),
              buildCard("Present Days", presentCount.toString(), Icons.event_available_outlined),
              SizedBox(height: 20,),
              buildCard("Absent Days",absentCount.toString(), Icons.do_not_disturb_on_outlined),
              SizedBox(height: 20,),
              buildCard("Attendance",attendancePercentage.toStringAsFixed(2), Icons.percent_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(String text, String number, IconData icon){
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(  // Changed from Column to Row
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Ensure spacing
          children: [
            Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            Row(
              children: [
                Text(number, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                SizedBox(width: 15),
                Icon(icon),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

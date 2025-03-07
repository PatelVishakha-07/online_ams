import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
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
  String? stdName, stdDept, stdContact, stdDob, year, division;

  @override
  void initState() {
    super.initState();
    FetchImage();
    FetchStudentOldData();
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
          stdDept = student["department"];
          stdContact = student["contact_no"];

          stdDob = student["dob"];
          //var year_division = studentDetail[1]; // Second object has year & division
          year = student["year"];
          division = student["division"];
        }
      });
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load Student Data")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(((stdName?? "Student") + "\n                    (Profile)"),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
      backgroundColor: Colors.pink.shade50,
      body: Padding(
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
                        ) : Text("No Image"),
                      ),
                    ),
                    SizedBox(height: 50,),

                    Text("Name: " + (stdName ?? "N/A"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    Text("Date of Birth: " + (stdDob ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                    Text("Class: " + (year ?? "N/A") + ( stdDept ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                    Text("Division: " + (division ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                    Text("Contact Number: " + (stdContact ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30,),
            buildCard("Present Days", "5", Icons.event_available_outlined),
            SizedBox(height: 30,),
            buildCard("Absent Days", "5", Icons.minimize_outlined),
          ],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(number,style: TextStyle(fontSize: 20,),),
                SizedBox(width: 10,), Icon(icon)
              ],
            ),
            SizedBox(height: 10,), Text(text,)
          ],
        ),
      ),
    );
  }

}

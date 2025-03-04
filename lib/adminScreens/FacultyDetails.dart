import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class FacultyDetailScreen extends StatefulWidget {
  final int faculty_id;
  const FacultyDetailScreen({super.key, required this.faculty_id});

  @override
  State<FacultyDetailScreen> createState() => _FacultyDetailScreenState();
}

class _FacultyDetailScreenState extends State<FacultyDetailScreen> {

  late List<dynamic> facultyDetailList = [];
  String? stdName, stdDept, stdContact, stdDob;

  Future<void> FetchFacultyOldData() async {
    final uri = Uri.parse(URL + "/fetchSingleRecord");
    final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "role": "Faculty",
          "student_id": widget.faculty_id
        })
    );
    if(response.statusCode == 200){
      setState(() {
        facultyDetailList = json.decode(response.body);
        if(facultyDetailList.isNotEmpty){
          var student = facultyDetailList.firstWhere((e) => e["faculty_id"] == widget.faculty_id, orElse: () =>null);
          stdName = student["faculty_name"];
          stdDept = student["department"];
          stdContact = student["contact_no"];
          stdDob = student["dob"];
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
        title: Text((stdName?? "Student" + " Profile"),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
      backgroundColor: Colors.pink.shade50,
        body: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: " + (stdName ?? "N/A"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    Text("Date of Birth: " + (stdDob ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                    Text ("Department" + ( stdDept ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                    Text("Contact Number: " + (stdContact ?? "N/A"), style: TextStyle(fontSize: 16, color: Colors.grey.shade700),),
                  ],
                )
              ],
            ),
          ),
        )
    );
  }
}

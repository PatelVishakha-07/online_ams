import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:online_ams/adminScreens/StudentDetails.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';

class StudentReportScreen extends StatefulWidget {
  final String faculty_id, subject_id;
  const StudentReportScreen({super.key, required this.faculty_id, required this.subject_id});

  @override
  State<StudentReportScreen> createState() => _StudentReportScreenState();
}

class _StudentReportScreenState extends State<StudentReportScreen> {

  late Future<List<dynamic>> studentList;
  String searchQuery = "";
  List<dynamic> filteredStudents = [], allStudents = [];
  int totalIndex=0;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FetchStudents();
    searchController.addListener((){
      setState(() {
        searchQuery = searchController.text.toLowerCase();
        FilterStudents();
      });
    });
  }

  void FilterStudents(){
    if(searchQuery.isEmpty){
      filteredStudents = allStudents;
    }else{
      filteredStudents = allStudents.where((student){
        return student["name"].toLowerCase().contains(searchQuery);
      }).toList();
    }
    setState(() {
      totalIndex = filteredStudents.length;
    });
  }


  void FetchStudents() async{
    setState(() {
      isLoading = true;
    });
    final uri = Uri.parse(URL+"/fetchStudentForFaculty");
    final response = await http.post(
      uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "faculty_id":widget.faculty_id,
        "subject_id":widget.subject_id
      })
    );
    if(response.statusCode == 200){
      setState(() {
        isLoading = false;
        allStudents = jsonDecode(response.body);
        filteredStudents = allStudents;
      });
    }else{
      setState(() {
        isLoading = false;
        allStudents = [];
        filteredStudents = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Students Found")));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard\n   (Faculty)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
      backgroundColor: Colors.pink.shade50,
      body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search Students...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),),
              ),
            ),
            Expanded(
                child: isLoading ? Center(child: CircularProgressIndicator(),) :
                allStudents.isEmpty ? Center(child: Text("No Student Found"),) :
                filteredStudents.isEmpty ? Center(child: Text("No Student Matched Your Search"),) :
                ListView.builder(
                  itemCount: filteredStudents.length,
                    itemBuilder: (context,index){
                    var student = filteredStudents[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Icon(Icons.person,color: Colors.redAccent),
                        title: Text(student["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => 
                          StudentDetailScreen(student_id: student["student_id"])));
                        },
                      ),
                    );
                    }
                )
            )
          ]
      )
    );
  }
}

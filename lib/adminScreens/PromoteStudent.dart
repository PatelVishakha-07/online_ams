import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class PromoteStudentScreen extends StatefulWidget {
  final String department;
  const PromoteStudentScreen({super.key, required this.department});

  @override
  State<PromoteStudentScreen> createState() => _PromoteStudentScreenState();
}

class _PromoteStudentScreenState extends State<PromoteStudentScreen> {

  List<Map<String, dynamic>> fyStudentList = [], syStudentList = [], tyStudentList = [];
  bool isLoading = true;

  Future<void> LoadStudent() async{
    final results = await Future.wait([
      FetchStudent("FY"),
      FetchStudent("SY"),
      FetchStudent("TY"),
    ]);
    setState(() {
      fyStudentList = results[0];
      syStudentList = results[1];
      tyStudentList = results[2];
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    LoadStudent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student List to Promote",
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
        centerTitle: true,
        backgroundColor: Colors.pink.shade50,
      ),
      backgroundColor: Colors.pink.shade50,
      body: isLoading ? Center(child: CircularProgressIndicator()):
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Text("Department: ${widget.department}",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
            SizedBox(height: 20,),
            buildStudentList("FY Students List", fyStudentList),
            SizedBox(height: 30,),
            buildStudentList("SY Students List", syStudentList),
            SizedBox(height: 30,),
            buildStudentList("TY Students List", tyStudentList),
            SizedBox(height: 35,),
            ElevatedButton(
                onPressed: (){
                  PromoteStudents();
                },
                child: Text("Promote Selected")
            )
          ],
        ),
      ),
    );
  }

  void toggleCheckBox(List<Map<String, dynamic>> students, int index){
    setState(() {
      students[index]["isChecked"] = !students[index]["isChecked"];
    });
  }

  Widget buildStudentList(String title, List<Map<String, dynamic>> students) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        children: students.asMap().entries.map((entry) {
          int index = entry.key + 1;
          Map<String, dynamic> std = entry.value;
          bool isChecked = std["isChecked"] ?? false;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: CheckboxListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              tileColor: isChecked ? Colors.green[100] : Colors.grey[200], // Background color
              title: Row(
                children: [
                  Text("$index. ", // Serial number
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Expanded(
                    child: Text(std["name"] ?? "N/A",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
                        color: isChecked ? Colors.green[800] : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              value: isChecked,
              onChanged: (bool? value) {
                toggleCheckBox(students, entry.key);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> FetchStudent(String year) async {
    final uri = Uri.parse(URL + "/fetchStudents");
    final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "year": year,
          "department": widget.department
        })
    );
    if (response.statusCode == 200) {
      var studentList = List<Map<String, dynamic>>.from(
          jsonDecode(response.body));
      if (studentList is List) {
        return studentList.map((student) {
          return {
            "id": student["student_id"],
            "name": student["name"],
            "isChecked": true,
            "year": student["year"],
            "semester_number": student["semester_number"],
            "academic_year": student["academic_year"]
          };
        }).toList();
      } else {
        return []; // Ensure an empty list is returned instead of null
      }
    }else{
      setState(() {
        isLoading = false;
      });
      return [];
    }
  }


  Future<void> PromoteStudents() async {
    List<Map<String, dynamic>> selectedStudents = [];

    bool isPromote = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Promote Students"),
          content: Text("Are you sure you want to promote all the students to the next year?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Promote", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
          ],
        )
    );

    if (!isPromote) return;

    if (isPromote) {
      for(var student in fyStudentList){
        if(student["isChecked"] == true){
          selectedStudents.add({
            "student_id":student["id"],
            "department":widget.department,
            "year":student["year"],
            "semester_number":student["semester_number"],
            "academic_year":student["academic_year"],
            "class_id":student["class_id"],
            "academic_year_id":student["academic_year_id"]
          });
        }
      }

      for(var student in syStudentList){
        if(student["isChecked"] == true){
          selectedStudents.add({
            "student_id":student["id"],
            "department":widget.department,
            "year":student["year"],
            "semester_number":student["semester_number"],
            "academic_year":student["academic_year"]
          });
        }
      }

      for(var student in tyStudentList){
        if(student["isChecked"] == true){
          selectedStudents.add({
            "student_id":student["id"],
            "department":widget.department,
            "year":student["year"],
            "semester_number":student["semester_number"],
            "academic_year":student["academic_year"]
          });
        }
      }

      if(selectedStudents.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Student Selected")));
        return;
      }

      final uri = Uri.parse(URL+"/promoteStudents");
      final response = await http.post(
          uri,
          headers: {"Content-Type":"application/json"},
          body: jsonEncode({"student_list":selectedStudents})
      );
      var data = jsonDecode(response.body);
      if(response.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"])));
        setState(() {});
        LoadStudent();
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"])));
      }
    }
  }
}

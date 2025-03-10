import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/Modules.dart';
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
  String? facultyName, facultyDept, facultyContact, facultyDob, firstName;
  bool isLoading = false, hasError = false;
  List<dynamic> subjectList = [];

  Future<void> FetchFacultyOldData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final uri = Uri.parse(URL + "/fetchSingleRecord");
    final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "role": "Faculty",
          "faculty_id": widget.faculty_id
        })
    );
    if(response.statusCode == 200){
      facultyDetailList = json.decode(response.body);
      if(facultyDetailList.isNotEmpty) {
        setState(() {
          var faculty = facultyDetailList.firstWhere((e) =>
          e["faculty_id"] == widget.faculty_id, orElse: () => null);
          facultyName = faculty["faculty_name"];
          List<String> nameParts = facultyName!.split(" ");
          firstName = nameParts.first;
          facultyDept = faculty["department"];
          facultyContact = faculty["contact_no"];
          DateFormat inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
          DateTime parsedDate = inputFormat.parse(faculty["dob"]);
          facultyDob = DateFormat('dd-MM-yyyy').format(parsedDate);
          isLoading = false;
        });
      }
      List<dynamic> subjects = await Modules.FetchSubjectList(
        role: "Faculty",
        faculty_id: widget.faculty_id,
      );
      setState(() {
        subjectList = subjects;
      });
    }else{
      setState(() {
        hasError = true;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load Faculty Data")));
    }
  }

  @override
  void initState() {
    super.initState();
    FetchFacultyOldData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(firstName != null ? "$firstName's Profile" : "Faculty Profile",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
      backgroundColor: Colors.pink.shade50,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Failed to load faculty data", style: TextStyle(fontSize: 18, color: Colors.red)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: FetchFacultyOldData,
              child: Text("Retry"),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${facultyName ?? 'N/A'}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Date of Birth: ${facultyDob ?? 'N/A'}", style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                SizedBox(height: 5),
                Text("Department: ${facultyDept ?? 'N/A'}", style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                SizedBox(height: 5),
                Text("Contact Number: ${facultyContact ?? 'N/A'}", style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                SizedBox(height: 15),
                Divider(),
                Text("Subjects Taken:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                subjectList.isNotEmpty
                    ? ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: subjectList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.book, color: Colors.pink.shade300),
                      title: Text(subjectList[index]["sub_name"], style: TextStyle(fontSize: 16)),
                    );
                  },
                )
                    : Text("No subjects assigned", style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

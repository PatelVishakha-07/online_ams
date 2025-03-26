import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class SubjectDetailScreen extends StatefulWidget {
  final String subName, sub_id;
  const SubjectDetailScreen({super.key, required this.sub_id, required this.subName});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {

  List<dynamic> subList = [], faculty_List = [];
  bool isSubjectLoading = false;
  String subject_name = "", sub_code = "", subYear ="", subSemester = "", subDepartment = "", faculty_name ="";

  Future<void> FetchSubjectList() async{
    setState(() {
      isSubjectLoading = true;
    });
    final uri = Uri.parse(URL+"/fetchSingleRecord");
    final response = await http.post(
      uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({"subject_id":widget.sub_id, "role":"Subject"})
    );
    if(response.statusCode == 200){
      var subjectData = jsonDecode(response.body);
      setState(() {
        isSubjectLoading = false;
        //var subject = subList.firstWhere((sub) => sub["subject_id"].toString() == widget.sub_id, orElse: () => null);
        subject_name = subjectData["sub_name"];
        sub_code = subjectData["sub_code"].toString();
        subYear = subjectData["year"];
        subSemester = subjectData["semester_no"].toString();
        subDepartment = subjectData["department"];

        faculty_List = (subjectData["faculty_list"] as List).map((faculty) => {
          "faculty_name": faculty["faculty_name"],
          "division": int.tryParse(faculty["division"].toString()) ?? 0 // Convert to int
        }).toList();
        faculty_List.sort((a, b) => a["division"].compareTo(b["division"]));
        faculty_List = faculty_List.map((faculty) => {
          "faculty_name": faculty["faculty_name"],
          "division": faculty["division"].toString()
        }).toList();
      });
    }else{
      setState(() {
        isSubjectLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Data found for ${widget.subName} subject")));
    }
  }

  @override
  void initState() {
    super.initState();
    FetchSubjectList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subName + "",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
      backgroundColor: Colors.pink.shade50,
      body: isSubjectLoading ? Center(child: CircularProgressIndicator(),) :
          Padding(
              padding: EdgeInsets.all(16),
            child: Card(
              margin: EdgeInsets.only(top: 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded card
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20,),
                      buildDetailRow("Subject Name", subject_name),
                      buildDetailRow("Subject Code", sub_code),
                      buildDetailRow("Department", subDepartment),
                      buildDetailRow("Year", subYear),
                      buildDetailRow("Semester", subSemester),

                      faculty_List.isNotEmpty ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Faculty: ",style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                          SizedBox(height: 10,),
                          ... faculty_List.map((faculty) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text("Division ${faculty["division"]}: ${faculty["faculty_name"]}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black54),),
                          ))
                        ],
                      ) : buildDetailRow("Faculty", "N/A"),
                      SizedBox(height: 20,),
                    ]
                ),
              ),
            ),
          )
    );
  }
}

Widget buildDetailRow(String label, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        Text(
          value.isNotEmpty ? value : "N/A",
          style: TextStyle(
            fontSize: 20,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black54,
          ),
        ),
      ],
    ),
  );
}


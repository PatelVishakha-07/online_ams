import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class AttendanceReportScreen extends StatefulWidget {
  final String student_id, subName, semesterNo, year, class_id, subject_id, semester_id, to_date, from_date;
  const AttendanceReportScreen({super.key, required this.subName, required this.student_id, required this.subject_id,
  required this.year, required this.semesterNo, required this.class_id, required this.semester_id, required this.from_date,
  required this.to_date});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {

  String? subName, semesterNo, year;
  List<dynamic> attendanceData = [];

  bool isLoading = true, hasError = false;

  Future<void> FetchAttendanceReport() async{
    final uri = Uri.parse(URL + "/fetchAttendanceReport");
    final response = await http.post(
        uri,
      headers: {"Content-Type":"application/json"},
        body:jsonEncode({
          "subject_id":widget.subject_id,
          "semester_id":widget.semester_id,
          "class_id":widget.class_id,
          "from_date":widget.from_date,
          "to_date":widget.to_date,
          "student_id":widget.student_id
    })
    );
    if(response.statusCode == 200){
      var data = json.decode(response.body);
      setState(() {
        attendanceData = data;
        isLoading = false;
      });
    }else{
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    int totalClasses = attendanceData.length;
    int presentCount = attendanceData.where((entry) => entry["status"] == "Present").length;
    double attendancePercentage = totalClasses > 0 ? (presentCount / totalClasses) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Report",style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pink.shade50,
        centerTitle: true,
      ),
      backgroundColor: Colors.pink.shade50,
      body: isLoading
          ? Center(child: CircularProgressIndicator()) : hasError
          ? Center(child: Text("Error fetching data. Please try again."))
          : attendanceData.isEmpty
          ? Center(child: Text("No attendance records found."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Card(
              color: Colors.white,
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📚 Subject: ${widget.subName}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("📅 Date: ${widget.from_date} to ${widget.to_date}", style: TextStyle(fontSize: 14)),
                    Text("🏫 Semester: ${widget.semesterNo} | Year: ${widget.year}", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),

            //ATTENDANCE LIST
            Expanded(
              child: Card(
                elevation: 3,
                color: Colors.white,
                child: ListView.builder(
                  itemCount: attendanceData.length,
                  itemBuilder: (context, index) {
                    final entry = attendanceData[index];
                    return ListTile(
                      title: Text("📅 ${entry['attendance_date']}"),
                      trailing: Text(
                        entry["status"],
                        style: TextStyle(
                          color: entry["status"] == "Present" ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 10),

            //SUMMARY SECTION
            Card(
              color: Colors.white,
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📊 Summary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text("📌 Total Classes: $totalClasses"),
                    Text("✅ Present: $presentCount"),
                    Text("📉 Attendance: ${attendancePercentage.toStringAsFixed(2)}%"),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Go Back"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade200),
              ),
            ),
          ],
        ),
      ),
    );
  }

}


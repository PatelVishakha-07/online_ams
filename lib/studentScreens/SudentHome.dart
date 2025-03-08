import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;
import 'package:online_ams/studentScreens/Attendance.dart';
import 'package:online_ams/studentScreens/AttendanceReport.dart';
import 'package:online_ams/studentScreens/Camera.dart';

class StudentHomeScreen extends StatefulWidget {
  final String username;
  const StudentHomeScreen({super.key, required this.username});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {

  String todayDate=DateFormat('dd MMMM yyyy').format(DateTime.now());
  String todayDay=DateFormat('EEEE').format(DateTime.now());

  Uint8List? imageBytes;
  int? student_id;
  late Future<List<dynamic>> studentDetails = Future.value([]);
  String? stdDept, stdYear, stdDiv, stdName, stdContact, stdDob;
  String? classId, divId, semester_id, academic_year_id;
  late List<dynamic> subjectList =[], semesterList =[], yearList=[], academicYearList=[];
  bool isLoadingYear = false, isLoadingSemester = false, isLoadingAcademicYear = false,  isLoading = false;
  String? selectedSubject, fromDate = "", toDate ="", selectedSemester, selectedYear, selectedAcademicYear;
  TextEditingController fromDateController = TextEditingController(), toDateController = TextEditingController();

  void FetchDetails() async{

    setState(() {
      isLoadingAcademicYear = true;
      isLoadingYear = true;
      isLoadingSemester = true;
    });

    student_id  = await Modules.FetchId(widget.username,"Student");
    List<dynamic> values = await Modules.FetchSingleData("Student", student_id: student_id.toString());
    if(values.isNotEmpty) {
      setState(() {
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
      });

      academicYearList = await Modules.FetchAcademicYearList();
      yearList = await Modules.FetchYear(stdDept!);
      semesterList = await Modules.FetchSemesterList(yearList.isNotEmpty ? yearList[0]["year_id"] : null);
      subjectList = await Modules.FetchSubjectList(semester_id: semester_id, role: "Attendance_Report", year: stdYear, dept: stdDept);

      setState(() {
        isLoadingAcademicYear = false;
        isLoadingYear = false;
        isLoadingSemester = false;
      });

    }else {
      // If no student details found, stop loading
      setState(() {
        isLoadingAcademicYear = false;
        isLoadingYear = false;
        isLoadingSemester = false;
      });
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
    super.initState();
    FetchImage();
    FetchDetails();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String,dynamic>> studentDashboardItems=[
      {"Title":"Mark Attendance", "Icon":Icons.co_present, "route": "mark_attendance"},
      {"Title":"            View\n Attendance Report", "Icon":Icons.report, "route": "Attendance_Report",}
    ];
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
                          String subject_id = result["sub_id"] ?? "0";
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
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP Code is Not Valid")));
                          }
                        }
                        else if(studentDashboardItems[index]["route"] == "Attendance_Report"){
                          showAttendanceReportDialog(context);
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


  void showAttendanceReportDialog(BuildContext context) {
    setState(() {
      isLoadingAcademicYear = false; // Ensure it is not stuck in loading
    });

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text("Fill Details to View Report"),
          icon: Icon(Icons.document_scanner),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              buildDropDownButton(labelText: "Select Academic Year", items: academicYearList, selectedValue: selectedAcademicYear,
                onChanged: (value) async{
                  setState(() {
                    selectedAcademicYear = value;
                    isLoadingSemester = true;
                  });
                  semesterList = await Modules.FetchSemesterList(selectedAcademicYear!);
                  setState(() {
                    isLoadingSemester = false;
                  });
                }, id_name: "academic_year_id", name: "academic_year", isLoading: isLoadingAcademicYear,),

              SizedBox(height: 20,),
              buildDropDownButton(labelText: "Select Year", items: yearList, selectedValue: selectedYear,
                  onChanged: (value) async{
                    setState(() {
                      selectedYear = value;
                    });
                  }, id_name: "class_id", name: "year"),

              SizedBox(height: 20,),
              buildDropDownButton(labelText: "Select Semester", items: semesterList, selectedValue: selectedSemester,
                  onChanged: (value) async{
                    setState(() {
                      selectedSemester = value;
                    });
                    subjectList = await Modules.FetchSubjectList(role: "Attendance Report", dept: stdDept ?? "",
                        year: selectedYear, semester_id: selectedSemester);
                    setState(() {});
                  }, id_name: "semester_id", name: "semester_number", isLoading: isLoadingSemester),

              SizedBox(height: 20,),
              buildDropDownButton(labelText: "Select Subject", items: subjectList, selectedValue: selectedSubject,
                  onChanged: (value) async{
                    setState(() {
                      selectedSubject = value;
                    });
                  }, id_name: "subject_id", name: "sub_name"),
              SizedBox(height: 20,),
              buildDateField(fromDateController, "From ", Icons.today, "from"),
              SizedBox(height: 20,),
              buildDateField(toDateController, "To ", Icons.today, "to")
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                child: Text("Cancel")),

            TextButton(
                onPressed: (){

                  String? selectedSubjectName = subjectList.firstWhere((subject) => subject["subject_id"] == selectedSubject,
                      orElse: () => {"sub_name": "Unknown Subject"} )["sub_name"];

                  String? selectedSemesterNo = semesterList.firstWhere((semester) => semester["semester_id"] == selectedSemester,
                      orElse: () => {"semester_number": "Unknown Semester"} )["semester_number"];

                  String? selectedYearName = yearList.firstWhere((yearValues) => yearValues["class_id"] == selectedYear,
                      orElse: () => {"year": "Unknown Year"} )["year"];

                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  AttendanceReportScreen(subName: selectedSubjectName!, student_id: student_id.toString(), subject_id: selectedSubject.toString(),
                      year:selectedYearName!, semesterNo: selectedSemesterNo!, class_id: selectedYear.toString(),
                      semester_id: selectedSemester.toString(), from_date: fromDate.toString(), to_date: toDate.toString())));
                },
                child: Text("Submit")
            )
          ],
        )
    );
  }

  Widget buildDropDownButton({required String labelText, required List<dynamic> items, bool isLoading = false,
    required String? selectedValue,  required void Function(dynamic) onChanged, required String? id_name, required String? name }) {
    return DropdownButtonFormField(
      value: items.any((item) => item[id_name] == selectedValue) ? selectedValue ?? "" : null,
      validator: (value) {
        if(value == null) return "Please select $labelText";
        return null;
      },
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: isLoading || items.isEmpty
          ? [DropdownMenuItem(child: Text("Loading..."), value: "")]
          : items.map((dynamic item){
        return DropdownMenuItem<dynamic>(
            value: item[id_name].toString(),
            child: Text(item[name].toString(),)
        );
      }).toList(),
      onChanged: isLoading ? null : onChanged,
    );
  }

  Widget buildDateField(TextEditingController controller, String labelText, IconData icon,String variable, {bool toValidate = true}){
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: Icon(icon),
      ),
      onTap: ()=>SelectDate(context, variable, controller),
      validator: (value){
        if(value == null || value.isEmpty) return labelText;
        return null;
      } ,
    );
  }

  Future<void> SelectDate(BuildContext context,  String type, TextEditingController controller) async{
    DateTime? dateSelected= await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      initialDate: DateTime.now(),
      lastDate: DateTime.now(),
    );
    if(dateSelected != null){
      setState(() {
        String formattedDate = DateFormat('yyyy-MM-dd').format(dateSelected);
        if(type == "from"){
          fromDate=formattedDate.toString();
        }else{
          toDate = formattedDate.toString();
        }
        controller.text=DateFormat('yyyy-MM-dd').format(dateSelected);
      });
    }
  }

}





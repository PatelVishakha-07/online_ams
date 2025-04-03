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
  String? stdDept, stdYear, stdDiv, stdName, stdContact, stdDob, stdRollNo;
  String? classId, divId, semester_id, academic_year_id;
  late List<dynamic> subjectList =[], semesterList =[], yearList=[], academicYearList=[];
  bool isLoadingSemester = false,  isLoading = false;
  String? selectedSubject, fromDate = "", toDate ="", selectedSemester = "", selectedYear = "", selectedAcademicYear = "";
  TextEditingController fromDateController = TextEditingController(), toDateController = TextEditingController();

  void FetchDetails() async{
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
        stdRollNo = values[0]["student_id"].toString();
        classId = values[0]["class_id"].toString();
        divId = values[0]["division_id"].toString();
        semester_id = values[0]["semester_id"].toString();
        academic_year_id = values[0]["academic_year_id"].toString();
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
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                FetchImage();
                FetchDetails();
              });
            },
            icon: Icon(Icons.refresh, color: Colors.blue),
            tooltip: "Reload",
          ),

          IconButton(
              onPressed: (){
                Modules.showLogoutDialog(context);
              },
              icon: Icon(Icons.logout_outlined, color: Colors.red)
          )
        ],
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
                            Text(studentDashboardItems[index]["Title"],
                                style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05,
                                    fontWeight: FontWeight.bold)),
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
                          String otp_code = result["otp_code"].toString();

                          if(status == "Valid"){
                            String msg = await Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceCameraScreen(student_id: student_id.toString())));
                            if(msg == "Face Matched"){
                              String option = await Attendance.MarkAttendance(context, student_id.toString(), classId.toString(),
                                  divId.toString(), subject_id ,semester_id.toString(), academic_year_id.toString(),otp_code.toString());

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
                          else if(status == "Invalid"){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP Code is Not Valid")));
                          }
                          else if(status == "You are not in the allowed area!"){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You are not in the allowed area!")));
                          }
                          else if(status == "Time to Mark Attendance is Over."){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Time to Mark Attendance is Over.")));
                          }
                          else if(status == "Attendance Already Marked"){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Attendance is Already Marked for this lecture")));
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

    selectedAcademicYear = null;
    selectedYear = null;
    selectedSemester = null;
    selectedSubject = null;
    fromDateController.clear();
    toDateController.clear();
    bool isSemesterLoading = false, isSubjectLoading = false;
    bool isLoadingAcademicYear = true, isLoadingYear = true;
    bool hasFetchedAcademicYears = false, hasFetchedYearList = false;
    List academicYearList = [];
    List yearList = [];
    semesterList = [];
    subjectList = [];

    Future<void> fetchAcademicYears(StateSetter setState) async {
      if (hasFetchedAcademicYears) return; // Prevent multiple API calls
      hasFetchedAcademicYears = true;

      List data = await Modules.FetchAcademicYearList();
      setState(() {
        academicYearList = data;
        isLoadingAcademicYear = false;
      });
    }

    Future<void> fetchYearList(StateSetter setState) async{
      if(hasFetchedYearList) return;
      hasFetchedYearList = true;
      List data = await Modules.FetchYear(stdDept.toString());
      setState((){
        yearList = data;
        isLoadingYear = false;
      });
    }

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState){
                if (isLoadingAcademicYear) {
                  fetchAcademicYears(setState);
                }
                if(isLoadingYear){
                  fetchYearList(setState);
                }
                return AlertDialog(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  title: Text("Fill Details to View Report"),
                  icon: Icon(Icons.document_scanner),
                  content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        buildDropDownButton(labelText: "Select Academic Year", items: academicYearList, selectedValue: selectedAcademicYear,
                          onChanged: (value) async{
                            setState(() {
                              selectedAcademicYear = value;
                            });
                          }, id_name: "academic_year_id", name: "academic_year", isLoading: isLoadingAcademicYear,),

                        SizedBox(height: 20,),
                        buildDropDownButton(labelText: "Select Year", items: yearList, selectedValue: selectedYear,
                            onChanged: (value) async{
                              setState(() {
                                selectedYear = value.toString();
                                semesterList.clear();
                                isSemesterLoading = true;
                              });
                              List newSemesterList = await Modules.FetchSemesterList(academicYearId: selectedAcademicYear);
                              setState(() {
                                semesterList = newSemesterList.toSet().toList();
                                selectedSemester = null;
                                isSemesterLoading = false;
                                String? selectedYearLabel = yearList.firstWhere((element) => element["class_id"].toString() == selectedYear.toString(),
                                  orElse: () => {"year": null},
                                )["year"];

                                if (selectedYearLabel == "FY") {
                                  semesterList = semesterList.where((sem) => sem["semester_number"].toString() == "1" ||
                                      sem["semester_number"].toString() == "2").toList();
                                } else if (selectedYearLabel == "SY") {
                                  semesterList = semesterList.where((sem) => sem["semester_number"].toString() == "3" ||
                                      sem["semester_number"].toString() == "4").toList();
                                } else if (selectedYearLabel == "TY") {
                                  semesterList = semesterList.where((sem) => sem["semester_number"].toString() == "5" ||
                                      sem["semester_number"].toString() == "6").toList();
                                }
                              });
                            }, id_name: "class_id", name: "year"),

                        SizedBox(height: 20,),
                        buildDropDownButton(labelText: "Select Semester", items: semesterList, selectedValue: selectedSemester,
                            onChanged: (value) async{
                              setState(() {
                                selectedSemester = value;
                                isSubjectLoading = true;
                              });
                              List newSubjectList = await Modules.FetchSubjectList(role: "Attendance_Report", dept: stdDept ?? "",
                                  year: selectedYear, semester_id: selectedSemester);
                              setState(() {
                                subjectList = newSubjectList.toSet().toList();
                                isSubjectLoading = false;
                              });
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
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context),
                        child: Text("Cancel")),

                    TextButton(
                        onPressed: (){
                          String selectedSubjectName = "", selectedYearName = "", selectedSemesterNo = "";
                          subjectList.forEach((e) {
                            if (e["subject_id"].toString() == selectedSubject) {
                              selectedSubjectName = e["sub_name"];
                            }
                          });
                          yearList.forEach((e) {
                            if (e["class_id"].toString() == selectedYear) {  // Ensure correct year selection
                              selectedYearName = e["year"];
                            }
                          });
                          semesterList.forEach((e) {
                            if (e["semester_id"].toString() == selectedSemester) {  // Ensure correct semester selection
                              selectedSemesterNo = e["semester_number"].toString();
                            }
                          });

                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              AttendanceReportScreen(subName: selectedSubjectName.toString(), student_id: student_id.toString(),
                                  subject_id: selectedSubject.toString(), year:selectedYearName.toString(), semesterNo: selectedSemesterNo.toString(),
                                  class_id: selectedYear.toString(), semester_id: selectedSemester.toString(),
                                  from_date: fromDate.toString(), to_date: toDate.toString())));


                        },
                        child: Text("Submit")
                    )
                  ],
                );
          });
        }
    );
  }

  Widget buildDropDownButton({required String labelText, required List<dynamic> items, bool isLoading = false,
    required String? selectedValue,  required void Function(dynamic) onChanged, required String? id_name, required String? name }) {
    return DropdownButtonFormField(
      value: items.any((item) => item[id_name].toString() == selectedValue.toString()) ? selectedValue.toString() ?? "" : null,
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





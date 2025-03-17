import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class UpdateStudentScreen extends StatefulWidget {
  final int student_id;

  const UpdateStudentScreen({super.key, required this.student_id});

  @override
  State<UpdateStudentScreen> createState() => _UpdateStudentScreenState();
}

class _UpdateStudentScreenState extends State<UpdateStudentScreen> {

  final formKey=GlobalKey<FormState>();
  var studentFirstNameController=TextEditingController();
  var studentMiddleNameController=TextEditingController();
  var studentLastNameController=TextEditingController();
  var studentContactNoController=TextEditingController();
  var studentDobController=TextEditingController();
  var studentRollNoController=TextEditingController();

  String studentClass = "", studentDivision = "", studentDepartment = "", studentAcademicYear = "", studentSemester = "";
  String oldFirstName="", oldLastName="", oldMiddleName="";
  List<dynamic> studentData = [];
  DateTime? studentDob;
  final List<String> dept =["BCA","BBA","BCOM","BSC"];
  late List<dynamic> studentYearList = [], studentDivisionList = [], semesterList=[], academicYearList=[];
  bool isLoading = false, isDataLoading = false, isUpdating = false;

  Future<void> FetchOldData() async{
    setState(() => isDataLoading = true);
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
        studentData = json.decode(response.body);
      });
      if(studentData.isNotEmpty){
        UpdateStudentFields();
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load Student Data")));
    }
    setState(() => isDataLoading = false);
  }

  void UpdateStudentFields() async{
    var student = studentData.firstWhere((e) => e["student_id"] == widget.student_id, orElse: () => null);
    if(student != null){
      setState(() {

        String fullName = student["name"];
        List<String> nameParts=fullName.trim().split(RegExp(r'\s+'));
        oldFirstName=nameParts[0];
        if (nameParts.length == 3) {
          oldMiddleName = nameParts[1];
          oldLastName = nameParts[2];
        } else if (nameParts.length == 2) {
          oldMiddleName = "";
          oldLastName = nameParts[1];
        } else {
          oldMiddleName = "";
          oldLastName = "";
        }
        studentFirstNameController.text = oldFirstName;
        studentMiddleNameController.text = oldMiddleName;
        studentLastNameController.text = oldLastName;
        studentContactNoController.text = student["contact_no"];
        studentRollNoController.text = student["roll_no"].toString();

        studentDob = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(student["dob"]);
        studentDobController.text = DateFormat('yyyy-MM-dd').format(studentDob!);
        studentDepartment = student["department"].toString();

      });
      academicYearList = await Modules.FetchAcademicYearList();
      semesterList = await Modules.FetchSemesterList(academicYearId: student["academic_year_id"].toString());
      studentYearList = await Modules.FetchYear(studentDepartment!);
      studentDivisionList = await Modules.FetchDivision(student["class_id"].toString());
      setState(() {
        studentAcademicYear = academicYearList.firstWhere((academic) =>
        academic["academic_year_id"].toString() == student["academic_year_id"].toString(), orElse: ()=>
        null)["academic_year_id"].toString();

        studentSemester = semesterList.firstWhere((sem) =>
        sem["semester_id"].toString() == student["semester_id"].toString(), orElse: () => null)["semester_id"].toString();

        studentClass = studentYearList.firstWhere((year) => year["class_id"].toString() == student["class_id"].toString(),
        orElse: () => null)["class_id"].toString();

        studentDivision = studentDivisionList.firstWhere((div) => div["division_id"].toString() == student["division_id"].toString(),
        orElse: () => null)["division_id"].toString();
      });

    }
  }

  @override
  void initState() {
    super.initState();
    FetchOldData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Student \n   Information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
      backgroundColor: Colors.pink[50],
      body: isDataLoading
          ? Center(child: CircularProgressIndicator())
          :SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: buildAddSingleRecord(),
      ),
    );
  }

  Widget buildAddSingleRecord(){
    return Form(
      key: formKey,
      child: Column(
        children: [

          buildTextFormField("Enter First Name",Icons.person,studentFirstNameController),
          SizedBox(height: 20,),
          buildTextFormField("Enter Middle Name",Icons.person,studentMiddleNameController),
          SizedBox(height: 20,),
          buildTextFormField("Enter Last Name",Icons.person,studentLastNameController),
          SizedBox(height: 20,),

          buildTextFormField("Enter Contact Number",Icons.contact_page,studentContactNoController,
          keyboardType: TextInputType.phone, maxLength: 10),

          SizedBox(height: 20,),
          DropdownButtonFormField<String>(
            value: studentDepartment.toString(),
            decoration: InputDecoration(
                labelText: "Select Department",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
            ),

            items: dept.map((deptValue){
              return DropdownMenuItem(
                value: deptValue.toString(),
                child: Text(deptValue.toString()),
              );
            }).toList(),
            onChanged: (value) async{
              setState(() {
                studentDepartment=value.toString();
              });
              studentYearList = await Modules.FetchYear(studentDepartment);
            },
            validator: (value){
              if(value == null || value.isEmpty) return "Please select department";
              return null;
            },
          ),

          SizedBox(height: 20,),
          buildDropDownButton(labelText: "Select Year", items: studentYearList, selectedValue: studentClass,
              onChanged: (value) async{
            setState(() {
              studentClass=value.toString();
            });
            studentDivisionList = await Modules.FetchDivision(studentClass);
            }, id_name: "class_id", name: "year"),

          SizedBox(height: 20,),
          buildDropDownButton(labelText: "Select Division", items: studentDivisionList, selectedValue: studentDivision,
              onChanged: (value){ setState(() { studentDivision=value; }); },
              id_name: "division_id", name: "division"),

          SizedBox(height: 20,),
          buildDropDownButton(labelText: "Select Academic Year", items: academicYearList, selectedValue: studentAcademicYear,
              onChanged: (value) async{
            setState(() {
              studentAcademicYear = value.toString();
            });
            semesterList = await Modules.FetchSemesterList(academicYearId:studentAcademicYear);
            },
              id_name: "academic_year_id", name: "academic_year"),

          SizedBox(height: 20,),
          buildDropDownButton(labelText: "Select Semester", items: semesterList,
              selectedValue: studentSemester, onChanged: (value) { setState(() { studentSemester = value.toString(); }); },
              id_name: "semester_id", name: "semester_number"),

          SizedBox(height: 20,),
          buildDobField(),

          SizedBox(height: 20,),
          ElevatedButton(
              onPressed: isUpdating ? null : () async{
                String name=studentFirstNameController.text.toString() + " " + studentMiddleNameController.text.toString()
                    + " " + studentLastNameController.text.toString();
                String contact=studentContactNoController.text.toString();
                String rollNo=studentRollNoController.text.toString();
                String formattedDob=studentDob != null ? DateFormat('yyyy-MM-dd').format(studentDob!) : "";

                setState(() {
                  isUpdating = true;
                  isLoading = true;
                });
                bool success = await Modules.updateStudentFacultyData(context, studentDepartment, name, contact, formattedDob, "Student",
                division: studentDivision, year: studentClass, roll_no: rollNo, student_id: widget.student_id.toString(),
                studentAcademicYear: studentAcademicYear, studentSemester: studentSemester);

                setState(() {
                  isUpdating = false;
                  isLoading = false;
                });
                if(success){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student data updated successfully!")));
                  Future.delayed(Duration(seconds: 1), () {Navigator.pop(context);});
                }else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update Student data. Try again!")));
                }
              },
              child: isLoading ? SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text("Update")
          )
        ],
      ),
    );
  }

  Widget buildDropDownButton({required String labelText, required List<dynamic> items,
    required String? selectedValue,  required void Function(dynamic) onChanged, required String? id_name, required String? name }) {
    String? validSelectedValue = items.any((item) => item[id_name].toString() == selectedValue.toString()) ?
    selectedValue.toString() : null;

    return DropdownButtonFormField(
      value: validSelectedValue,
      validator: (value) {
        if(value == null || value.isEmpty) return "Please select $labelText";
        return null;
      },
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: (items ?? []).map((dynamic item){
        return DropdownMenuItem<dynamic>(
            value: item[id_name].toString(),
            child: Text(item[name].toString(),)
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget buildDobField(){
    return TextFormField(
      controller: studentDobController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Select Date of Birth",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: Icon(Icons.calendar_today_outlined),
      ),
      onTap: ()=>SelectDate(context),
      validator: (value){
        if(value == null || value.isEmpty) return "Please select date";
        return null;
      },
    );
  }

  Future<void> SelectDate(BuildContext context) async{
    DateTime? dateSelected= await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      initialDate: DateTime.now(),
      lastDate: DateTime.now(),
    );
    if(dateSelected != null){
      setState(() {
        studentDob=dateSelected;
        studentDobController.text=DateFormat('yyyy-MM-dd').format(dateSelected);
      });
    }
  }

  Widget buildTextFormField(String hintText,IconData icon,TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int? maxLength}){
    return  TextFormField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: (keyboardType == TextInputType.phone)
          ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        hintText: hintText,prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        counterText: maxLength != null ? "" : null,
      ),
      validator: (value){
        if (value == null || value.isEmpty) return hintText;
        if (keyboardType == TextInputType.phone && value.length != 10) return "Contact number must be 10 digits";
        return null;
      },
    );
  }

}



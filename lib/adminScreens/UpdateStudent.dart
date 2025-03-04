import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'ListStudent.dart' as lstd;
import 'package:http/http.dart' as http;

class UpdateStudentScreen extends StatefulWidget {
  final int student_id;
  final List<dynamic> yearList, divisionList;

  const UpdateStudentScreen({super.key, required this.student_id, required this.yearList, required this.divisionList});

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

  String? studentClass, studentDivision, studentDepartment;
  String oldFirstName="", oldLastName="", oldMiddleName="";

  List<dynamic> studentData = [];

  DateTime? studentDob;
  final List<String> dept =["BCA","BBA","BCOM","BSC"];

  late List<dynamic> studentYearList = [];
  late List<dynamic> studentDivisionList = [];

  Future<void> FetchOldData() async{
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load Data")));
    }
  }

  void UpdateStudentFields() async{
    var student = studentData.firstWhere((e) => e["student_id"] == widget.student_id, orElse: () => null);
    if(student != null){
      String fullName = student["name"];
      List<String> nameParts=fullName.split(" ");
      oldFirstName=nameParts[0];
      oldMiddleName=nameParts.length > 2 ? nameParts[1]:"";
      oldLastName=nameParts.length > 2 ? nameParts[2] : nameParts[1];

      // Updating existing controllers
      studentFirstNameController.text = oldFirstName;
      studentMiddleNameController.text = oldMiddleName;
      studentLastNameController.text = oldLastName;
      studentContactNoController.text = student["contact_no"];
      studentRollNoController.text = student["roll_no"].toString();

      studentDob = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(student["dob"]);
      studentDobController.text = DateFormat('yyyy-MM-dd').format(studentDob!);
      studentDepartment = student["department"];

      studentClass = student["year"];
      studentDivision = student["division"];
      setState(() {
        studentYearList = widget.yearList;
        studentDivisionList = widget.divisionList;
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
      body: SingleChildScrollView(
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

          buildTextFormField("Enter Contact Number",Icons.contact_page,studentContactNoController,),

          SizedBox(height: 20,),
          DropdownButtonFormField<String>(
            value: studentDepartment,
            decoration: InputDecoration(
                labelText: "Select Department",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
            ),

            items: dept.map((deptValue){
              return DropdownMenuItem(
                value: deptValue,
                child: Text(deptValue),
              );
            }).toList(),
            onChanged: (value){
              setState(() {
                studentDepartment=value;
                //FetchYear();
              });
            },
            validator: (value){
              if(value == null || value.isEmpty) return "Please select department";
              return null;
            },
          ),

          SizedBox(height: 20,),
          buildDropDownButton(labelText: "Select Year", items: studentYearList, selectedValue: studentClass,
              onChanged: (value){ setState(() { studentClass=value.toString();}); }, id_name: "class_id", name: "year"),

          SizedBox(height: 20,),
          buildDropDownButton(labelText: "Select Division", items: studentDivisionList, selectedValue: studentDivision,
              onChanged: (value){ setState(() { studentDivision=value; }); },
              id_name: "division_id", name: "division"),

          SizedBox(height: 20,),
          buildTextFormField("Enter Roll number",Icons.confirmation_number_outlined,studentRollNoController),
          SizedBox(height: 20,),
          buildDobField(),

          SizedBox(height: 20,),
          ElevatedButton(
              onPressed: (){
                String name=studentFirstNameController.text.toString() + " " + studentMiddleNameController.text.toString()
                    + " " + studentLastNameController.text.toString();
                String contact=studentContactNoController.text.toString();
                String rollNo=studentRollNoController.text.toString();
                String formattedDob=studentDob != null ? DateFormat('yyyy-MM-dd').format(studentDob!) : "";
                Modules.updateStudentFacultyData(context, studentDepartment, name, contact, formattedDob, "Student",
                division: studentDivision, year: studentClass, roll_no: rollNo, student_id: widget.student_id.toString());
                Navigator.pop(context);
              },
              child: Text("Update")
          )
        ],
      ),
    );
  }

  Widget buildDropDownButton({required String labelText, required List<dynamic> items,
    required String? selectedValue,  required void Function(dynamic) onChanged, required String? id_name, required String? name }) {

    String? validSelectedValue = items.any((item) => item[id_name] == selectedValue) ? selectedValue : null;
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
            value: item[id_name],
            child: Text(item[name],
            ));
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

  Widget buildTextFormField(String hintText,IconData icon,TextEditingController controller){
    return  TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value){
        if(value == null || value.isEmpty) return hintText;
        return null;
      },
    );
  }

}



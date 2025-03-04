import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'ListStudent.dart' as lstd;
import 'package:http/http.dart' as http;

class UpdateFacultyScreen extends StatefulWidget {
  final String faculty_id;

  const UpdateFacultyScreen({super.key, required this.faculty_id});

  @override
  State<UpdateFacultyScreen> createState() => _UpdateFacultyScreenState();
}

class _UpdateFacultyScreenState extends State<UpdateFacultyScreen> {

  final formKey=GlobalKey<FormState>();
  var facultyFirstNameController=TextEditingController();
  var facultyLastNameController=TextEditingController();
  var facultyMiddleNameController=TextEditingController();
  var facultyContactNoController=TextEditingController();
  var facultyDobController=TextEditingController();
  List<dynamic> facultyData = [];
  String? facultyDept;
  String oldFirstName="", oldLastName="", oldMiddleName="";
  DateTime? dob;
  final List<String> dept=["BCA","BBA","BCOM","BSC","MCOM","MSC"];

  Future<void> FetchOldData() async{
    final uri=Uri.parse(URL+"/updateFacultyStudentData");
    final response=await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "role":"Faculty",
          "student_id":widget.faculty_id
        })
    );
    if(response.statusCode == 200){
      setState(() {
        facultyData = json.decode(response.body);
      });
      if(facultyData.isNotEmpty){
        UpdateFacultyFields();
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load Data")));
    }
  }

  void UpdateFacultyFields() {
    var faculty = facultyData.firstWhere((e) => e["student_id"] == widget.faculty_id, orElse: () => null);
    if(faculty != null){
      String fullName = faculty["name"];
      List<String> nameParts=fullName.split(" ");
      oldFirstName=nameParts[0];
      oldMiddleName=nameParts.length > 2 ? nameParts[1]:"";
      oldLastName=nameParts.length > 2 ? nameParts[2] : nameParts[1];
      facultyFirstNameController.text = oldFirstName;
      facultyMiddleNameController.text = oldMiddleName;
      facultyLastNameController.text = oldLastName;
      facultyContactNoController.text = faculty["contact_no"];

      dob = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(faculty["dob"]);
      facultyDobController.text = DateFormat('yyyy-MM-dd').format(dob!) ;
      facultyDept=faculty["department"];
      setState(() {});
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
        title: Text("Update Faculty \n   Information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
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

          buildTextFormField("Enter First Name",Icons.person,facultyFirstNameController),
          SizedBox(height: 20,),
          buildTextFormField("Enter Middle Name",Icons.person,facultyMiddleNameController),
          SizedBox(height: 20,),
          buildTextFormField("Enter Last Name",Icons.person,facultyLastNameController),
          SizedBox(height: 20,),
          buildTextFormField("Enter Contact Number",Icons.contact_page,facultyContactNoController),

          SizedBox(height: 20,),
          DropdownButtonFormField<String>(
            value: facultyDept,
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
                facultyDept=value;
              });
            },
            validator: (value){
              if (value == null) return "Please select the department";
              return null;
            },
          ),

          SizedBox(height: 20,),
          buildDobField(),

          SizedBox(height: 20,),
          ElevatedButton(
              onPressed: (){
                if (formKey.currentState!.validate()){
                  String name=facultyFirstNameController.text.toString() + facultyMiddleNameController.text.toString() + facultyLastNameController.text.toString();
                  String contact=facultyContactNoController.text.toString();
                  String formattedDate=dob != null ? DateFormat('yyyy-MM-dd').format(dob!): "";

                  Modules.updateStudentFacultyData(context, facultyDept, name, contact, formattedDate, "Faculty",faculty_id: widget.faculty_id);
                  Navigator.pop(context);
                }
              },
              child: Text("Update")
          )
        ],
      ),
    );
  }

  Widget buildTextFormField(String hintText,IconData icon,TextEditingController controller){
    return  TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value){
        if (value == null || value.isEmpty) return "Please enter the value";
        return null;
      },
    );
  }

  Widget buildDobField(){
    return TextFormField(
      controller: facultyDobController,
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
        dob=dateSelected;
        facultyDobController.text=DateFormat('yyyy-MM-dd').format(dateSelected);
      });
    }
  }

}

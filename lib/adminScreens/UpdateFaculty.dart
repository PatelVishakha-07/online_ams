import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'ListStudent.dart' as lstd;
import 'package:http/http.dart' as http;

class UpdateFacultyScreen extends StatefulWidget {
  final int faculty_id;

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
  bool isDataLoading = false, isLoading = false;
  final List<String> dept=["BCA","BBA","BCOM","BSC"];

  Future<void> FetchOldData() async{
    setState(() => isDataLoading = true);
    final uri=Uri.parse(URL+"/fetchSingleRecord");
    final response=await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "role":"Faculty",
          "faculty_id":widget.faculty_id
        })
    );
    if(response.statusCode == 200){
      setState(() {
        facultyData = json.decode(response.body);
        if(facultyData.isNotEmpty){
          UpdateFacultyFields();
        }
      });
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load Faculty Data")));
    }
    setState(() => isDataLoading = false);
  }

  void UpdateFacultyFields() {
    var faculty = facultyData.firstWhere((e) => e["faculty_id"] == widget.faculty_id, orElse: () => null);
    if(faculty != null){
      String fullName = faculty["faculty_name"] ?? "";
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
      body: isDataLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
          buildTextFormField("Enter Contact Number",Icons.contact_page,facultyContactNoController, keyboardType: TextInputType.phone,
          maxLength: 10),

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
              onPressed: () async{
                if (formKey.currentState!.validate()) {
                  String name= "${facultyFirstNameController.text.toString()} ${facultyMiddleNameController.text.toString()} ${facultyLastNameController.text.toString()}";
                  String contact=facultyContactNoController.text.toString();
                  String formattedDate=dob != null ? DateFormat('yyyy-MM-dd').format(dob!): "";

                  setState(() {
                    isLoading = true;
                  });
                  bool success = await Modules.updateStudentFacultyData(context, facultyDept, name, contact, formattedDate, "Faculty",faculty_id: widget.faculty_id.toString());

                  setState(() {
                    isLoading = false;
                  });
                  if(success){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Faculty data updated successfully!")));
                    Future.delayed(Duration(seconds: 1), () {Navigator.pop(context);});
                  }else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update Faculty data. Try again!")));
                  }
                }
              },
              child: Text("Update")
          )
        ],
      ),
    );
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

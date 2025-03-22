import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class AcademicSetupScreen extends StatefulWidget {
  final String academic_year_id, academic_year;
  const AcademicSetupScreen({super.key, required this.academic_year_id, required this.academic_year});

  @override
  State<AcademicSetupScreen> createState() => _AcademicSetupScreenState();
}

class _AcademicSetupScreenState extends State<AcademicSetupScreen> {

  final TextEditingController semesterNumberController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  int? academic_id;
  bool isLoading = false, isLoadingAcademic = false;

  List<dynamic> academicYears = [];

  Future<void> FetchAcademic() async{
    isLoadingAcademic = true;

    List<dynamic> fetchedYears =await Modules.FetchAcademicYearList();
    setState(() {
      academicYears = fetchedYears;
      isLoadingAcademic = false;
    });
  }

  @override
  void initState() {
    super.initState();
    FetchAcademic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Semester\n (${widget.academic_year})", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.pink.shade50,
      ),
      backgroundColor: Colors.pink.shade50,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
            padding: EdgeInsets.all(12),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 30,),
                isLoadingAcademic ? CircularProgressIndicator():
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: "Select Academic Year",
                    prefixIcon: Icon(Icons.date_range_sharp),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  value: academic_id,
                  hint: Text("Select Academic Year"),
                  items: academicYears.map((year) {
                    return DropdownMenuItem<int>(
                      value: year["academic_year_id"],
                      child: Text(year["academic_year"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      academic_id = value!;
                    });
                  },
                  validator: (value){
                    if(value == null) return "Select Academic Year";
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                buildTextField("Semester Number", Icons.safety_divider, semesterNumberController),
                SizedBox(height: 20,),
                ElevatedButton(
                    onPressed: () async{
                      if(formKey.currentState!.validate()){
                        setState(() {
                          isLoading = true;
                        });
                        await addSemester();
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: isLoading ? CircularProgressIndicator() : Text("Add Semester")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addSemester() async {
    var response = await http.post(
      Uri.parse("$URL/addSemester"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "academic_year_id": academic_id,
        "semester_no": int.tryParse(semesterNumberController.text),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Semester Added!")));
      setState(() {
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add semester")));
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildTextField(String hintText, IconData leadingIcon, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(leadingIcon, color: Colors.redAccent,),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
      validator: (value){
        if(value!.isEmpty || value == null){
          return hintText;
        }
        return null;
      },
    );
  }
}

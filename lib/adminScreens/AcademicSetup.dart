import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class AcademicSetupScreen extends StatefulWidget {
  const AcademicSetupScreen({super.key});

  @override
  State<AcademicSetupScreen> createState() => _AcademicSetupScreenState();
}

class _AcademicSetupScreenState extends State<AcademicSetupScreen> {

  final TextEditingController academicYearController = TextEditingController();
  final TextEditingController semesterNumberController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  int? selectedAcademicYearId;
  final formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> academicYears = [];

  @override
  void initState() {
    super.initState();
    FetchAcademicYears();
  }

  Future<void> FetchAcademicYears() async {
    var response = await http.post(Uri.parse("$URL/fetchAcademicYear"));
    if (response.statusCode == 200) {
      setState(() {
        academicYears = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    }
  }

  Future<void> addAcademicYear() async {
    var response = await http.post(
      Uri.parse("$URL/addAcademicYear"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"academic_year": academicYearController.text}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Academic Year Added!")));
      FetchAcademicYears(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add academic year")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Academic Setup \n     (Admin)"), centerTitle: true, backgroundColor: Colors.pink.shade300,),
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

                Text("Add Academic Year:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                buildTextField("Academic Year", Icons.date_range_outlined, academicYearController),
                SizedBox(height: 30),
                ElevatedButton(onPressed: addAcademicYear, child: Text("Add Academic Year")),

                SizedBox(height: 20),

                Text("Add Semester:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<int>(
                  value: selectedAcademicYearId,
                  hint: Text("Select Academic Year"),
                  items: academicYears.map((year) {
                    return DropdownMenuItem<int>(
                      value: year["academic_year_id"],
                      child: Text(year["academic_year"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAcademicYearId = value;
                    });
                  },
                ),
                buildTextField("Semester Number", Icons.safety_divider, semesterNumberController),
                SizedBox(height: 20,),
                buildDatePicker("Start Date (YYYY-MM-DD)", Icons.hourglass_top_outlined, startDateController),
                SizedBox(height: 20),
                buildDatePicker("End Date (YYYY-MM-DD)", Icons.hourglass_bottom_outlined, endDateController),

                SizedBox(height: 30),
                ElevatedButton(onPressed: addSemester, child: Text("Add Semester")),
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
        "academic_year_id": selectedAcademicYearId,
        "semester_no": int.tryParse(semesterNumberController.text),
        "start_date": startDateController.text,
        "end_date": endDateController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Semester Added!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add semester")));
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

  Widget buildDatePicker(String hintText, IconData leadingIcon, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true, // Prevent manual input
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(leadingIcon, color: Colors.redAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          String formattedDate = pickedDate.toString().split(" ")[0]; // Format: YYYY-MM-DD
          setState(() {
            controller.text = formattedDate;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select a date";
        }
        return null;
      },
    );
  }


}

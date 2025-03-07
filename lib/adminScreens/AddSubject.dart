import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class AddSubjectScreen extends StatefulWidget {
  final String option;
  const AddSubjectScreen({super.key, required this.option});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {

  final formKey = GlobalKey<FormState>();
  TextEditingController subjectNameController = TextEditingController();
  TextEditingController subjectCodeController = TextEditingController();
  String? selectedDepartment, selectedYear, selectedAcademicYear, selectedSemester ;
  var selectedFaculty;
  List<String> academicYearList = [], semesterList = [], yearList = [];
  final List<String> deptList = ["BCA", "BBA", "BCOM", "BSC"];
  late List<dynamic> facultyList=[];
  bool isLoadingFaculty = false, isLoadingYear = false;

  void getSubjectOldDetails(String subName, String subCode, String subYear, String subDept) {
    subjectNameController = TextEditingController(text: subName);
    subjectCodeController = TextEditingController(text: subCode);
    selectedYear = subYear;
    selectedDepartment = subDept;
  }

  Future<void> FetchFacultyList() async {
    if (selectedDepartment == null) return;
    setState(() {
      isLoadingFaculty = true;
    });
    final uri = Uri.parse(URL + "/fetchFacultyNameId");
    final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"department": selectedDepartment})
    );
    if (response.statusCode == 200) {
      setState(() {
        facultyList = jsonDecode(response.body);
        isLoadingFaculty = false;
      });
    } else {
      setState(() {
        facultyList = [];
        isLoadingFaculty = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch faculty list")),); });
    }
  }

  Future<void> FetchYearList() async {
    if (selectedAcademicYear == null) return;
    setState(() {
      isLoadingYear= true;
    });
    final uri = Uri.parse(URL + "fetchYearNameId");
    final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"academic_year": selectedAcademicYear})
    );
    if (response.statusCode == 200) {
      setState(() {
        yearList.clear();
        yearList.addAll(List<String>.from(jsonDecode(response.body)));
        isLoadingYear = false;
      });
    } else {
      setState(() {
        yearList.clear();
        isLoadingYear = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch year list")));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAcademicYears();
  }

  Future<void> fetchAcademicYears() async {
    List<String> years = await Modules.FetchAcademicYearList(); // Ensure this function returns List<String>
    setState(() {
      academicYearList = years;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Subject",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
      backgroundColor: Colors.pink[50],
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(height: 25,),
                buildTextFormField(
                    "Subject Name", Icons.subject_outlined, subjectNameController,
                    TextInputType.text),
                SizedBox(height: 25,),
                buildTextFormField(
                    "Subject Code", Icons.confirmation_number_outlined,
                    subjectCodeController, TextInputType.number),
                SizedBox(height: 25,),

                buildDropDownButton(labelText: "Select Academic Year", items: academicYearList, selectedValue: selectedAcademicYear,
                    onChanged: (value) { setState(() async {
                    selectedAcademicYear = value;
                    selectedSemester = null;
                    FetchYearList();
                    semesterList= await Modules.FetchSemesterList(value!) ;
                  }); }),

                SizedBox(height: 25),
                buildDropDownButton(labelText:  "Select Year", items: yearList, selectedValue: selectedYear, onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                }),

                SizedBox(height: 25,),
                buildDropDownButton(labelText:  "Select Semester", items: semesterList, selectedValue: selectedSemester, onChanged: (value){
                  setState(() {
                    selectedSemester = value;
                  });
                }),

                SizedBox(height: 25,),
                buildDropDownButton(labelText: "Select Department", items: deptList, selectedValue: selectedDepartment, onChanged: (value){
                  setState(() {
                    selectedDepartment = value;
                    selectedFaculty = null;
                    FetchFacultyList();
                  });
                }),

                SizedBox(height: 20,),

                isLoadingFaculty ? CircularProgressIndicator(): DropdownButtonFormField(
                  decoration: InputDecoration(labelText: "Select Faculty",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                  ),
                    items: (facultyList ?? []).map((faculty){
                      return DropdownMenuItem(
                        value: faculty["faculty_id"],
                          child: Text(faculty["faculty_name"])
                      );
                    }).toList(),
                    onChanged: (value){
                      setState(() {
                        selectedFaculty = value;
                      });
                    },
                  value: selectedFaculty,
                  validator: (value){
                      if(value == null ) return "Please select Faculty";
                      return null;
                  },
                ),

                SizedBox(height: 25,),
                ElevatedButton(
                    onPressed: () {
                      if (widget.option == "Add Subject") {
                        if(formKey.currentState!.validate()){
                          SaveSubject();
                          Navigator.pop(context);
                        }
                      } else if (widget.option == "Update Subject") {
                        UpdateSubject();
                        Navigator.pop(context);
                      }
                    },
                    child: widget.option == "Add Subject" ? Text("Add",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),) :
                    Text("Update", style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.red),)
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropDownButton({required String labelText, required List<String> items,
    required String? selectedValue,  required void Function(String?) onChanged}) {
    return DropdownButtonFormField(
      value: selectedValue,
        validator: (value) {
          if(value == null || value.isEmpty) return "Please select $labelText";
          return null;
        },
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((String item){
          return DropdownMenuItem<String>(
              value: item,
              child: Text(item,
              ));
        }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> SaveSubject() async{
    String subjectName = subjectNameController.text.toString();
    String subjectCode = subjectCodeController.text.toString();

    final uri=Uri.parse(URL+"/addSubject");
    final response = await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "subject_name":subjectName,
          "subject_code":subjectCode,
          "subject_department":selectedDepartment,
          "subject_year":selectedYear,
          "faculty_id":selectedFaculty,
          "academic_year_id": selectedAcademicYear,
          "semester_id": selectedSemester
        })
    );
    if(response.statusCode == 200){
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Subject Added Successfully")));

    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Add Subject")));
    }
  }

  Future<void> UpdateSubject() async{
    String subjectName = subjectNameController.text.toString();
    String subjectCode = subjectCodeController.text.toString();

    final uri=Uri.parse(URL+"/updateSubject");
    final response = await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "subject_name":subjectName,
          "subject_code":subjectCode,
          "subject_department":selectedDepartment,
          "subject_year":selectedYear,
          "faculty_id":selectedFaculty,
          "academic_year_id": selectedAcademicYear, // Send Academic Year ID
          "semester_id": selectedSemester
        })
    );
    if(response.statusCode == 200){
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Subject Details Updated Successfully")));

    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Update Subject Details")));
    }
  }

  Widget buildTextFormField(String hintText,IconData icon,TextEditingController controller,TextInputType inputType){
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


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
  List<dynamic> academicYearList = [], semesterList = [], yearList = [];
  final List<String> deptList = ["BCA", "BBA", "BCOM", "BSC"];
  late List<dynamic> facultyList=[];
  bool isLoadingFaculty = false, isLoadingYear = false, isLoadingAcademic = false, isLoadingSemester = false;

  void getSubjectOldDetails(String subName, String subCode, String subYear, String subDept) {
    subjectNameController = TextEditingController(text: subName);
    subjectCodeController = TextEditingController(text: subCode);
    selectedYear = subYear;
    selectedDepartment = subDept;
  }

  Future<void> FetchFacultyList() async {
    if (selectedDepartment == null) return;
    setState(() {
      facultyList.clear();
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
    if (selectedDepartment == null) return;
    setState(() {
      isLoadingYear= true;
    });
    final uri = Uri.parse(URL + "/fetchYearNameId");
    final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"department": selectedDepartment})
    );
    if (response.statusCode == 200) {
      setState(() {
        yearList.clear();
        yearList = json.decode(response.body);
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
    fetchAcademicYears();
    super.initState();
  }

  Future<void> fetchAcademicYears() async {

    setState(() {
      isLoadingAcademic= true;
    });

    List<dynamic> years = await Modules.FetchAcademicYearList();
    setState(() {
      academicYearList = years;
      isLoadingAcademic = false;
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

                DropdownButtonFormField<String>(
                  value: selectedDepartment != "" ? selectedDepartment : null,
                  decoration: InputDecoration(
                      labelText: "Select Department",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  items: deptList.map((deptValue){
                    return DropdownMenuItem(
                      value: deptValue,
                      child: Text(deptValue),
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedDepartment=value.toString();
                    });
                    await FetchFacultyList();
                    await FetchYearList();
                  },
                  validator: (value){
                    if(value == null || value.isEmpty) return "Please select department";
                    return null;
                  },
                ),
                SizedBox(height: 25,),

                isLoadingAcademic ? CircularProgressIndicator():
                buildDropDownButton(labelText: "Select Academic Year", items: academicYearList, selectedValue: selectedAcademicYear,
                    onChanged: (value) async{ setState(() {
                    selectedAcademicYear = value;
                    selectedSemester = null;
                  });
                    semesterList= await Modules.FetchSemesterList(value!) ;
                },id_name: "academic_year_id", name: "academic_year"),

                SizedBox(height: 25),
                isLoadingAcademic ? CircularProgressIndicator():
                buildDropDownButton(labelText:  "Select Year", items: yearList, selectedValue: selectedYear,
                    onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },id_name: "class_id", name: "year"),

                SizedBox(height: 25,),
                isLoadingAcademic ? CircularProgressIndicator():
                buildDropDownButton(labelText: "Select Semester", items: semesterList, selectedValue: selectedSemester,
                    onChanged: (value){
                      setState(() {
                        selectedSemester = value;
                      });
                    }, id_name: "semester_id", name: "semester_number"),

                SizedBox(height: 20,),

                isLoadingFaculty ? CircularProgressIndicator():
                buildDropDownButton(labelText: "Please select Faculty", items: facultyList, selectedValue: selectedFaculty,
                    onChanged: (value){
                          setState(() {
                            selectedFaculty = value;
                          });
                        }, id_name: "faculty_id", name: "faculty_name"),

                SizedBox(height: 25,),
                ElevatedButton(
                    onPressed: () {
                      if (widget.option == "Add Subject") {
                        if(formKey.currentState!.validate()){
                          SaveSubject();
                          //Navigator.pop(context);
                        }
                      } else if (widget.option == "Update Subject") {
                        UpdateSubject();
                       // Navigator.pop(context);
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


  Widget buildDropDownButton({required String labelText, required List<dynamic> items,
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
      items:  (items ?? []).map((dynamic item){
        return DropdownMenuItem<dynamic>(
            value: item[id_name].toString(),
            child: Text(item[name].toString(),)
        );
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
          "class_id":selectedYear,
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


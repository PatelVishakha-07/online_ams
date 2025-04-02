import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class AddSubjectScreen extends StatefulWidget {
  final String option, sub_id;
  const AddSubjectScreen({super.key, required this.option, required this.sub_id});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {

  final formKey = GlobalKey<FormState>();
  TextEditingController subjectNameController = TextEditingController();
  TextEditingController subjectCodeController = TextEditingController();
  String? selectedDepartment, selectedYear, selectedAcademicYear, selectedSemester, yearName;
  var selectedFaculty;
  List<dynamic> academicYearList = [], semesterList = [], yearList = [], academicList = [], divList = [];
  final List<String> deptList = ["BCA", "BBA", "BCOM", "BSC"];
  List<dynamic> facultyList=[], selectedFaculties = [];
  bool isLoadingFaculty = false, isLoadingYear = false, isLoadingAcademic = false, isLoadingSemester = false,
      isLoading = false, isLoadingDivision = false;

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
      yearList.clear();
      isLoadingYear= true;
    });
    yearList = await Modules.FetchYear(selectedDepartment.toString());
    setState(() {
      isLoadingYear = false;
    });
  }

  Future<void> FetchDivision() async{
    final uri = Uri.parse(URL + "/fetchDivision");
    final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"class_id": selectedYear})
    );
    if(response.statusCode == 200){
      var availableDivisions = jsonDecode(response.body);
      if(availableDivisions != null){
        setState(() {
          divList = availableDivisions;
          selectedFaculties = List.filled(divList.length, null);
        });
      }
    }else{
      setState(() {
        divList = [];
        selectedFaculties = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Divisions are allocated to this Class")));
    }
  }

  Future<void> FetchAcademicList() async {
    setState(() {
      academicList.clear();
      isLoadingAcademic = true;
    });
    academicList = await Modules.FetchAcademicYearList();
    setState(() {
      isLoadingAcademic = false;
    });
  }

  Future<void> GetOldSubjectDetails() async{
    final uri = Uri.parse(URL + "/fetchSingleRecord");
    final response = await http.post(uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "role": "Subject",
          "subject_id":widget.sub_id
        })
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> subList = json.decode(response.body);
      setState(() {
        subjectNameController.text = subList["sub_name"] ?? "";
        subjectCodeController.text = subList["sub_code"].toString();
        selectedDepartment = subList["department"];
        selectedYear =subList["semester_id"].toString();
        selectedAcademicYear = subList["academic_year_id"].toString();
        selectedSemester = subList["semester_id"].toString();
        selectedFaculties = subList["faculty_list"] ?? [];

      });
      await FetchAcademicList();
      await FetchYearList();
      semesterList= await Modules.FetchSemesterList(academicYearId: selectedAcademicYear.toString());
      await FetchDivision();
      await FetchFacultyList();
      List<dynamic> oldFacultyList = subList["faculty_list"] ?? [];
      setState(() {
        selectedFaculties = List.filled(divList.length, null);
        for(var oldFaculty in oldFacultyList){
          int divIndex = divList.indexWhere((div) => div["division_id"] == oldFaculty["division_id"]);
          if(divIndex != -1){
            selectedFaculties[divIndex] = oldFaculty["faculty_id"].toString();
          }
        }
      });

      setState(() {
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch subject details")));
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    if(widget.option == "Update Subject"){
      GetOldSubjectDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.option,
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
                    await FetchAcademicList();
                    await FetchYearList();
                    await FetchFacultyList();
                  },
                  validator: (value){
                    if(value == null || value.isEmpty) return "Please select department";
                    return null;
                  },
                ),

                SizedBox(height: 25,),
                isLoadingAcademic ? CircularProgressIndicator():
                    buildDropDownButton(labelText: "Select Academic Year", items: academicList, selectedValue: selectedAcademicYear,
                        onChanged: (value) async{
                      setState(() {
                        selectedAcademicYear = value.toString();
                        isLoadingSemester = true;
                      });
                        }, id_name: "academic_year_id", name: "academic_year"),

                SizedBox(height: 25),
                isLoadingYear ? CircularProgressIndicator():
                buildDropDownButton(labelText:  "Select Year", items: yearList, selectedValue: selectedYear,
                    onChanged: (value) async{
                      setState(() {
                        isLoadingSemester = true;
                      });
                      semesterList= await Modules.FetchSemesterList(academicYearId: selectedAcademicYear.toString());
                  setState(() {
                    isLoadingSemester = false;
                    selectedYear = value;
                    isLoadingDivision = true;
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
                  FetchDivision();
                  selectedFaculties = List.filled(divList.length, null);
                  setState(() {
                    isLoadingDivision = false;
                  });

                },id_name: "class_id", name: "year"),

                SizedBox(height: 25,),
                isLoadingSemester ? CircularProgressIndicator():
                buildDropDownButton(labelText: "Select Semester", items: semesterList, selectedValue: selectedSemester,
                    onChanged: (value){
                      setState(() {
                        selectedSemester = value;
                      });
                    }, id_name: "semester_id", name: "semester_number"),

                SizedBox(height: 20,),

                isLoadingDivision ? CircularProgressIndicator() :
                    Column(
                      children: List.generate(divList.length, (index){
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: buildDropDownButton(labelText: "Select Faculty for Division ${divList[index]["division"]}",
                              items: facultyList, selectedValue: selectedFaculties[index].toString(),
                              onChanged: (value){
                            setState(() {
                              selectedFaculties[index] = value;
                            });
                              }, id_name: "faculty_id", name: "faculty_name")
                        );
                      }),
                    ),

                SizedBox(height: 25,),
                ElevatedButton(
                    onPressed: isLoading
                        ? null // Disable button while loading
                        : () {
                      if (widget.option == "Add Subject") {
                        if(formKey.currentState!.validate()){
                          SaveSubject();
                        }
                      } else if (widget.option == "Update Subject") {
                        if(formKey.currentState!.validate()){
                          UpdateSubject();
                        }
                      }
                    },
                    child: widget.option == "Add Subject" ? Text("Add",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),) :
                    Text("Update", style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.red),)
                ),
                if (isLoading) CircularProgressIndicator(),

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
      value: items.any((item) => item[id_name].toString() == selectedValue) ? selectedValue ?? "" : null,
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
    if (mounted) setState(() => isLoading = true);
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
          //"faculty_id":selectedFaculty,
          "academic_year_id": selectedAcademicYear,
          "semester_id": selectedSemester,
          "faculties_list":List.generate(divList.length, (index) =>{
            "division_id":divList[index]["division_id"],
            "faculty_id":facultyList[index]
          })
        })
    );
    if(response.statusCode == 200){
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Subject Added Successfully")));
      if (mounted) {
        setState(() => isLoading = false);
        Navigator.pop(context);
      }
    }else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Add Subject")));
    }
  }

  Future<void> UpdateSubject() async{
    if (mounted) setState(() => isLoading = true);
    String subjectName = subjectNameController.text.toString();
    String subjectCode = subjectCodeController.text.toString();

    List<Map<String,dynamic>> assignedFaculty = [];
    for(int i=0; i < divList.length; i++){
      if(selectedFaculties[i] != null){
        assignedFaculty.add({
          "division_id":divList[i]["division_id"],
          "faculty_id":selectedFaculties[i]
        });
      }
    }

    final uri=Uri.parse(URL+"/updateSubject");
    final response = await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "subject_id":widget.sub_id,
          "subject_name":subjectName,
          "subject_code":subjectCode,
          "subject_department":selectedDepartment,
          "semester_id": selectedSemester,
          "class_id":selectedYear,
          "faculty_list":assignedFaculty
        })
    );
    if(response.statusCode == 200){
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Subject Details Updated Successfully")));
      if (mounted) {
        setState(() => isLoading = false);
        Navigator.pop(context);
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Update Subject Details")));
      if (mounted) {
        setState(() => isLoading = false);
      }
    }

  }

  Widget buildTextFormField(String hintText,IconData icon,TextEditingController controller,TextInputType inputType){
    return  TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      inputFormatters: (inputType == TextInputType.number)
          ? [FilteringTextInputFormatter.digitsOnly] :
      [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z ]*$'))],
      validator: (value){
        if(value == null || value.isEmpty) return hintText;
        return null;
      },
    );
  }

}


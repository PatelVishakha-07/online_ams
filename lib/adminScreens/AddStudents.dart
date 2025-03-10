import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {

  final formKey=GlobalKey<FormState>();
  String? oldName, oldRollNo, oldDob, oldContact, oldYear, oldDept, oldDivision;
  String? filename;
  File? selectedFile;
  String? selectedOption="Add Single Record";
  var studentFirstNameController=TextEditingController();
  var studentMiddleNameController=TextEditingController();
  var studentLastNameController=TextEditingController();
  var studentContactNoController=TextEditingController();
  var studentDobController=TextEditingController();
  var studentRollNoController=TextEditingController();
  String? studentClass ="", studentDivision="", studentDepartment="", studentSemester="", studentAcademicYear="";
  DateTime? studentDob;
  late List<dynamic> yearList = [], divisionList = [], semesterList = [], academicYearList = [];
  bool isLoadingYear = false, isLoadingDivision = false, isLoadingSemester = false, isLoadingAcademicYear = false, isUploading = false;

  final List<String> deptList =["BCA","BBA","BCOM","BSC","MSC","MCOM"];

  Future<void> FetchYear() async{
    if(studentDepartment == null) return;
    setState(() {
      isLoadingYear = true;
    });
    final uri =Uri.parse(URL+"/fetchYearNameId");
    final response = await http.post(
        uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({"department":studentDepartment})
    );
    if(response.statusCode == 200){
      setState(() {
        yearList = json.decode(response.body);
        isLoadingYear = false;
      });
    }else{
      setState(() {
        yearList = [];
        isLoadingYear = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch Year list")),);
      });
    }
  }

  Future<void> FetchDivision() async{
    if(studentClass == null) return;
    setState(() {
      isLoadingDivision = true;
    });
    final uri =Uri.parse(URL+"/fetchDivisionNameId");
    final response = await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({"class_id":studentClass})
    );
    if(response.statusCode == 200){
      setState(() {
        divisionList = json.decode(response.body);
        isLoadingDivision = false;
      });
    }else{
      setState(() {
        divisionList = [];
        isLoadingDivision = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch Division list")),);
      });
    }
  }

  Future<void> FetchSemesters(String academic_year) async {
    setState(() => isLoadingSemester = true);
    final uri = Uri.parse("$URL/fetchSemesters");
    final response = await http.post(uri, 
        headers: {"Content-Type": "application/json"},
      body: jsonEncode({"academic_year_id":academic_year})
    );
    setState(() {
      if (response.statusCode == 200) {
        semesterList = json.decode(response.body);
      } else {
        semesterList = [];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch Semesters")));
      }
      isLoadingSemester = false;
    });
  }

  Future<void> FetchAcademicYears() async {
    setState(() => isLoadingAcademicYear = true);
    final uri = Uri.parse("$URL/fetchAcademicYear");
    final response = await http.post(uri, headers: {"Content-Type": "application/json"});

    setState(() {
      if (response.statusCode == 200) {
        academicYearList = json.decode(response.body);
      } else {
        academicYearList = [];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch Academic Years")));
      }
      isLoadingAcademicYear = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[50],
        title: Text("Add Students\n    (Admin)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
      ),
      backgroundColor: Colors.pink[50],
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text("Select type: ",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildRadioButton("Add Single Record"),
                  buildRadioButton("Add Excel File"),
                ],
              ),
              SizedBox(height: 20,),
              if(selectedOption == "Add Single Record")...[
                buildAddSingleRecord()
              ]else...[
                Center(
                  child: GestureDetector(
                    child: Container(
                      width: 300,height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey,width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload,size: 50, color: Colors.blueGrey,),
                          SizedBox(height: 10,),
                          Text(
                            filename ?? "Upload Excel File",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                    onTap:PickExcelFile,
                  ),
                ),
                SizedBox(height: 20,),
                if (selectedFile != null)
                  isUploading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: uploadExcelFile,
                    child: Text("Upload and Save File"),
                  )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future<void> insertStudentData() async{
    String studentFirstName= studentFirstNameController.text.toString();
    String studentMiddleName=studentMiddleNameController.text.toString();
    String studentLastName=studentLastNameController.text.toString();
    String studentContactNo=studentContactNoController.text.toString();
    String studentDept=studentDepartment.toString();
    String studentRollNo=studentRollNoController.text.toString();
    String studentbirthDate=studentDobController.text.toString();

    final uri=Uri.parse(URL+"/addSingleRecord");
    final response = await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "role":"Student",
          "first_name":studentFirstName,
          "middle_name":studentMiddleName,
          "last_name":studentLastName,
          "roll_no":studentRollNo,
          "contact_no":studentContactNo,
          "department":studentDept,
          "dob":studentbirthDate,
          "class_id":studentClass,
          "division_id":studentDivision,
          "semester_id": studentSemester,
          "academic_year_id": studentAcademicYear
        })
    );

    if(response.statusCode == 200){
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data inserted successfully")));
      studentFirstNameController.clear();
      studentMiddleNameController.clear();
      studentLastNameController.clear();
      studentDobController.clear();
      studentContactNoController.clear();
      studentRollNoController.clear();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to insert data")));
    }
  }

  Widget buildRadioButton(String type){
    return Row(
      children: [
        Radio(
            value: type,
            groupValue: selectedOption,
            onChanged: (value){
              setState(() {
                selectedOption = value;
              });
            }
        ),
        Text(type,style: TextStyle(fontSize: 20),)
      ],
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
            value: studentDepartment != "" ? studentDepartment : null,
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
            onChanged: (value){
              setState(() {
                studentDepartment=value.toString();
                FetchYear();
              });
            },
            validator: (value){
              if(value == null || value.isEmpty) return "Please select department";
              return null;
            },
          ),

          SizedBox(height: 20,),
          isLoadingYear ? CircularProgressIndicator() :
          buildDropDownButton(labelText: "Select Year", items: yearList, selectedValue: studentClass,
              onChanged: (value){
            setState(() {
                studentClass = value.toString();
                FetchDivision();
                FetchAcademicYears();
              });}, id_name: "class_id",name: "year"),

          SizedBox(height: 20,),
          isLoadingDivision ? CircularProgressIndicator() :
          buildDropDownButton(labelText: "Select Division", items: divisionList, selectedValue: studentDivision,
              onChanged: (value){setState(() {
                studentDivision = value.toString();
              });}, id_name: "division_id", name: "division"),

          SizedBox(height: 20,),
          isLoadingAcademicYear ? CircularProgressIndicator() :
          buildDropDownButton(labelText: "Select Academic Year", items:  academicYearList, selectedValue:  studentAcademicYear,
              onChanged: (value) { setState(() {
                studentAcademicYear = value.toString();
                FetchSemesters(studentAcademicYear.toString());
              });}, id_name: "academic_year_id", name: "academic_year"),

          SizedBox(height: 20,),
          isLoadingSemester ? CircularProgressIndicator() :
          buildDropDownButton(labelText: "Select Semester", items: semesterList, selectedValue:  studentSemester,
              onChanged:  (value) { setState(() {
              studentSemester = value.toString();
            });}, id_name:  "semester_id", name:  "semester_number"),


          SizedBox(height: 20,),
          buildTextFormField("Enter Roll number",Icons.confirmation_number_outlined,studentRollNoController),
          SizedBox(height: 20,),
          buildDobField(),

          SizedBox(height: 20,),
          ElevatedButton(
              onPressed: (){
                if(formKey.currentState!.validate()){
                  insertStudentData();
                }
                //Navigator.pop(context);
              },
              child: Text("Add")
          )
        ],
      ),
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

  Future<void> PickExcelFile() async{
    FilePickerResult? result= await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx','csv', 'xls']
    );

    if(result != null && result.files.isNotEmpty){
      setState(() {
        selectedFile=File(result.files.single.path!);
        filename=result.files.single.name;
      });
    }
  }

  Future<void> uploadExcelFile() async{
    if(selectedFile == null) return;

    setState(() {
      isUploading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(URL+"/upload")
    );
    request.files.add(await http.MultipartFile.fromPath('file', selectedFile!.path));
    var response = await request.send();

    setState(() {
      isUploading = false;
    });

    if(response.statusCode == 200 ){
      setState(() {
        filename=null;
        selectedFile=null;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("File Uploaded Successfully")));
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload Failed")));
    }
  }
}

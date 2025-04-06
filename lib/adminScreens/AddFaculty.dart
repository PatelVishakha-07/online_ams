import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';

class AddFacultyScreen extends StatefulWidget {
  const AddFacultyScreen({super.key});

  @override
  State<AddFacultyScreen> createState() => _AddFacultyScreenState();
}

class _AddFacultyScreenState extends State<AddFacultyScreen> {

  final formKey=GlobalKey<FormState>();
  String? filename;
  File? selectedFile;
  String? selectedOption="Add Single Record";
  var facultyFirstNameController=TextEditingController();
  var facultyLastNameController=TextEditingController();
  var facultyMiddleNameController=TextEditingController();
  var facultyContactNoController=TextEditingController();
  var facultyDobController=TextEditingController();
  String? facultyDept;
  DateTime? dob;
  final List<String> dept=["BCA","BBA","BCOM","BSC"];
  bool isLoading = false, isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Faculty",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.pink.shade50,
        centerTitle: true,
      ),
      backgroundColor: Colors.pink.shade50,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text("Select type: ",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildRadioButton("Add Single Record"),
                    buildRadioButton("Add Excel File"),
                  ],
                ),
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

        buildTextFormField("Enter First Name",Icons.person,facultyFirstNameController, keyboardType: TextInputType.name),
        SizedBox(height: 20,),
        buildTextFormField("Enter Middle Name",Icons.person,facultyMiddleNameController, keyboardType: TextInputType.name),
        SizedBox(height: 20,),
        buildTextFormField("Enter Last Name",Icons.person,facultyLastNameController, keyboardType: TextInputType.name),
        SizedBox(height: 20,),
        buildTextFormField("Enter Contact Number",Icons.contact_page,facultyContactNoController,
        keyboardType: TextInputType.phone, maxLength: 10),

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
              if (formKey.currentState!.validate()){
                setState(() {
                  isLoading = true;
                });
                String msg = await insertFacultyData();
                setState(() {
                  isLoading = false;
                });
                if(msg == "success"){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Faculty added successfully!")));
                  Future.delayed(Duration(seconds: 1), () { Navigator.pop(context); });
                }else if(msg == "exists"){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Faculty record already exists.")));
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add Faculty. Try again!")));
                }
              }
            },
            child: isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text("Add"),
        )
      ],
    ),
  );
}

Future<String> insertFacultyData() async{
    String facultyFirstName=facultyFirstNameController.text.toString();
    String facultyMiddleName=facultyMiddleNameController.text.toString();
    String facultyLastName=facultyLastNameController.text.toString();
    String facultyContactNo=facultyContactNoController.text.toString();
    String facultyDepartment=facultyDept.toString();
    String facultyDob=facultyDobController.text.toString();
    final uri=Uri.parse(URL+"/addSingleRecord");
    final response = await http.post(
      uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "role":"Faculty",
        "first_name":facultyFirstName,
        "middle_name":facultyMiddleName,
        "last_name":facultyLastName,
        "contact_no":facultyContactNo,
        "department":facultyDepartment,
        "dob":facultyDob
      })
    );
    if(response.statusCode == 200){
      facultyFirstNameController.clear();
      facultyMiddleNameController.clear();
      facultyLastNameController.clear();
      facultyContactNoController.clear();
      facultyDobController.clear();
      facultyDept = null;
      return "success";
    }else if(response.statusCode == 401){
      return "exists";
    }
    else{
      return "failed";
    }
}

  Widget buildTextFormField(String hintText,IconData icon,TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int? maxLength}){
    return  TextFormField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: (keyboardType == TextInputType.phone)
          ? [FilteringTextInputFormatter.digitsOnly] :
      [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z ]*$'))],
      decoration: InputDecoration(
        hintText: hintText,prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        counterText: maxLength != null ? "" : null,
      ),
      validator: (value){
        if (value == null || value.isEmpty) return hintText;
        if (keyboardType == TextInputType.phone) {
          final RegExp indianNumberRegExp = RegExp(r'^[6789]\d{9}$');
          if (!indianNumberRegExp.hasMatch(value)) {
            return "Enter a valid Indian number (10 digits, starts with 6-9)";
          }
        }

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

Future<void> PickExcelFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv']
  );

  if (result != null && result.files.isNotEmpty) {
    setState(() {
      selectedFile = File(result.files.single.path!);
      filename = result.files.single.name;
    });
  }
}

Future<void> uploadExcelFile() async {
    if (selectedFile == null) return;
    setState(() {
      isUploading = true;
    });

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(URL + "/upload")
    );
    request.files.add(
        await http.MultipartFile.fromPath('file', selectedFile!.path));
    var response = await request.send();
    setState(() {
      isUploading = false;
    });

    if (response.statusCode == 200) {
      setState(() {
        filename = null;
        selectedFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("File Uploaded Successfully")));
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload Failed")));
    }
  }
  
}


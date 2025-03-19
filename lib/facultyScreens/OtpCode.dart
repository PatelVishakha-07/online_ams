import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:online_ams/Modules.dart' ;
import 'package:flutter/material.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;
import 'package:online_ams/studentScreens/Attendance.dart';

class OTPScreen extends StatefulWidget {
  final int faculty_id;
  const OTPScreen({super.key, required this.faculty_id});

  @override
  State<OTPScreen> createState() => _OTPScrState();
}

class _OTPScrState extends State<OTPScreen> {

  final formKey = GlobalKey<FormState>();
  List<dynamic> subjectList = [], yearList = [], divisionList = [];
  late Future<List<dynamic>> facultyDetails;
  bool isLoadingYear = false, isLoadingDivision = false, isLoading = false;
  List<String> departmentList = ["BCA", "BBA", "BCOM", "BSC", "MSC", "MCOM"];
  String? facultyDepartment = "", selectedYear, selectedDivision, selectedSubject;

  TextEditingController locationController = TextEditingController();
  TextEditingController validTimeController = TextEditingController();


  Future<void> FetchSubjectList() async{
    final uri = Uri.parse("$URL/fetchSubject");
    final response = await http.post(
      uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "faculty_id":widget.faculty_id,
        "role":"Faculty",
        "class_id":selectedYear
      })
    );
    if(response.statusCode == 200){
      subjectList = json.decode(response.body);
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch Subject list")));
    }
  }

  Future<void> FetchYear() async{

    if(facultyDepartment == null ){
      isLoadingYear = true;
    }
    final uri =Uri.parse(URL+"/fetchYearNameId");
    final response = await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({"department":facultyDepartment})
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
    if(selectedYear == null) return;
    setState(() {
      isLoadingDivision = true;
    });
    final uri =Uri.parse(URL+"/fetchDivisionNameId");
    final response = await http.post(
        uri,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({"class_id":selectedYear})
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


  @override
  void initState() {
    super.initState();
    facultyDetails = Modules.FetchSingleData("Faculty",faculty_id: widget.faculty_id.toString());
    facultyDetails.then((details){
      if(details.isNotEmpty){
        setState(() {
          facultyDepartment = details[0]["department"];
          FetchYear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Code for Attendance",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
        centerTitle: true,
        backgroundColor: Colors.pink.shade50,
      ),
      backgroundColor: Colors.pink.shade50,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [

                  Text("Department: $facultyDepartment",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),

                  SizedBox(height: 20,),
                  isLoadingYear ? CircularProgressIndicator() :
                  buildDropDownButton(labelText: "Select Year", items: yearList, selectedValue: selectedYear,icon: Icons.class_outlined,
                      onChanged: (value){ setState(() {
                        selectedYear=value.toString();
                        FetchDivision();
                        FetchSubjectList();
                      }); }, id_name: "class_id", name: "year"),

                  SizedBox(height: 20,),
                  isLoadingDivision ? CircularProgressIndicator() :
                  buildDropDownButton(labelText: "Select Division", items: divisionList, selectedValue: selectedDivision,
                      onChanged: (value){ setState(() { selectedDivision=value.toString(); }); },
                      id_name: "division_id", name: "division", icon: Icons.splitscreen),

                  SizedBox(height: 20,),
                  buildDropDownButton(labelText: "Select Subject", items: subjectList, selectedValue: selectedSubject, icon: Icons.subject_outlined,
                      onChanged: (value){ setState(() { selectedSubject=value.toString(); }); },
                      id_name: "subject_id", name: "sub_name"),

                  SizedBox(height: 20,),
                  buildTextFormField(validTimeController, "Enter valid time (in minutes)", Icons.timer_outlined),

                  SizedBox(height: 20,),
                  buildTextFormField(locationController, "Enter area ", Icons.my_location),

                  SizedBox(height: 40,),
                  ElevatedButton(
                      onPressed: () async{
                        if(!formKey.currentState!.validate()) return;
                        setState(() {
                          isLoading = true;
                        });
                        Future.delayed(Duration.zero, (){
                          showDialog(
                            context: context,
                            barrierDismissible: false, // Prevent dismissing by tapping outside
                            builder: (context) {
                              return AlertDialog(
                                content: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 15),
                                    Text("Generating OTP..."),
                                  ],
                                ),
                              );
                            },
                          );
                        });

                        String otp_code = GenerateOtp();
                        String created_at = DateTime.now().toString();
                        int validMinutes = int.parse(validTimeController.text.toString());
                        String expiry_time = DateTime.now().add(Duration(minutes: validMinutes)).toString();
                        Position? facultyLocation = await Modules.GetCurrentLocation();
                        double faculty_latitude = facultyLocation!.latitude;
                        double faculty_longitude = facultyLocation!.longitude;
                        String areaSize = locationController.text.toString();

                        await Modules.SaveOtp(context, otp_code, int.parse(selectedYear!), widget.faculty_id, int.parse(selectedDivision!), created_at,
                           expiry_time, int.parse(selectedSubject!),faculty_latitude.toString(),faculty_longitude.toString(),areaSize);

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                        showOtpDialog(otp_code);

                        setState(() {
                          isLoading = false;
                        });


                      },
                      child: Text("Submit",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 23),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent.shade100,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                  ),

                ],
              ),
            )
        ),
      )
    );
  }

  String GenerateOtp(){
    Random randomNumber = Random();
    int code = 1000 + randomNumber.nextInt(9000);
    return code.toString();
  }

  void showOtpDialog(String otp_code){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
            title: Column(
              children: [
                Icon(Icons.lock_outline, color: Colors.blue),
                SizedBox(width: 10),
                Text("Attendance Code", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("$otp_code", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                SizedBox(height: 10),
                Text("Provide this code to Student to mark their attendance.",
                  style: TextStyle(color: Colors.grey), textAlign: TextAlign.center,),
              ],
            ),
            elevation: 4,
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text("OK", style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          );
    });
  }



  Widget buildDropDownButton({required String labelText, required List<dynamic> items, required IconData icon,
    required String? selectedValue,  required void Function(dynamic) onChanged, required String? id_name, required String? name }) {
    return DropdownButtonFormField(
      value: items.any((item) => item[id_name] == selectedValue) ? selectedValue : null,
      validator: (value) {
        if(value == null || value.isEmpty) return "Select $labelText";
        return null;
      },
      decoration: InputDecoration(
        icon: Icon(icon),
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: (items ?? []).map((dynamic item){
        return DropdownMenuItem<dynamic>(
            value: item[id_name],
            child: Text(item[name],)
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget buildTextFormField(TextEditingController controller, String labelText, IconData icon){
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        icon: Icon(icon)
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value){
        if(value == null || value.isEmpty)return labelText;
        return null;
      },
    );
  }
}

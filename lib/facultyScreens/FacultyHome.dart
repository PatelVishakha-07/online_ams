import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/facultyScreens/FacultySubjectList.dart';
import 'package:online_ams/facultyScreens/OtpCode.dart';
import 'package:online_ams/facultyScreens/StudentReport.dart';

class FacultyHomeScreen extends StatefulWidget {
  final String username;
  const FacultyHomeScreen({super.key, required this.username});

  @override
  State<FacultyHomeScreen> createState() => _FacultyHomeScreenState();
}

class _FacultyHomeScreenState extends State<FacultyHomeScreen> {

  String todayDate=DateFormat('dd MMMM yyyy').format(DateTime.now());
  String todayDay=DateFormat('EEEE').format(DateTime.now());

  int? faculty_id;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    FetchDetails();
  }

  void FetchDetails() async{
    await Modules.FetchId(widget.username,"Faculty").then((id){
      setState(() {
        faculty_id = id;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    if (faculty_id == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<Map<String,dynamic>> facultyItems=[
      {"title":"Generate Code","icon":Icons.password,"route":OTPScreen(faculty_id: faculty_id!,)},
      {"title":"View Subject","icon":Icons.remove_red_eye_outlined,"route":FacultySubjectList(faculty_id: faculty_id!, )},
      {"title":"View Student\n   Report","icon":Icons.file_copy_outlined,"route":"student_report" },
    ];

    void ShowSubjectDialog() async{
      String? subjectSelected;
      Future<List<dynamic>> subjectList = Modules.FetchSubjectList(role: "Faculty", faculty_id: faculty_id);

      showDialog(
        barrierDismissible: false,
          context: context,
          builder: (context) => StatefulBuilder(builder: (context, setState){
            return AlertDialog(
              title: Text("Select Subject: ", style: TextStyle(fontWeight: FontWeight.bold),),
              content: FutureBuilder<List<dynamic>>(
                  future: subjectList,
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);
                    else if(snapshot.hasError) return Center(child: Text("Error ${snapshot.error}"),);
                    else if(!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No Subject Found"),);

                    List<dynamic> items = snapshot.data!;
                    return Form(
                      key: formKey,
                      child: DropdownButtonFormField<dynamic>(
                        hint: Text("subject name"),
                        value: subjectSelected,
                        items: items.map((subject){
                          return DropdownMenuItem<String>(
                            value: subject["subject_id"].toString(),
                            child: Text(subject["sub_name"].toString()),
                          );
                        }).toList(),
                        onChanged: (value){
                          setState((){
                            subjectSelected = value.toString();
                          });
                        },
                        validator: (value){
                          if(value == null){
                            return "Select Subject";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(labelText: "Select Subject"),
                      ),
                    );
                  }
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if(formKey.currentState!.validate()){
                      String subject_id = subjectSelected.toString();

                      await Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          StudentReportScreen(faculty_id: faculty_id.toString(), subject_id: subject_id,)));

                      if(mounted) Navigator.pop(context);
                    }
                  },
                  child:Text("Submit"),
                ),
              ],

            );
          })
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard\n   (Faculty)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                FetchDetails();
              });
            },
            icon: Icon(Icons.refresh_outlined, color: Colors.blue),
            tooltip: "Reload",
          ),

          IconButton(
              onPressed: (){
                Modules.showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, color: Colors.red),
          )
        ],
      ),
      backgroundColor: Colors.pink.shade50,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(height: 20,),
            Card(
                color: Colors.blue.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 4,
                child: SizedBox(
                    height: 90,
                    width: 390,
                    child: Center(
                        child: Text(todayDay+"\n"+todayDate,style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                    )
                )
            ),
            SizedBox(height: 20,),
            Expanded(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16
                  ),
                  itemCount: facultyItems.length,
                  itemBuilder: (context,index){
                    return GestureDetector(
                      onTap: (){
                        if(facultyItems[index]["route"] == "student_report"){
                          ShowSubjectDialog();
                        }else{
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>facultyItems[index]["route"]));
                        }
                      },
                      child: Card(
                        color: Colors.blue[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(facultyItems[index]["icon"],size: 50,color: Colors.redAccent,),
                            SizedBox(height: 10,),
                            Text(facultyItems[index]["title"],style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,))
                          ],
                        ),
                      ),
                    );
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }

}


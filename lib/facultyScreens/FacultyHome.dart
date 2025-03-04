import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/adminScreens/ListSubject.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:online_ams/facultyScreens/FacultySubjectList.dart';
import 'package:online_ams/facultyScreens/OtpCode.dart';
import 'package:http/http.dart' as http;


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

  @override
  void initState() {
    super.initState();
    FetchFacultyId(widget.username).then((id){
      setState(() {
        faculty_id = id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (faculty_id == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // Show loading
      );
    }

    List<Map<String,dynamic>> facultyItems=[
      {"title":"Generate Code","icon":Icons.password,"route":OTPScreen(faculty_id: faculty_id!,)},
      {"title":"View Subject","icon":Icons.remove_red_eye_outlined,"route":FacultySubjectList(faculty_id: faculty_id!, )},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard\n   (Faculty)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
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
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>facultyItems[index]["route"]));
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


Future<int> FetchFacultyId(String username) async{
  final uri=Uri.parse("$URL/fetchId");
  final response = await http.post(
      uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "username":username,
        "role":"Faculty"
      })
  );
  if(response.statusCode == 200){
    return json.decode(response.body);
  }
  return 0;
}

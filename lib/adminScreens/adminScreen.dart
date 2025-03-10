import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/adminScreens/AcademicSetup.dart';
import 'package:online_ams/adminScreens/Faculty.dart';
import 'package:online_ams/adminScreens/ListDetails.dart';
import 'package:online_ams/adminScreens/Students.dart';
import 'package:online_ams/adminScreens/Subject.dart';

var URL="https://350b-2409-4080-948c-7c17-bd75-666e-eac7-c1c7.ngrok-free.app";

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

    List<Map<String,dynamic>> dashboardItems=[
      {"Title":"Academic Setup", "Icon":Icons.school, "route": AcademicSetupScreen()},
      {"Title":"Class", "Icon":Icons.class_, "route": ListScreen(option:"Class")},
      {"Title":"Faculty", "Icon":Icons.person, "route": FacultyScreen()},
      {"Title":"Student", "Icon":Icons.people, "route": StudentScreen()},
      {"Title":"Subject", "Icon":Icons.subject_outlined, "route": SubjectScreen()},
      {"Title":"Change Password", "Icon":Icons.lock_outline, "route": ""},
    ];

  @override
  Widget build(BuildContext context) {
      String todayDate=DateFormat('dd MMMM yyyy').format(DateTime.now());
      String todayDay=DateFormat('EEEE').format(DateTime.now());
      
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard\n   (Admin)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
      backgroundColor: Colors.pink.shade50,
      body: Padding(
          padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: 50,),
            Expanded(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16
                  ),
                  itemCount: dashboardItems.length,
                  itemBuilder: (context,index){
                    return GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> dashboardItems[index]["route"]));
                      },
                      child: Card(
                        color: Colors.blue.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(dashboardItems[index]["Icon"],size: 50,color: Colors.redAccent,),
                            SizedBox(height: 15,),
                            Text(dashboardItems[index]["Title"],style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

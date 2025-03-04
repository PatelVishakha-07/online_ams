import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/adminScreens/AddStudents.dart';
import 'package:online_ams/adminScreens/ListDetails.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  List<Map<String,dynamic>> studentItems=[
    {"title":"View Students","icon":Icons.remove_red_eye_outlined,"route":
    ListScreen(option: "Student",)},
    {"title":"Add Students","icon":Icons.people_alt_outlined,"route":AddStudentScreen()},
  ];

  String todayDate=DateFormat('dd MMMM yyyy').format(DateTime.now());
  String todayDay=DateFormat('EEEE').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard\n   (Admin)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
      backgroundColor: Colors.pink[50],
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
                  itemCount: studentItems.length,
                  itemBuilder: (context,index){
                    return GestureDetector(
                      onTap: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>studentItems[index]["route"]));
                      },
                      child: Card(
                        color: Colors.blue[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(studentItems[index]["icon"],size: 50,color: Colors.redAccent,),
                            SizedBox(height: 10,),
                            Text(studentItems[index]["title"],style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,))
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

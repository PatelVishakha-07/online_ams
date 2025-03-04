import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/adminScreens/AddFaculty.dart';
import 'package:online_ams/adminScreens/ListDetails.dart';

class FacultyScreen extends StatefulWidget {
  const FacultyScreen({super.key});

  @override
  State<FacultyScreen> createState() => _FacultyScreenState();
}

class _FacultyScreenState extends State<FacultyScreen> {
  List<Map<String,dynamic>> facultyItems=[
    {"title":"View Faculty","icon":Icons.remove_red_eye_outlined,"route":ListScreen(option: "Faculty",)},
    {"title":"Add Faculty","icon":Icons.people_alt_outlined,"route":AddFacultyScreen()},
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

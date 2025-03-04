import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_ams/adminScreens/Faculty.dart';
import 'package:online_ams/adminScreens/ListDetails.dart';
import 'package:online_ams/adminScreens/Students.dart';
import 'package:online_ams/adminScreens/Subject.dart';

var URL="https://a136-2409-4080-9480-46ec-309e-5194-1f96-4db0.ngrok-free.app";

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

    List<Map<String,dynamic>> dashboardItems=[
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

/*
  void showRemoveClassAlertDialog(){
    String? classNameToRemove;
    String? divisionNameToRemove;
      showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              backgroundColor: Colors.indigoAccent.shade100,
              elevation: 4,
              title: Text("Remove Class"),
              icon: Icon(Icons.delete),
              actions: [
                TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Cancel")),
                ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text("Remove"),
                )
              ],
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField(
                    decoration: InputDecoration(labelText: "Select Class: "),
                      value: classNameToRemove,
                      items: className.map((classRemoved){
                        return DropdownMenuItem(
                          child: Text(classRemoved),
                          value: classRemoved,
                        );
                      }).toList(),
                      onChanged: (value){
                        setState(() {
                          classNameToRemove=value as String?;
                        });
                      }
                  ),
                  SizedBox(height: 20,),
                  DropdownButtonFormField(
                      decoration: InputDecoration(labelText: "Select Division: "),
                      value: divisionNameToRemove,
                      items: division.map((divisionRemoved){
                        return DropdownMenuItem(
                          child: Text(divisionRemoved),
                          value: divisionRemoved,
                        );
                      }).toList(),
                      onChanged: (value){
                        setState(() {
                          divisionNameToRemove=value as String?;
                        });
                      }
                  ),
                ],
              ),
            );
          }
      );
  }

  void showAddFacultyAlertDialog(){

      var facultyNameController=TextEditingController();
      var facultyContactNoController=TextEditingController();
      var facultyClassSelected=[];

      showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              backgroundColor: Colors.indigoAccent.shade100,
              icon: Icon(Icons.add),
              title: Text("Add Faculty"),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text("Cancel")),
                ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text("Add")
                )
              ],
              elevation: 4,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  TextFormField(
                    decoration: InputDecoration(hintText: "Enter Faculty Name ",),
                    keyboardType: TextInputType.text,
                    controller: facultyNameController,
                  ),
                  SizedBox(height: 15,),

                  TextFormField(
                    decoration: InputDecoration(hintText: "Enter Contact Number ",),
                    keyboardType: TextInputType.text,
                    controller: facultyContactNoController,
                  ),
                  SizedBox(height: 15,),

                  MultiSelectDialogField(
                      items: className.map((e)=> MultiSelectItem(e, e)).toList(),
                      title: Text("Select Class: "),
                      selectedColor: Colors.green,
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Colors.black,width: 2)),
                      buttonIcon: Icon(Icons.arrow_drop_down,color: Colors.black,),
                      buttonText: Text("Choose Options"),
                      onConfirm: (values){
                        setState(() {
                          facultyClassSelected=values.cast<String>();
                        });
                      }
                  )
                ],
              ),
            );
          }
      );
  }

  void showRemoveFacultyAlertDialog(){

      var removeFacultyNameController=TextEditingController();
      var removeFacultyContactNoController=TextEditingController();

      showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              backgroundColor: Colors.indigoAccent.shade100,
              icon: Icon(Icons.add),
              title: Text("Remove Faculty"),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text("Cancel")),
                ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text("Remove")
                )
              ],
              elevation: 4,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  TextFormField(
                    decoration: InputDecoration(hintText: "Enter Faculty Name ",),
                    keyboardType: TextInputType.text,
                    controller: removeFacultyNameController,
                  ),
                  SizedBox(height: 15,),

                  TextFormField(
                    decoration: InputDecoration(hintText: "Enter Contact Number ",),
                    keyboardType: TextInputType.text,
                    controller: removeFacultyContactNoController,
                  ),
                  SizedBox(height: 15,),

                ],
              ),
            );
          }
      );
    }
*/
}

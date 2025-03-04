import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/StudentDetails.dart';
import 'package:online_ams/adminScreens/UpdateStudent.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'ListDetails.dart' as ld;
import 'package:http/http.dart' as http;
import 'UpdateStudent.dart' as upStd;

class ListStudentScreen extends StatefulWidget {
  final String stdDepartment, stdYear, stdDivision ;
  const ListStudentScreen({super.key,required this.stdDepartment, required this.stdYear, required this.stdDivision});

  @override
  State<ListStudentScreen> createState() => _ListStudentScreenState();
}

class _ListStudentScreenState extends State<ListStudentScreen> {

  late Future<List<dynamic>> studentList;
  Set<int> selectedIndexes={};
  int totalIndex=0;
  
  @override
  void initState() {
    super.initState();
    studentList=Modules.FetchData("Student",dept: widget.stdDepartment,year: widget.stdYear, division: widget.stdDivision);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("             "+widget.stdYear+widget.stdDepartment+"\nDivision " + widget.stdDivision +" Student List",
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
        centerTitle: true,
        backgroundColor: Colors.pink.shade50,
        actions: selectedIndexes.isNotEmpty?[
          IconButton(
              onPressed: (){
                setState(() {
                  if(selectedIndexes.length == totalIndex){
                    selectedIndexes.clear();
                  }else{
                    selectedIndexes=Set<int>.from(List.generate(totalIndex, (i) => i));
                  }
                });
              },
              icon: Icon(Icons.select_all)
          ),

          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async{
                bool confirmDelete = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Delete Selected Items"),
                        content: Text("Are You Sure You want to delete all Selected Items?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context,false),
                              child: Text("Cancel")
                          ),
                          TextButton(
                              onPressed: () => Navigator.pop(context,true),
                              child: Text("Delete",style: TextStyle(color: Colors.red))
                          ),
                        ],
                    )
                );
                if(confirmDelete){
                  List<dynamic> studentData = await studentList;
                  for(int index in selectedIndexes){
                    var item = studentData[index];
                    await DeleteData(context, "Student", student_id: item["student_id"].toString());
                  }
                  setState(() {
                    selectedIndexes.clear();
                    studentList = Modules.FetchData("Student", dept: widget.stdDepartment);
                  });
                }
              },
          ),
        ]:[],
      ),
      backgroundColor: Colors.pink.shade50,
      body:Column(
        children: [
          Expanded(
              child: FutureBuilder(
                  future: studentList,
                  builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);
                    else if(snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"),);
                    else if(!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No data Found"),);

                    totalIndex=snapshot.data!.length;
                    return ListView.builder(
                      itemCount: totalIndex,
                        itemBuilder: (context,index){
                        var item=snapshot.data![index];
                        bool isSelected=selectedIndexes.contains(index);
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Card(
                            color: isSelected ? Colors.redAccent.shade100 :Colors.blue.shade100,
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: Icon(Icons.person,color: Colors.redAccent),
                              title: Text(item["name"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PopupMenuButton<String>(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                            child: Text("Update"),
                                          value: "update",
                                        ),
                                        PopupMenuItem(
                                          child: Text("Delete"),
                                          value: "delete",
                                        )
                                      ],
                                    icon: Icon(Icons.more_vert),
                                    onSelected: (value)async {
                                      if (value == "update") {
                                        List<dynamic> yearList = await Modules.FetchYear(widget.stdDepartment);
                                        List<dynamic> divisionList = await Modules.FetchDivision(widget.stdDivision);
                                        Navigator.push(context, MaterialPageRoute(builder:
                                            (context) => UpdateStudentScreen(student_id: item["student_id"],
                                              yearList: yearList, divisionList: divisionList,)));
                                      }
                                      else if (value == "delete") {
                                        bool confirmDelete = await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                AlertDialog(
                                                  title: Text(
                                                      "Delete Selected Student"),
                                                  content: Text(
                                                      "Are You Sure You want to delete Selected Student?"),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                                                    TextButton(
                                                        onPressed: () => Navigator.pop(context, true),
                                                        child: Text("Delete", style: TextStyle(color: Colors.red))
                                                    ),
                                                  ],
                                                )
                                        );
                                        if (confirmDelete) {
                                            await DeleteData(context, "Student", student_id: item["student_id"].toString());
                                          setState(() {
                                            studentList = Modules.FetchData("Student", dept: widget.stdDepartment);
                                          });
                                        }
                                      }
                                    }
                                  )
                                ],
                              ),
                              onTap: (){
                                if(selectedIndexes.isNotEmpty) {
                                  setState(() {
                                    if(isSelected){
                                      selectedIndexes.remove(index);
                                    }else{
                                      selectedIndexes.add(index);
                                    }
                                  });
                                }else{
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => StudentDetailScreen(student_id: item["student_id"]),),);
                                }

                              },
                              onLongPress: (){
                                setState(() {
                                  selectedIndexes.add(index);
                                });
                              },
                            ),
                          ),
                        );
                    });
                  } 
              )
          )
        ],
      )
    );
  }
}

Future<void> DeleteData(BuildContext context, String option, {String? student_id, String? faculty_id,
 String? class_id, String? division_id}) async{
  final uri=Uri.parse(URL+"/deleteRecord");
  final response=await http.post(
      uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "option":option,
        "student_id":student_id.toString(),
        "faculty_id":faculty_id.toString(),
        "class_id":class_id.toString(),
        "division_id":division_id.toString()
      })
  );
  if(response.statusCode == 200){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Record Deleted Successfully")));
  }else{
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Delete Record")));
  }

}

